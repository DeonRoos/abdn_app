library(shiny)
library(mgcv)
library(dplyr)
library(leaflet)

shinyServer(function(input, output, session) {
  # Load the pre-trained model
  model_path <- file.path("data", "model_m1.rds")
  model_m1 <- readRDS(model_path)
  
  # Render the saved Leaflet maps
  output$leaflet_map_price <- renderUI({
    tags$iframe(
      src = "abdn_homes_pricing.html",
      width = "100%",
      height = "850px",
      frameborder = "0",
      scrolling = "yes"
    )
  })

  # Reactive values for storing coordinates
  coords <- reactiveValues(lon = -2.105621720258337, lat = 57.16686874046701)
  
  # Initial leaflet map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = coords$lon, lat = coords$lat, zoom = 12)
  })
  
  # Update coordinates and add marker on map click
  observeEvent(input$map_click, {
    click <- input$map_click
    coords$lon <- click$lng
    coords$lat <- click$lat
    leafletProxy("map") %>%
      clearMarkers() %>%
      addMarkers(lng = click$lng, lat = click$lat)
  })
  
  observeEvent(input$predict, {
    # Calculate days since the reference date
    reference_date <- as.Date("2024-09-27")
    selected_date <- input$date_selected
    days_since <- as.numeric(difftime(selected_date, reference_date, units = "days"))
    
    new_data <- data.frame(
      Longitude = coords$lon,
      Latitude = coords$lat,
      FloorArea = input$sqmt,
      rooms = input$rooms,
      Bathrooms = input$baths,
      HouseType = input$type,
      UR8Name = input$UR8,
      baths = input$baths,
      epc_band = as.factor(input$epc),
      council_tax_band = as.factor(input$tax),
      days_since = days_since,
      parking_type = input$parking_type,
      num_floors = as.factor(input$num_floors),
      has_garden = "Yes"
    )
    
    prediction <- predict(model_m1, new_data, se.fit = TRUE)
    expect_price <- round(prediction$fit)
    low_price <- round(prediction$fit - 1.96 * prediction$se.fit)
    upp_price <- round(prediction$fit + 1.96 * prediction$se.fit)
    
    output$prediction <- renderText({
      paste0(
        "<div style='text-align: center;'>",
        "<p style='font-size: 24px;'>We predict your house would be listed at:</p>",
        "<p style='font-size: 36px; font-weight: bold; color: #00A68A;'>£", format(expect_price, big.mark = ","), "</p>",
        "<p style='font-size: 18px;'>Price Range: £", format(low_price, big.mark = ","), " - £", format(upp_price, big.mark = ","), "</p>",
        "</div>"
      )
    })
    
    output$prediction_details <- renderUI({
      HTML(paste0(
        "<h4>Details Used for Prediction</h4>",
        "<ul>",
        "<li>House Type: ", input$type, "</li>",
        "<li>Urban|Rural: ", input$UR8, "</li>",
        "<li>Number of Floors: ", input$num_floors, "</li>",
        "<li>Number of Rooms: ", input$rooms, "</li>",
        "<li>Number of Bathrooms: ", input$baths, "</li>",
        "<li>Square Meters: ", input$sqmt, "</li>",
        "<li>EPC Rating: ", input$epc, "</li>",
        "<li>Tax Band: ", input$tax, "</li>",
        "<li>Parking: ", input$parking_type, "</li>",
        "<li>Longitude: ", coords$lon, "</li>",
        "<li>Latitude: ", coords$lat, "</li>",
        "<li>On (Date): ", selected_date, "</li>",
        "</ul>"
      ))
    })
  })
})


