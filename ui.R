####################
######## UI ########
####################


ui <- fluidPage(
  # Setting the app theme
  # theme = "theme.css",
  # Importing scripts
  includeScript("www/wheel.js"),
    tags$head(
      # More styling options
    tags$style(HTML("
      body{font-family: 'Oxygen'!important;}
      h5{border-bottom: 1px solid rgba(255,255,255,.5);
         color:#FFF;
         font-family: 'Oxygen';
         margin-bottom:10px;
         font-weight: bold;
         padding-bottom: 10px;
       }"
    ))
  ),
  tabsetPanel(
    # Tab Panel for the application --------------------
    tabPanel("DICOM Viewer", 
  fluidPage(
    # Left Column
    column(width = 2,
      # Choosing data
      h5("Select patient file"),
      verticalLayout(
        selectInput("fileInput", "", choices = dirs, selected = default_dicom)
      ),
      
      # Selecting view axis
      div(class = "sagittalScroll", sliderInput("slider_x", "X orientation", min = 1, max = 10, value = 5)),
      div(class = "coronalScroll", sliderInput("slider_y", "Y orientation", min = 1, max = 10, value = 5)),
      div(class = "axialScroll", sliderInput("slider_z", "Z orientation", min = 1, max = 10, value = 5))
           
    ),
    
    # Middle column - Image display
    column(width = 7,
      h5("Plane View"),
      # 3 tabs: Axial, Sagittal and Coronal
      tabsetPanel(type = "tabs", 
        tabPanel(
          "Axial", 
          div(
            class = "axialScroll",
            plotOutput("axial", height = "450px", brush = "plot_brush")
          )
        ), 
        tabPanel(
          "Sagittal",
          div(
            class = "sagittalScroll",
            plotOutput("sagittal", height = "450px", brush = "plot_brush")
          )
        ), 
        tabPanel(
          "Coronal",
          div(
            class = "coronalScroll",
            plotOutput("coronal", height = "450px", brush = "plot_brush")
          )
        )
      ),
      # Table output under the image
      tableOutput("table"),
      # Button to write to the database
      actionButton("writeDB", "Extract DICOM headers to database", icon("database"))
    ),
    
    # Right column
    column(width = 3,
      h5("Orthogonal Position"),
      plotOutput("distPlot", height = "350px", hover = "plot_hover", brush = "plot_brush")
    )
  )
    ),
  
  # Help tab -----------------------------------
  tabPanel("Help",
           documentation_tab()
  )
)
)
