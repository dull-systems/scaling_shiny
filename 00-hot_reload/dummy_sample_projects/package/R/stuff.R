ui <- function(request){
  shiny::fluidPage(
    shiny::titlePanel("Old Faithful Geyser Data"),

    shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::sliderInput("bins",
                           "Number of bins:",
                           min = 2,
                           max = 50,
                           value = 30)
      ),

      shiny::mainPanel(
        shiny::plotOutput("distPlot")
      )
    )
  )
}

server <- function(input, output, session) {
  output$distPlot <- shiny::renderPlot({
    x    <- faithful[, 2]
    bins <- seq(min(x), max(x), length.out = input$bins + 1)

    graphics::hist(x, breaks = bins, col = 'darkgray', border = 'white',
                   xlab = 'Waiting time to next eruption (in mins)',
                   main = 'Histogram of waiting times')
  })
}

old_faithful_app <- shiny::shinyApp(ui = ui, server = server)
