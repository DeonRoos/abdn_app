library(shiny)
library(leaflet)

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
               selectInput("type", "House Type:", choices = c("detached", "semi", "terrace"), selected = "detached"),
               numericInput("rooms", "Number of Rooms:", value = 5),
               numericInput("baths", "Number of Bathrooms:", value = 1),
               numericInput("sqmt", "Square Meters:", value = 103),
               selectInput("epc", "EPC Rating:", choices = c("a", "b", "c", "d", "e", "f", "g"), selected = "c"),
               selectInput("tax", "Tax Band:", choices = c("a", "b", "c", "d", "e", "f", "g"), selected = "e"),
               dateInput(
                 inputId = "date_selected",
                 label = "Select Date:",
                 value = Sys.Date(),  # Default value is the current date
                 min = "2024-07-06",  # Minimum date allowed
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
  # tabPanel("Viewing Map",
  #          h3("Viewing Map"),
  #          uiOutput("leaflet_map_viewing")
  # ),
  # tabPanel("Today's Viewing Map",
  #          h3("Today's Viewing Map"),
  #          uiOutput("leaflet_map_viewing_today")
  # ),
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
  # ,
  # tabPanel("Predicted relationships for house characterists",
  #          h3("The figures below assume average values for all characteristics not included in the focal plot (i.e. the house is average in all ways other than those varied in the figure)."),
  #          div(class = "image-container",
  #              img(src = "plot_figs.png")
  #          )
  # )
))
