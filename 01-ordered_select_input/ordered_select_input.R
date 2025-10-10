# (License terms at the end of this file)

# Wrapper and drop-in replacement for `shiny::selectInput` that preserves the order of selected items on initialization
# and bookmark restoration (see https://github.com/rstudio/shiny/issues/1490)
# 
# It requires the `selectize` parameter to be TRUE for multi-selections.
OrderedSelectInput <- function(inputId, label, choices, selected = NULL, multiple = FALSE, selectize = TRUE,
                               width = NULL, size = NULL) {
  res <- NULL
  if (isTRUE(multiple)) {
    if (!isTRUE(selectize)) stop("OrderedSelectInput requires `selectize = TRUE` for multi-selectors")
    if (!is.null(selected) && !is.character(selected)) 
      stop("OrderedSelectInput `select` parameter should be of type `character`")
    
    # For multi-selectors, we bypass the default problematic behavior of the `selected` parameter and
    # instead inject the selection through the `onInitialize` selectize hook.
    # The server-side part of the selector is unaware of this, so it can't properly bookmark its state.
    # This call to `shiny::restoreInput` addresses that.
    selected <- shiny::restoreInput(id = inputId, default = selected)
    
    initial_value_js <- paste("[", paste(sprintf("'%s'", selected), collapse = ", "), "]")
    res <- shiny::selectizeInput(
      inputId = inputId, label = label, choices = choices, multiple = TRUE, selected = NULL,
      options = list( # see https://selectize.dev/docs/events
        onInitialize = I(sprintf("function() { this.setValue(%s); }", initial_value_js))
      )
    )
  } else { # Pass-through
    res <- shiny::selectInput(inputId = inputId, label = label, choices = choices, selected = selected, 
                              multiple = FALSE, selectize = selectize, width = width, size = size)
  }
  return(res)
}

# This function is a simplified version of:
# https://github.com/Boehringer-Ingelheim/dv.explorer.parameter/blob/30c5638f9a154fc25717fd1e5bcdcb6fdbd0c65e/R/DR.R#L51-L87
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
# (see https://github.com/Boehringer-Ingelheim/dv.explorer.parameter/blob/30c5638f9a154fc25717fd1e5bcdcb6fdbd0c65e/LICENSE)
#
# The changes specific to this file are dual-licensed (pick one!) under:
# - The same Apache 2 license, in case it suits your use case, but under this copyright:
#   Copyright (c) 2025 Miguel Lechón
# - The more permissive Zero-Clause BSD license:
#   Copyright (c) 2025 Miguel Lechón
#   Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
#   THE SOFTWARE IS PROVIDED “AS IS” AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
