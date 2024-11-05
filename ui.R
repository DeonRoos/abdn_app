library(shiny)
library(leaflet)
library(shinyjs)

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

      /* Navbar hover and active styles */
      .navbar .nav > li > a:hover,
      .navbar .nav > li > a:focus {
        background-color: #00A68A;
        color: #FFFFFF !important;
        border: 2px solid #00A68A;
        box-shadow: 0 0 10px 5px rgba(0, 166, 138, 0.3);
      }
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

      /* Modal styles */
      .modal-content {
        background-color: #202123 !important;
        color: white !important;
        border: 1px solid #00A68A !important;
      }
      .modal-header, .modal-footer {
        background-color: #444654 !important;
        color: white !important;
        border-top: 1px solid #00A68A;
      }
      .modal-title {
        color: #00A68A !important;
        font-weight: bold;
      }
      .modal-body {
        color: white !important;
      }
      .modal-footer .btn {
        background-color: #00A68A;
        color: #FFFFFF !important;
        border: 1px solid #00A68A;
      }
      ")
    )
  ),
  useShinyjs(),  # Enable shinyjs
  tabPanel("Price Prediction",
           sidebarLayout(
             sidebarPanel(
               h3("Enter House Details"),
               h5("Select House Location"),
               leafletOutput("map", height = "600px"),
               br(),
               actionButton("show_modal", "Enter House Details"),
               actionButton("predict", "Predict Price", class = "btn", disabled = TRUE)  # Start disabled
             ),
             mainPanel(
               h4("Prediction Results"),
               htmlOutput("prediction"),
               br(),
               p("The expected price represents the price the model predicts the house would be listed for."),
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
  ),
  
  # Modal for entering house details
  tags$div(
    id = "houseDetailsModal",
    class = "modal fade",
    tabindex = "-1",
    role = "dialog",
    tags$div(
      class = "modal-dialog",
      role = "document",
      tags$div(
        class = "modal-content",
        tags$div(
          class = "modal-header",
          tags$button(type = "button", class = "close", `data-dismiss` = "modal", "×"),
          tags$h4(class = "modal-title", "Enter House Details")
        ),
        tags$div(
          class = "modal-body",
          p("Please provide details about the house. These inputs allow the model to make an accurate prediction based on the house's features and location."),
          selectInput("houseType", "House Type", choices = c("Detached", "Semi-Detached", "Terraced")),
          numericInput("floorArea", "Floor Area (sq m)", value = 100),
          # Add other relevant inputs here
        ),
        tags$div(
          class = "modal-footer",
          actionButton("modalSave", "Save", class = "btn btn-primary"),
          tags$button(type = "button", class = "btn btn-default", `data-dismiss` = "modal", "Close")
        )
      )
    )
  )
))
