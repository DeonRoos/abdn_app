library(shiny)

shinyUI(navbarPage(
  title = "Aberdeen House Prices",
  # Add custom styles to the head section of the HTML document
  tags$head(
    tags$style(
      HTML("
      /* Global styles */
      body {
        background-color: #202123 !important;
        color: white;
      }

      /* Main panel styles */
      .mainPanel {
        background-color: #202123 !important;
      }

      /* Sidebar panel styles */
      .well {
        background-color: #202123 !important;
        border: none !important;
      }

      /* Text color styles */
      h4, h6, p, .form-control-static, .text-output {
        color: white;
      }
      
      /* Custom CSS styles */
      .navbar .navbar-brand {
          font-size: 24px;
          color: #FFFFFF !important;
      }
      
      /* Navigation bar styles */
      .navbar {
        background-color: #444654;
        color: #00A68A; 
        font-weight: bold;
        border: 2px solid #00A68A;
        box-shadow: 0 0 10px 5px rgba(0, 166, 138, 0.3);
        font-size: 20px;
      }

      /* Navigation bar styles */
      .navbar .nav > li > a:hover,
      .navbar .nav > li > a:focus {
        background-color: #00A68A;
        color: #FFFFFF !important;
        border: 2px solid #00A68A;
        box-shadow: 0 0 10px 5px rgba(0, 166, 138, 0.3);
      }

      /* Navigation bar styles */
      .navbar .nav .active > a,
      .navbar .nav .active > a:hover,
      .navbar .nav .active > a:focus {
        background-color: #00A68A;
        color: #FFFFFF !important;
        border: 2px solid #00A68A;
        box-shadow: 0 0 10px 5px rgba(0, 166, 138, 0.3);
      }

      /* Input styles */
      .form-control, .selectize-input, .shiny-input-container {
        background-color: #444654 !important;
        color: white !important;
        border: 1px solid #00A68A;
      }

      /* Action button styles */
      .btn {
        background-color: #00A68A;
        color: #FFFFFF !important;
        border: 1px solid #00A68A;
      }

      /* Image container styles */
      .image-container {
        display: flex;
        justify-content: center;
      }

      /* Image styles */
      .image-container img {
        max-width: 100%;
        height: auto;
      }
      ")
    )
  ),
  
  tabPanel("Pricing Map",
           h3("Map of Aberdeen House Prices"),
           uiOutput("leaflet_map_price")
  ),
  tabPanel("Viewing Map",
           h3("Viewing Map"),
           uiOutput("leaflet_map_viewing")
  ),
  tabPanel("Today's Viewing Map",
           h3("Today's Viewing Map"),
           uiOutput("leaflet_map_viewing_today")
  ),
  tabPanel("Price Prediction",
           sidebarLayout(
             sidebarPanel(
               h3("Enter House Details"),
               numericInput("lon", "Longitude:", value = -2.105621720258337),
               numericInput("lat", "Latitude:", value = 57.16686874046701),
               numericInput("sqmt", "Square Meters:", value = 100),
               numericInput("rooms", "Number of Rooms:", value = 3),
               selectInput("type", "House Type:", choices = c("detached", "semi", "terrace"), selected = "detached"),
               numericInput("baths", "Number of Bathrooms:", value = 1),
               selectInput("epc", "EPC Rating:", choices = c("a", "b", "c", "d", "e", "f", "g"), selected = "c"),
               selectInput("tax", "Tax Band:", choices = c("a", "b", "c", "d", "e", "f", "g"), selected = "c"),
               numericInput("days_since", "Days Since 1st of July 2024:", value = 0),
               actionButton("predict", "Predict Price")
             ),
             mainPanel(
               h4("Prediction Results"),
               textOutput("prediction"),
               br(),
               p("The expected price represents the price the model predicts the house would be listed for, not sold for, and assumes the house is in 'average' condition, i.e. the house is of sufficient quality to allow the buyer to move in immediately with only minor updates or refurbishments required some time down the line.")
             )
           )
  ),
  tabPanel("Map Plot",
           h3("Map Plot"),
           div(class = "image-container",
               img(src = "plot_maps.png")
           )
  ),
  tabPanel("Figures Plot",
           h3("Figures Plot"),
           div(class = "image-container",
               img(src = "plot_figs.png")
           )
  )
))
