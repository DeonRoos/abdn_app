library(shiny)
library(mgcv)
library(dplyr)

shinyServer(function(input, output, session) {
  # Load the pre-trained model
  model_path <- file.path("data", "model_m1.rds")
  model_m1 <- readRDS(model_path)
  
  # Render the saved Leaflet maps
  output$leaflet_map_price <- renderUI({
    tags$iframe(
      src = "abdn_homes_pricing.html",
      width = "100%",
      height = "600px",
      frameborder = "0",
      scrolling = "yes"
    )
  })
  
  output$leaflet_map_viewing <- renderUI({
    tags$iframe(
      src = "abdn_viewing.html",
      width = "100%",
      height = "600px",
      frameborder = "0",
      scrolling = "yes"
    )
  })
  
  output$leaflet_map_viewing_today <- renderUI({
    tags$iframe(
      src = "abdn_viewing_today.html",
      width = "100%",
      height = "600px",
      frameborder = "0",
      scrolling = "yes"
    )
  })
  
  observeEvent(input$predict, {
    new_data <- data.frame(
      lon = input$lon,
      lat = input$lat,
      sqmt = input$sqmt,
      rooms = input$rooms,
      type = input$type,
      baths = input$baths,
      epc = input$epc,
      tax = input$tax,
      days_since = input$days_since
    )
    
    prediction <- predict(model_m1, new_data, se.fit = TRUE)
    expect_price <- round(prediction$fit)
    low_price <- round(prediction$fit - 1.96 * prediction$se.fit)
    upp_price <- round(prediction$fit + 1.96 * prediction$se.fit)
    
    output$prediction <- renderText({
      paste0(
        "Expected Price: £", format(expect_price, big.mark = ","),
        "\nPrice Range: £", format(low_price, big.mark = ","), " - £", format(upp_price, big.mark = ",")
      )
    })
  })
})
