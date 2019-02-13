

shinyUI(fluidPage(
  theme = "theme.css",
  includeScript("www/wheel.js"),
    tags$head(
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
  # Application title      
  fluidRow(
    column(width = 2,
      h5("Select patient file"),
      verticalLayout(
        selectInput("fileInput", "", choices = dirs, selected = default_dicom)
      ),
      div(class = "sagittalScroll", sliderInput("slider_x", "X orientation", min = 1, max = 10, value = 5)),
      div(class = "coronalScroll", sliderInput("slider_y", "Y orientation", min = 1, max = 10, value = 5)),
      div(class = "axialScroll", sliderInput("slider_z", "Z orientation", min = 1, max = 10, value = 5))
           
    ),
    column(width = 7,
      h5("Plane View"),
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
      tableOutput("table"),
      actionButton("writeDB", "Extract DICOM headers to database", icon("database"))
    ),
    column(width = 3,
      h5("Orthogonal Position"),
      plotOutput("distPlot", height = "350px", hover = "plot_hover", brush = "plot_brush")
    )
  )
)
)
