# This is a test app to demonstrate the behavior of the `observer_dedup` function.
# Find the license at the end of the file.

# Instructions:
# - Launch the app on a web browser
# - Observe that:
#   - Clicking `foo` reports the removal of the previous copy of the internal observer
#   - Clicking `bar` only triggers a single print statement
# - Smile!

library(shiny)

source("observer_dedup.R")                                       # change

server <- function(input, output, session) {
  observe({
    foo <- input$foo
    
    observer_dedup(                                              # change
      id = 'dummy_id', session = session, verbose = TRUE,        # change
      expr =
        observe({
        print(paste0("foo was: ", foo, ". bar: ", input$bar))
      })
    )                                                            # change
  })
}

ui <- basicPage(
  actionButton("foo", "foo"),
  actionButton("bar", "bar")
)

shinyApp(ui, server)

# This file reproduces code originally found in this github issue post:
# https://github.com/rstudio/shiny/issues/825#issue-75758069
# We redistribute this code under the assumption that it shares the same license
# as the rstudio/shiny repository. That license reads:
#
# > MIT License
# > 
# > Copyright (c) 2025 shiny authors
# > 
# > Permission is hereby granted, free of charge, to any person obtaining a copy
# > of this software and associated documentation files (the "Software"), to deal
# > in the Software without restriction, including without limitation the rights
# > to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# > copies of the Software, and to permit persons to whom the Software is
# > furnished to do so, subject to the following conditions:
# > 
# > The above copyright notice and this permission notice shall be included in all
# > copies or substantial portions of the Software.
# > 
# > THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# > IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# > FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# > AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# > LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# > OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# > SOFTWARE.
