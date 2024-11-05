library(shiny)
library(mgcv)
library(dplyr)
library(leaflet)
library(sf)
library(shinyjs)

shinyServer(function(input, output, session) {
  
  # Enable shinyjs
  useShinyjs()
  
  # Reactive values for storing coordinates and UR8Name
  coords <- reactiveValues(lon = -2.105621720258337, lat = 57.16686874046701, UR8Name = NULL)
  
  # Load the pre-trained model
  model_path <- file.path("data", "model_m1.rds")
  model_m1 <- readRDS(model_path)
  
  # Load and preprocess shapefile for UR8Name detection
  shapefile_path <- file.path("data", "SG_UrbanRural_2020", "SG_UrbanRural_2020.shp")
  urban_rural_shp <- st_read(shapefile_path) %>%
    st_transform(crs = 4326)
  
  # Render static price map
  output$leaflet_map_price <- renderUI({
    tags$iframe(
      src = "abdn_homes_pricing.html",
      width = "100%",
      height = "850px",
      frameborder = "0",
      scrolling = "yes"
    )
  })
  
  # Initial leaflet map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = coords$lon, lat = coords$lat, zoom = 12)
  })
  
  # Update coordinates and marker on map click
  observeEvent(input$map_click, {
    click <- input$map_click
    coords$lon <- click$lng
    coords$lat <- click$lat
    # Find UR8Name based on coordinates
    point_sf <- st_as_sf(data.frame(lon = coords$lon, lat = coords$lat), coords = c("lon", "lat"), crs = 4326)
    coords$UR8Name <- st_join(point_sf, urban_rural_shp, left = TRUE)$UR8Name
    leafletProxy("map") %>%
      clearMarkers() %>%
      addMarkers(lng = click$lng, lat = click$lat)
  })
  
  # List of Solicitors for the selectInput
  solicitor_choices <- c(
    "James & George Collie", "Aberdein Considine", "Raeburn Christie Clark & Wallace",
    "Solicitors Direct", "Andersonbain LLP", "Storie, Cruden & Simpson",
    "Kellas", "Burnett & Reid LLP", "Ledingham Chalmers LLP",
    "Mackinnons", "Alex Hutcheon + Co", "Wilsone & Duffus",
    "A.C. Morrison & Richards LLP", "Stewart & Watson", "Peterkins",
    "Laurie & Co", "Adam Flowerdew & Reynolds", "Masson & Glennie LLP",
    "Shiells", "Smith Solicitors Stonehaven", "Balfour + Manson",
    "T. Duncan & Co.", "Gavin Bain & Co.", "Stronachs LLP",
    "Brown & McRae", "Church Of Scotland", "Thorntons",
    "Grant Smith Law Practice", "Murdoch, Mcmath & Mitchell", "Walter Gerrard & Co",
    "Gilson Gray LLP", "Howie & Co", "Burnett Legal Services Ltd.",
    "Macrae Stephen & Co", "Blackadders", "Hamilton Watt & Co",
    "Taggart, Meil, Mathers", "Beckley Kenny & Co", "John Davie & Co",
    "Alex Hutcheon & Company Ltd"
  )
  
  # Show input form modal dialog
  observeEvent(input$show_modal, {
    showModal(modalDialog(
      title = "House Details",
      easyClose = TRUE,
      footer = tagList(modalButton("Cancel"), actionButton("submit_details", "Submit")),
      
      selectInput("type", "House Type:", choices = c("Detached", "Semi-Detached", "Terraced", "Flat"), selected = "Detached"),
      numericInput("sqmt", "Square Meters:", value = 103),
      numericInput("bedrooms", "Number of Bedrooms:", value = 3),
      numericInput("publicrooms", "Number of Public Rooms:", value = 2),
      numericInput("baths", "Number of Bathrooms:", value = 1),
      selectInput("parking_type", "Parking Type:", choices = c("Double Garage", "Garage", "No parking", "Parking"), selected = "Garage"),
      selectInput("epc", "EPC Rating:", choices = c("A", "B", "C", "D", "E", "F", "G"), selected = "C"),
      selectInput("tax", "Tax Band:", choices = c("A", "B", "C", "D", "E", "F", "G"), selected = "D"),
      selectInput("has_garden", "Has Garden:", choices = c("Yes", "No"), selected = "Yes"),
      selectInput("solicitor", "Solicitor Account Name:", choices = solicitor_choices, selected = "James & George Collie"),
      dateInput("date_selected", "Select Date:", value = Sys.Date(), min = "2024-09-27", max = Sys.Date())
    ))
  })
  
  # Store modal inputs and close modal on submit
  observeEvent(input$submit_details, {
    removeModal()
    
    # Store inputs and validate for predict button enablement
    if (!is.null(input$type) && input$sqmt > 0 && !is.null(input$bedrooms) &&
        !is.null(input$publicrooms) && !is.null(input$baths) &&
        !is.null(input$parking_type) && !is.null(input$epc) && 
        !is.null(input$tax) && !is.null(input$has_garden) && 
        !is.null(input$solicitor) && !is.null(input$date_selected) && 
        !is.null(coords$UR8Name)) {
      shinyjs::enable("predict")  # Enable the button if all fields are filled
    } else {
      shinyjs::disable("predict")  # Keep the button disabled otherwise
    }
  })
  
  # Prediction logic on button click
  observeEvent(input$predict, {
    reference_date <- as.Date("2024-09-27")
    days_since <- as.numeric(difftime(input$date_selected, reference_date, units = "days"))
    
    # Prepare data frame for prediction
    new_data <- data.frame(
      Longitude = coords$lon,
      Latitude = coords$lat,
      FloorArea = input$sqmt,
      Bathrooms = input$baths,
      HouseType = input$type,
      UR8Name = coords$UR8Name,
      Bedrooms = input$bedrooms,
      PublicRooms = input$publicrooms,
      parking_type = input$parking_type,
      has_garden = input$has_garden,
      epc_band = as.factor(input$epc),
      council_tax_band = as.factor(input$tax),
      days_since = days_since,
      SolicitorAccount_Name = as.factor(input$solicitor)
    )
    
    # Prediction and confidence interval
    prediction <- predict(model_m1, new_data, se.fit = TRUE)
    expect_price <- round(prediction$fit)
    low_price <- round(prediction$fit - 1.96 * prediction$se.fit)
    upp_price <- round(prediction$fit + 1.96 * prediction$se.fit)
    
    # Render prediction result
    output$prediction <- renderText({
      paste0("<div style='text-align: center;'>",
             "<p style='font-size: 24px;'>We predict your house would be listed at:</p>",
             "<p style='font-size: 36px; font-weight: bold; color: #00A68A;'>£", format(expect_price, big.mark = ","), "</p>",
             "<p style='font-size: 18px;'>Price Range: £", format(low_price, big.mark = ","), " - £", format(upp_price, big.mark = ","), "</p>",
             "</div>")
    })
    
    output$prediction_details <- renderUI({
      HTML(paste0(
        "<h4>Details Used for Prediction</h4>",
        "<ul>",
        "<li>House Type: ", input$type, "</li>",
        "<li>UR8Name: ", coords$UR8Name, "</li>",
        "<li>Bedrooms: ", input$bedrooms, "</li>",
        "<li>Public Rooms: ", input$publicrooms, "</li>",
        "<li>Number of Bathrooms: ", input$baths, "</li>",
        "<li>Square Meters: ", input$sqmt, "</li>",
        "<li>EPC Rating: ", input$epc, "</li>",
        "<li>Tax Band: ", input$tax, "</li>",
        "<li>Parking: ", input$parking_type, "</li>",
        "<li>Longitude: ", coords$lon, "</li>",
        "<li>Latitude: ", coords$lat, "</li>",
        "<li>On (Date): ", input$date_selected, "</li>",
        "<li>Solicitor: ", input$solicitor, "</li>",
        "</ul>"
      ))
    })
  })
})
