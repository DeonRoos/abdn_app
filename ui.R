library(shiny)
library(leaflet)
library(shinyjs)

shinyUI(navbarPage(
  title = "Granite Price Guide",
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
        width: 100%; /* Use full width */
        display: flex;
        justify-content: center;
        align-items: center;
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
  
  navbarMenu(title = tagList(icon("chart-bar"), " Property Insights"),
             tabPanel("Price Heatmaps", div(class = "image-container", img(src = "plot_maps.png", style = "width: 100%; height: auto;"))),
             tabPanel("Price Trends", div(class = "image-container", img(src = "trends.png", style = "width: 100%; height: auto;")))
  ),
  
  tabPanel(title = tagList(icon("chart-line"), " Price Prediction"),
           sidebarLayout(
             sidebarPanel(
               h3("Enter House Details"),
               h5(tagList(icon("map-marker-alt"), " Select House Location")),
               leafletOutput("map", height = "600px"),
               br(),
               actionButton("show_modal", tagList(icon("edit"), " Enter House Details")),
               actionButton("predict", tagList(icon("chart-line"), " Predict Price"), class = "btn", disabled = TRUE)
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
  tabPanel(title = tagList(icon("building"), " Houses"),
           uiOutput("leaflet_map_price")
  )
))
