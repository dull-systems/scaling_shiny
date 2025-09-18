# Shiny App Hot Reloader [![status](http://assets.dull.systems:8080/status?id=scaling_shiny/00-hot_reload/README.md)](https://dull.systems/hot-reloading-shiny-apps "")

# Goal
Faster development of shiny-related R packages through app hot reloading.

# Summary
Reloading a shiny app while preserving its input state can be accomplished by:
- Autoreloading it (https://shiny.posit.co/r/reference/shiny/latest/shinyoptions.html, look for "shiny.autoreload").
- Autobookmarking its state after each change (https://mastering-shiny.org/action-bookmark.html#updating-the-url).

This script builds upon those two techniques and provides the following extra benefits:
- It hot-reloads apps without altering their source code.
- It runs arbitrary functions before the app (re)loads or stops. This makes possible, among other things,
  to `devtools::load_all()` packages before every reload.

# Requirements:
- shiny >= 1.11.0

  Previous versions of shiny don't reload apps fully unless the launched app file itself changes.
  This can be worked around through by launching a separate app reloader process. If you need to use an older version
  of shiny, reach out to contact@dull.systems for more details.

# Examples:
<details><summary><big><b>Working on a plain shiny app:</b></big> <i><small>[show/hide]</small></i></summary>

- Download this repository.
- Load the `dummy_sample_projects/non_package/non_package.Rproj` project.
- Run `source("../../shiny_hot_reload.R")`.
- Move the slider to 50.
- Change the sliderInput `max` value to 100 in `dummy_sample_projects/non_package/app.R`.
- Notice how the running app incorporates the changes while maintaining its state. Stop the app.
</details>

<details><summary><big><b>Working on a shiny app that depends on a package:</b></big> <i><small>[show/hide]</small></i></summary>

- Load the `dummy_sample_projects/package/package.Rproj`
- Make sure you the `devtools` package is installed.
- Run `source("../../shiny_hot_reload.R")`.
- Move the slider to 50.
- Change the sliderInput `max` value to 100 in `dummy_sample_projects/package/R/stuff.R`.
- Notice how the running app has loaded the changes while maintaining its state.
- Notice how the console output prints a "i Loading example_package" message every time the app reloads. Stop the app.
</details>

# Configuration:
- Tweak or rewrite the functions `user_app`, `user_pre_reload` and `user_post_disconnect` to suit your workflow.
- Tweak the `user_settings` list.

# Usage:
- Navigate to the root folder of the project you want to work on.
- Run this command: `source("path/to/shiny_hot_reload.R")`
