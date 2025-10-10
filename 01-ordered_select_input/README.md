# Ordered SelectInput [![status](http://assets.dull.systems:8080/status?id=scaling_shiny/01-ordered_select_input/README.md)](https://www.dull.systems/ordered-select-input "")

# Goal
Drop-in replacement for `shiny::selectInput` that preserves the order of selected items on initialization and bookmark restoration.

# Summary
The original `shiny::selectInput` control, when configured for multiple choice, alters the order of selected items during initialization. This is a [known bug](https://github.com/rstudio/shiny/issues/1490).

This simple wrapper uses a `selectize` javascript hook to preserve the order of the selection.

# Requirements:
- shiny ≥ 1.0.0

# Examples:
- See `app.R`
