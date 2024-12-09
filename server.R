library(shiny)
library(mgcv)
library(dplyr)
library(leaflet)
library(sf)
library(shinyjs)

shinyServer(function(input, output, session) {
  
  # Enable shinyjs
  useShinyjs()
  
  # Reactive values to store map coordinates and form data
  coords <- reactiveValues(lon = -2.105621720258337, lat = 57.16686874046701, UR8Name = NULL)
  form_data <- reactiveValues(
    type = "Detached",
    sqmt = 83,
    bedrooms = 2,
    publicrooms = 1,
    baths = 1,
    parking_type = "Garage",
    epc = "F",
    tax = "D",
    has_garden = "Yes",
    num_floors = "1",
    solicitor = "James & George Collie",
    date_selected = Sys.Date()
  )
  
  # Load the pre-trained model
  model_m1 <- readRDS(file.path("data", "model_m1.rds"))
  
  # Load and preprocess shapefile for UR8Name detection
  urban_rural_shp <- st_read(file.path("data", "SG_UrbanRural_2020", "SG_UrbanRural_2020.shp")) %>%
    st_transform(crs = 4326)
  
  # Solicitor choices
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
  
  # --- UI Rendering ---
  
  # Render static price map iframe
  output$leaflet_map_price <- renderUI({
    tags$iframe(
      src = "abdn_homes_pricing.html",
      width = "100%",
      height = "850px",
      frameborder = "0",
      scrolling = "yes"
    )
  })
  
  # Initial Leaflet map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = coords$lon, lat = coords$lat, zoom = 12)
  })
  
  # --- Event Observers ---
  
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
  
  # Show modal for entering house details
  observeEvent(input$show_modal, {
    showModal(createHouseDetailsModal())
  })
  
  # Store modal inputs and enable predict button if valid
  observeEvent(input$submit_details, {
    updateFormData()
    removeModal()
    validateInputs()
  })
  
  # --- Prediction Logic ---
  
  observeEvent(input$predict, {
    output$prediction <- renderText({
      prediction_results <- makePrediction()
      formatPredictionText(prediction_results)
    })
    
    output$prediction_details <- renderUI({
      renderPredictionDetails(coords, form_data)
    })
  })
  
  # --- Helper Functions ---
  
  # Create modal dialog for house details
  createHouseDetailsModal <- function() {
    modalDialog(
      title = "House Details",
      easyClose = TRUE,
      footer = tagList(modalButton("Cancel"), actionButton("submit_details", "Submit")),
      
      selectInput("type", "House Type:", choices = c("Detached", "Semi-Detached", "Terraced", "Flat"), selected = form_data$type),
      numericInput("sqmt", "Square Meters:", value = form_data$sqmt),
      numericInput("bedrooms", "Number of Bedrooms:", value = form_data$bedrooms),
      numericInput("publicrooms", "Number of Public Rooms:", value = form_data$publicrooms),
      numericInput("baths", "Number of Bathrooms:", value = form_data$baths),
      selectInput("parking_type", "Parking Type:", choices = c("Double Garage", "Garage", "No parking", "Parking"), selected = form_data$parking_type),
      selectInput("epc", "EPC Rating:", choices = LETTERS[1:7], selected = form_data$epc),
      selectInput("tax", "Tax Band:", choices = LETTERS[1:7], selected = form_data$tax),
      selectInput("has_garden", "Has Garden:", choices = c("Yes", "No"), selected = form_data$has_garden),
      selectInput("num_floors", "Number of floors:", choices = c("1", "2"), selected = form_data$num_floors),
      selectInput("solicitor", "Solicitor Account Name:", choices = solicitor_choices, selected = form_data$solicitor),
      dateInput("date_selected", "Select Date:", value = form_data$date_selected, min = "2024-09-27", max = Sys.Date())
    )
  }
  
  # Update form data with modal inputs
  updateFormData <- function() {
    for (field in names(form_data)) {
      form_data[[field]] <- input[[field]]
    }
  }
  
  # Enable predict button if inputs are valid
  validateInputs <- function() {
    if (all(!is.null(unlist(form_data)), !is.null(coords$UR8Name))) {
      shinyjs::enable("predict")
    } else {
      shinyjs::disable("predict")
    }
  }
  
  # Make prediction using the model
  makePrediction <- function() {
    days_since <- as.numeric(difftime(form_data$date_selected, as.Date("2024-09-27"), units = "days"))
    
    new_data <- data.frame(
      Longitude = coords$lon,
      Latitude = coords$lat,
      FloorArea = form_data$sqmt,
      Bathrooms = form_data$baths,
      HouseType = form_data$type,
      UR8Name = coords$UR8Name,
      Bedrooms = form_data$bedrooms,
      PublicRooms = form_data$publicrooms,
      parking_type = form_data$parking_type,
      has_garden = form_data$has_garden,
      num_floors = form_data$num_floors,
      epc_band = as.factor(form_data$epc),
      council_tax_band = as.factor(form_data$tax),
      days_since = days_since,
      SolicitorAccount_Name = as.factor(form_data$solicitor)
    )
    
    predict(model_m1, new_data, se.fit = TRUE)
  }
  
  # Format prediction text
  formatPredictionText <- function(prediction) {
    expect_price <- round(prediction$fit, -3)
    low_price <- round(prediction$fit - 1.96 * prediction$se.fit, -3)
    upp_price <- round(prediction$fit + 1.96 * prediction$se.fit, -3)
    
    paste0("<div style='text-align: center;'>",
           "<p style='font-size: 24px;'>We predict your house would be listed at:</p>",
           "<p style='font-size: 36px; font-weight: bold; color: #00A68A;'>£", format(expect_price, big.mark = ","), "</p>",
           "<p style='font-size: 18px;'>Price Range: £", format(low_price, big.mark = ","), " - £", format(upp_price, big.mark = ","), "</p>",
           "</div>")
  }
  
  # Render prediction details
  renderPredictionDetails <- function(coords, form_data) {
    HTML(paste0(
      "<h4>Details Used for Prediction</h4>",
      "<ul>",
      "<li>House Type: ", form_data$type, "</li>",
      "<li>UR8Name: ", coords$UR8Name, "</li>",
      "<li>Bedrooms: ", form_data$bedrooms, "</li>",
      "<li>Public Rooms: ", form_data$publicrooms, "</li>",
      "<li>Number of Bathrooms: ", form_data$baths, "</li>",
      "<li>Square Meters: ", form_data$sqmt, "</li>",
      "<li>EPC Rating: ", form_data$epc, "</li>",
      "<li>Tax Band: ", form_data$tax, "</li>",
      "<li>Parking: ", form_data$parking_type, "</li>",
      "<li>Has Garden: ", form_data$has_garden, "</li>",
      "<li>Number of Floors: ", form_data$num_floors, "</li>",
      "<li>Solicitor: ", form_data$solicitor, "</li>",
      "<li>Date Selected: ", form_data$date_selected, "</li>",
      "<li>Longitude: ", coords$lon, "</li>",
      "<li>Latitude: ", coords$lat, "</li>",
      "</ul>"
    ))
  }
})
