
xap.require('oro.dicom', 'oro.nifti', 'reshape2', 'RPostgreSQL')

shinyUI(fluidPage(
  theme = "theme.css",
    tags$head(
    tags$style(HTML("      
body{font-family: 'Oxygen'!important;}
h5{border-bottom: 1px solid rgba(255,255,255,.5); color:#FFF; font-family: 'Oxygen'; margin-bottom:10px; font-weight: bold; padding-bottom: 10px;}
    "))
  ),
  # Application title      
  fluidRow(
    column(width = 2,
           h5('Select patient file'),
           uiOutput('fileSelection'),
           sliderInput('slider_x', 'X orientation', min=1, max=10, value=5),
           sliderInput('slider_y', 'Y orientation', min=1, max=10, value=5),
           sliderInput('slider_z', 'Z orientation', min=1, max=10, value=5)
           
    ),
    column(width = 7,
           h5('Plane View'),
           tabsetPanel(type = "tabs", 
                       tabPanel("Axial", plotOutput("Axial", height = "450px",   brush = "plot_brush")), 
                       tabPanel("Sagittal", plotOutput("Sagittal", height = "450px",   brush = "plot_brush")), 
                       tabPanel("Coronal", plotOutput("Coronal", height = "450px",   brush = "plot_brush"))
           ),
           tableOutput('table'),
           actionButton('writeDB', 'Extract DICOM headers to database', icon("database"))
    ),
    
    column(width = 3,
           
           h5('Orthogonal Position'),
           plotOutput('distPlot', height = "350px",    hover = "plot_hover",brush = "plot_brush")
    )

  )
)
)