# (License terms at the end of this file)

# Solves https://github.com/rstudio/shiny/issues/825#issuecomment-496679761
observer_dedup <- local({
  # Evaluates `expr` under a reactive domain identified by `id` while keeping track of all observers created by it.
  # On repeated calls to this function, the old tracked observers are destroyed prior to evaluating `expr`.
  
  states <- list() # One state per `id`. Each state is an environment for mutation purposes.
  
  observer_dedup_func <- function(id, expr, session = shiny::getDefaultReactiveDomain(), verbose = FALSE) {
    # New state if unknown `id`
    if (!(id %in% names(states))) {
      states[[id]] <<- list2env(
        list(
          subdomain = list(end = function() NULL),
          captured_callbacks = list()
        ),
        parent = emptyenv()
      )
    }
    
    state <- states[[id]] # The only state that concerns us
    
    # Glorified append
    capture_callbacks <- function(callback) {
      return(state[["captured_callbacks"]][[length(state[["captured_callbacks"]]) + 1]] <<- callback)
    }
    
    make_scope_that_captures_callbacks <- function(namespace) {
      parent <- get("parent", envir = state[["subdomain"]])
      ns <- shiny::NS(namespace)
      scope <- parent$makeScope(namespace)
      overrides <- get("overrides", scope)
      overrides[["onEnded"]] <- capture_callbacks
      overrides[["makeScope"]] <- function(namespace) make_scope_that_captures_callbacks(ns(namespace))
      scope[["overrides"]] <- overrides
      return(scope)
    }
    
    invoke_and_remove_callbacks <- function() {
      for (cb in state[["captured_callbacks"]]) {
        if (verbose) {
          owner <- environment(cb)
          if (inherits(owner, "Observer")) {
            message(sprintf("Destroying observer %s %s", owner$.reactId, owner$.label))
          } else {
            browser()
          }
        }
        cb()
      }
      state[["captured_callbacks"]] <<- list()
    }
    
    state[["subdomain"]]$end() # Destroy tracked observers from the previous observer_dedup invocation
    state[["subdomain"]] <- shiny:::createSessionProxy( # Session that tracks observers even inside nested shiny modules
      session,
      makeScope = make_scope_that_captures_callbacks,
      onEnded = capture_callbacks,
      end = invoke_and_remove_callbacks
    )
    
    expr <- substitute(expr)
    env <- parent.frame()
    result <- shiny::withReactiveDomain(state[["subdomain"]], eval(expr, env))
    return(result)
  }
  return(observer_dedup_func)
})

# This function is a copy of:
# https://github.com/Boehringer-Ingelheim/dv.explorer.parameter/blob/7d8fa2cd81f2595c0b44975c06c1d81c6a78aa6b/R/dressing_room.R#L521-L587
#
# The original implementation is distributed under these terms:
# > Copyright 2024 Boehringer-Ingelheim Pharma GmbH & Co.KG
# > 
# > Licensed under the Apache License, Version 2.0 (the "License");
# > you may not use this file except in compliance with the License.
# > You may obtain a copy of the License at
# > 
# > http://www.apache.org/licenses/LICENSE-2.0
# > 
# > Unless required by applicable law or agreed to in writing, software
# > distributed under the License is distributed on an "AS IS" BASIS,
# > WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# > See the License for the specific language governing permissions and
# > limitations under the License.
# (see https://github.com/Boehringer-Ingelheim/dv.explorer.parameter/blob/7d8fa2cd81f2595c0b44975c06c1d81c6a78aa6b/LICENSE)
