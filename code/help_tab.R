documentation_tab <- function() {
  tabPanel("Help",
           fluidPage(width = 12,
                     fluidRow(column(
                       6,
                       h3("DICOM VIEWER"), 
                       p("The Digital Imaging and Communications in Medicine or DICOM is the standard for the communication and managment of medical
                         imaging information and related data."),
                       p("The sample images displaying the app are results from Magnetic Resonances of the brain. 
                         The source of this data is", tags$a("Osirix", href = "https://www.osirix-viewer.com/resources/dicom-image-library/"), ", from a library called BRAINIX."),
                       h4("Adding your images"),
                       p("To use other DICOM images in the app, you can place sets of DICOM images 
                         inside the folder called 'dicom_images' within the 'data' folder in the parent directory" ),
                       h4("Using the App"),
                       p("You can select the patient file to display from the drop-down menu on the left. Then you can change the Orientation of the 
                         image being displayed using the sliders"),
                       p("In the middle of the screen the image will be displayed. You can change the plane view by clicking on 'Axial', 'Sagittal' or 
                         'Coronal' tabs just above the image. Under the image a table with the file information is printed."),
                       p("On the left-side of the screen, you can see the Orthogonal Position in the three axis at the same time."),
                       br()
                     ),
                     column(
                       6,
                       h3("Walkthrough video"),
                       tags$video(src="dicom-viewer.mp4", type = "video/mp4", width="100%", height = "350", frameborder = "0", controls = NA),
                       p(class = "nb", "NB: This mini-app is for provided for demonstration purposes, is unsupported and is utilised at user's 
                       risk. If you plan to use this mini-app to inform your study, please review the code and ensure you are 
                       comfortable with the calculations made before proceeding. ")
                       
                     ))
                     
                     
                     
                     
           ))
}