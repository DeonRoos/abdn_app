library(shiny)
library(leaflet)

shinyUI(navbarPage(
  title = "Aberdeen House Prices",
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
        border: 1px solid #00A68A !important;
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
      
          /* Custom Date Picker styles */
    .datepicker {
      background-color: #444654 !important;
      border: 1px solid #00A68A !important;
      color: white !important;
    }
    .datepicker table {
      background-color: #444654 !important;
      color: white !important;
    }
    .datepicker table tr td, .datepicker table tr th {
      background-color: #444654 !important;
      color: white !important;
    }
    .datepicker table tr td.day:hover, .datepicker table tr td.day.focused {
      background-color: #00A68A !important;
      color: #FFFFFF !important;
    }
    .datepicker table tr td.active, .datepicker table tr td.active:hover {
      background-color: #00A68A !important;
      color: #FFFFFF !important;
    }
    .datepicker table tr td.today {
      background-color: #00A68A !important;
      color: #FFFFFF !important;
      border-radius: 50%;
    }
    .datepicker table tr td.today:hover {
      background-color: #00A68A !important;
      color: #FFFFFF !important;
    }
    .datepicker table tr td.disabled, .datepicker table tr td.disabled:hover {
      background-color: #444654 !important;
      color: #777 !important;
    }
      ")
    )
  ),
  tabPanel("Price Prediction",
           sidebarLayout(
             sidebarPanel(
               h3("Enter House Details"),
               h5("Select House Location"),
               leafletOutput("map", height = "300px"),
               br(),
               selectInput("type", "House Type:", choices = c("Detached", "Semi-Detached", "Terraced", "Flat"), selected = "detached"),
               selectInput("UR8", "Urban desingation:", choices = c(
                 "Large Urban Areas", "Accessible Rural Areas", "Other Urban Areas",      
                 "Accessible Small Towns", "Remote Small Towns", "Remote Rural Areas", 
                 "Very Remote Rural Areas"
               ), selected = "Large Urban Areas"),
               selectInput("num_floors", "Numerb of Floors:", choices = c("1","2"), selected = "2"),
               numericInput("rooms", "Number of Rooms:", value = 5),
               numericInput("baths", "Number of Bathrooms:", value = 1),
               numericInput("sqmt", "Square Meters:", value = 103),
               selectInput("parking_type", "Parking:", choices = c("Garage", "Parking", "Double Garage", "No parking"), selected = "Garage"),
               selectInput("epc", "EPC Rating:", choices = c("A", "B", "C", "D", "E", "F", "G"), selected = "C"),
               selectInput("tax", "Tax Band:", choices = c("A", "B", "C", "D", "E", "F", "G"), selected = "D"),
               dateInput(
                 inputId = "date_selected",
                 label = "Select Date:",
                 value = Sys.Date(),  # Default value is the current date
                 min = "2024-09-27",  # Minimum date allowed
                 max = Sys.Date()     # Maximum date allowed (current date)
               ),
               actionButton("predict", "Predict Price")
             ),
             mainPanel(
               h4("Prediction Results"),
               htmlOutput("prediction"),
               br(),
               p("The expected price represents the price the model predicts the house would be listed for, not sold for, and assumes the house is in 'average' condition, i.e. the house is of sufficient quality to allow the buyer to move in immediately with only minor updates or refurbishments required some time down the line."),
               br(),
               uiOutput("prediction_details")
             )
           )
  ),
  tabPanel("Houses",
           uiOutput("leaflet_map_price")
  ),
  tabPanel("Aberdeenshire",
           h5("The maps below show the predicted house price for the average Aberdeenshire house. The average house is detached, has five rooms (three of which are bedrooms, two living rooms), one bathroom, 103 square meters, has EPC of C and tax grade of E"),
           div(class = "image-container",
               tags$style(HTML("
               .image-container {
                 width: 100%; /* Use full width */
                 display: flex;
                 justify-content: center;
                 align-items: center;
               }
             ")),
             img(src = "plot_maps.png")
           )
  )
))
