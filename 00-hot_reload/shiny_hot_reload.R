# Copyright (c) 2025 Miguel Lechón and Luis Morís
# Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
# THE SOFTWARE IS PROVIDED “AS IS” AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

# Shiny App Hot Reloader - v0.1.0
# https://www.dull.systems/hot-reloading-shiny-apps

# Version history:
# 0.1.0 (2025-09-22) First public release
# --------------------------------------------------------------------------

# Goal: Faster development of shiny-related R packages through app hot reloading.
#
# Reloading a shiny app while preserving its input state can be accomplished by:
# - Autoreloading it (https://shiny.posit.co/r/reference/shiny/latest/shinyoptions.html, look for "shiny.autoreload").
# - Autobookmarking its state after each change (https://mastering-shiny.org/action-bookmark.html#updating-the-url).
#
# This script builds upon those two techniques and provides the following extra benefits:
# - It hot-reloads apps without altering their source code.
# - It runs arbitrary functions before the app (re)loads or stops. This makes possible, among other things,
#   to `devtools::load_all()` packages before every reload.
#
# Requirements:
# - shiny >= 1.11.0
#   Previous versions of shiny don't reload apps fully unless the launched app file itself changes.
#   This can be worked around through by launching a separate app reloader process. If you need to use an older version
#   of shiny, reach out to contact@dull.systems for more details.
#
# Examples:
# - Download this repository.
# - Load the `dummy_sample_projects/non_package/non_package.Rproj` project.
# - Run `source('../../shiny_hot_reload.R')`.
# - Move the slider to 50.
# - Change the sliderInput `max` value to 100 in `dummy_sample_projects/non_package/app.R`.
# - Notice how the running app incorporates the changes while maintaining its state. Stop the app.
#
# - Load the `dummy_sample_projects/package/package.Rproj`
# - Make sure the `devtools` package is installed.
# - Run `source('../../shiny_hot_reload.R')`.
# - Move the slider to 50.
# - Change the sliderInput `max` value to 100 in `dummy_sample_projects/package/R/stuff.R`.
# - Notice how the running app has loaded the changes while maintaining its state.
# - Notice how the console output prints a "i Loading example_package" message every time the app reloads. Stop the app.
#
# Configuration:
# - Tweak or rewrite the `user_app`, `user_pre_reload` and `user_post_disconnect` functions to suit your workflow.
# - Tweak the `user_settings` list below.
#
# Usage:
# - Navigate to the root folder of the project you want to work on.
# - Run this command: `source('path/to/shiny_hot_reload.R')`
#
local({ # avoid polluting the session with our variables
  # USER CONFIGURATION ----
  # This function returns the shiny app object you want to live-reload. Go ahead and modify it according to your needs.
  # Right now it looks for a `shiny_hot_reload_app.R` file to run. If it can't find one, it looks at the name of the
  # working folder and, depending on it, loads a predefined app to run.
  user_app <- function(){
    default_app_path <- './shiny_hot_reload_app.R'
    if(file.exists(default_app_path)){
      app <- source(default_app_path, local = TRUE)[['value']]
    }else{
      project_dir <- basename(getwd())
      app <- switch(
        project_dir,
        'non_package' = source('app.R', local = TRUE)[['value']], # how to load a standalone `app.R` file
        'package' = old_faithful_app,                             # how to load a symbol inside a package
        stop(paste('Unknown action for path', getwd()))
      )
    }
    return(app)
  }

  # This function runs arbitrary code prior to (re)loading the target app.
  # It is not strictly necessary, as adding these statements inside `user_app` above would accomplish the same effect.
  # Right now it checks if the current folder looks like the root of an R package. If it does, it reloads it.
  user_pre_reload <- function(){
    codebase_is_a_package <- file.exists('DESCRIPTION')
    if(codebase_is_a_package) devtools::load_all()
  }

  # This function runs arbitrary code once the client disconnects from the target app.
  # Right now it's empty.
  user_post_disconnect <- function() NULL

  # `user_settings` is a list with the following two elements:
  # - `options`:
  #      [named list] Global R options to set before running the target shiny app. Reverted after the app exits.
  # - `preserve_state_across_reloads`:
  #      [logical(1)] Whether to preserve the state of inputs. Sometimes full reloads are more convenient.
  user_settings <- list(
    options = list( # these are some suggestions; (un)comment as you see fit
      # shiny.autoreload.pattern = '.*\\.(r|html?|js|css|png|jpe?g|gif)$', # shiny's default autoreload pattern
      # shiny.launch.browser = TRUE,
      # shiny.fullstacktrace = TRUE,
      shiny.autoload.r = FALSE
    ),
    preserve_state_across_reloads = !( # Preserve state for all but two folders
      basename(getwd()) %in% c('first_folder_name', 'second_folder_name')
    )
  )

  # APP RELOADER ----
  initially_sourced <- !isTRUE(getOption('autoreload.should_run_app'))

  if(initially_sourced){ # 1. This branch runs when you `source()` this script interactively.
    get_path_to_this_file <- function() {
      f <- function() NULL
      return(file.path(utils::getSrcDirectory(f), utils::getSrcFilename(f)))
    }
    path_to_this_file <- get_path_to_this_file()

    if(nchar(system.file(package='shiny')) == 0 || packageVersion('shiny') < '1.11.0'){
      stop(sprintf('This script requires shiny >= 1.11.0 [%s]', path_to_this_file))
    }

    # 1.1 We set up the reload functionality, along with user project-specific desired options.
    options_to_restore <- do.call(
      options, c(autoreload.should_run_app = TRUE, shiny.autoreload = TRUE,  user_settings[['options']])
    )
    on.exit(do.call(options, options_to_restore), add = TRUE, after = FALSE)

    # 1.2 We then copy this script to the folder from where you `source()`d this file (root of your project), because:
    # - shiny only autoreloads apps provided as paths to files.
    # - shiny only looks for changes inside the folder containing the app script.
    # - shiny stores bookmarks in the folder containing the app script.
    tmp_app_path <- tempfile(pattern = 'autoreload_app_', fileext = '.R', tmpdir = getwd())
    file.copy(from = path_to_this_file, to = tmp_app_path)
    on.exit(unlink(tmp_app_path), add = TRUE, after = FALSE)

    # 1.3 And then we run the temporary file as an app.
    return(invisible(print(shiny::runApp(tmp_app_path))))
  }else{ # 2. This branch runs when this script is launched by the `shiny::runApp(...)` expression above.
    user_pre_reload()
    app <- user_app()

    original_server_function <- environment(app[['serverFuncSource']])[['server']]
    if(length(formals(original_server_function)) != 3)
      stop('The hot reload tool expects a server function that takes three arguments (input, output and session).')
   
    # 2.1 We patch the app so that it updates its query string after each input event.
    # To do that, we rely on undocumented shiny implementation details. That's OK, because this tool is only useful for
    # development and can't affect applications in production.
    wrapped_server_function <- function(input, output, session){
      if(isTRUE(user_settings[['preserve_state_across_reloads']])){
        shiny::observe({
          shiny::reactiveValuesToList(input)
          session$doBookmark()
        })
        shiny::onBookmarked(shiny::updateQueryString)
      }

      shiny::onStop(user_post_disconnect)
      
      return(original_server_function(input, output, session))
    }
    
    app[['serverFuncSource']] <- function() wrapped_server_function

    if(isTRUE(user_settings[['preserve_state_across_reloads']]) &&
       !isTRUE(app[['appOptions']][['bookmarkStore']] %in% c('url', 'server')))
      app[['appOptions']][['bookmarkStore']] <- 'url'

    # 2.2 We return the patched app to the `runApp` expression [1.3].
    return(app)
  }
})
