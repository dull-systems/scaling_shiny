# This is just a test app to demonstrate the behavior of the following selector:
source("ordered_select_input.R", local = TRUE)

# Instructions:
# - Launch the app on a web browser
# - See that the initial `selected` configuration is preserved
# - Manually change the selection
# - Create a bookmark
# - Restore that bookmark
# - See that the manual selection is preserved
# - Smile!
shiny::shinyApp(
  ui = function(request){
    shiny::fluidPage(
      shiny::bookmarkButton(),
      OrderedSelectInput(inputId = "selection", label = "Selection:",
                         choices = list(
                           "A", "B", "C",            # plain choices
                           D = list("D1", "D2")      # choices nested inside a category
                         ),
                         selected = c("B", "D2", "A"),
                         multiple = TRUE
      ),
      shiny::textOutput("selection"),
    )
  },
  server = function(input, output) {
    output[["selection"]] <- shiny::renderText({
      v <- paste(input[["selection"]], collapse = ", ")
      print(paste("Selection:", v))                  # printed to show there are no unnecessary reactive invalidations
      v
    })
  }, enableBookmarking = "url"
)
