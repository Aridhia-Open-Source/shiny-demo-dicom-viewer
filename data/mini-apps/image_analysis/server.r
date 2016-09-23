library(shiny)
library(oro.dicom)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  
  pth <- "~/datafiles/DICOM images/brainix/"
  dirs <- list.dirs(path = pth, full.names = FALSE, recursive = TRUE)
  feedback <- reactiveValues(text = "asdas")
  
  
  output$fileSelection <- renderUI({
    progress <- shiny::Progress$new()
    progress$set(message = "Locating file..", value = 0)
      Sys.sleep(1)
    on.exit(progress$close())
    verticalLayout(
      selectInput('fileInput', '', choices = dirs, selected = dirs[2])
    )
  })
  
  fName <- eventReactive(input$fileInput, {
    paste(pth, input$fileInput, sep="")
  })
  
  observe({
    val <- hk40n()
    d <- dim(val)
    progress <- shiny::Progress$new()
    progress$set(message = "Updating Position...", value = 0)
      Sys.sleep(1)
    on.exit(progress$close())
    
 
    
    # Control the value, min, max, and step.
    # Step size is 2 when input value is even; 1 when value is odd.
    updateSliderInput(session, "slider_x", value = as.integer(d[1]/2),max = d[1])
    updateSliderInput(session, "slider_y", value = as.integer(d[2]/2),max = d[2])
    updateSliderInput(session, "slider_z", value = as.integer(d[3]/2),max = d[3])
  })
  
  dcmImages <- reactive({

    progress <- shiny::Progress$new()
    
    progress$set(message = "Processing DICOM file...", value = 0)
      Sys.sleep(1)
    on.exit(progress$close())

    readDICOM(fName(),verbose = TRUE)
  })
  
  
  outTable <- reactive({
    progress <- shiny::Progress$new()
    progress$set(message = "Extracting information...", value = 0)
      Sys.sleep(1)
    on.exit(progress$close())
    hdr <- dcmImages()$hdr
    StudyID <- extractHeader(hdr, "StudyID", numeric=FALSE)
    StudyType <- as.character(extractHeader(hdr, "StudyDescription", numeric=FALSE))
    StudyDate <- extractHeader(hdr, "StudyDate", numeric=FALSE)
    Protocol <- extractHeader(hdr, "ProtocolName", numeric=FALSE)
    AcquisitionDate <- extractHeader(hdr, "AcquisitionDate", numeric=FALSE)
    Modality <- extractHeader(hdr, "Modality", numeric=FALSE)
    PatientsName <- extractHeader(hdr, "PatientsName", numeric=FALSE)
    PatientID <- extractHeader(hdr, "PatientID", numeric=FALSE)
    PatientDOB <- extractHeader(hdr, "PatientsBirthDate", numeric=FALSE)
    RequestedProcedure <- extractHeader(hdr, "RequestedProcedureID", numeric=FALSE)
    Findings <- rep('No findings', length(StudyID))
    df <- melt(data.frame(StudyID,
                          StudyType,
                          StudyDate,
                          Protocol,
                          AcquisitionDate,
                          Modality,
                          PatientsName,
                          PatientID,
                          PatientDOB,
                          RequestedProcedure,
                         Findings))
  })

  output$table <- renderTable({
    table <- outTable()
    table2 <- setNames(table, lapply(colnames(table), function(x) gsub("(.)([A-Z][a-z])|([a-z])([A-Z][A-Z])","\\1\\3 \\2\\4", x)))
    table2[1,]
  })
  
  hk40n <- reactive({
    validate(
      need(length(dcmImages()) >1,  "Please select a data set"))
    
    dicom2nifti(dcmImages())
  })
  
  d <- reactive({
    dim(hk40n())
    
  })
 
  output$distPlot <- renderPlot({

    img <- hk40n()
    out <- orthographic(img,
                        col.crosshairs="green",
                        xyz = c(input$slider_x,   input$slider_y, input$slider_z),
                        oma = rep(0, 4),
                        mar = rep(0.5, 4),
                        col = gray(0:64/64),
                        text = paste(
                          'StudyID: ',outTable()[1, ]$StudyID, '\n',
                          'Study Type: ', outTable()[1, ]$StudyType, '\n',
                          'Date: ',outTable()[1, ]$AcquisitionDate, '\n',
                          'Patient: ', outTable()[1, ]$PatientsName, '\n',
                        'PatientID: ', outTable()[1, ]$PatientID, '\n'),
    text.color = "white",
    text.cex = 1) # 

  })
  
  patientInfo <- reactive({
    pat_id <- 'Unspecified'
      pat_name <- 'Unspecified'
      study <- 'Unspecified'
     if (input$fileInput== 'SOUS - 702')
    {pat_id <- 'pat_001'
    pat_name <- 'Gandalf'
    study <- 'Brain MRI'
    }
    if (input$fileInput == 'sT2-TSE-T - 301'){
      pat_id <- 'pat_002'
      pat_name <- 'Aragorn'
      study <- 'Neck MRI'
    }
    if (input$fileInput == 'sT2W-FLAIR - 401'){
      pat_id <- 'pat_003'
      pat_name <- 'Legolas'
      study <- 'Pituitary MRI'
    }
    if (input$fileInput == 'T1-3D-FFE-C - 801'){
      pat_id <- 'pat_004'
      pat_name <- 'Gimli'
      study <- 'Thoratic-spine MRI'
    }
        if (input$fileInput == 'T1-SE-extrp - 601'){
      pat_id <- 'pat_005'
      pat_name <- 'Frodo'
      study <- 'Some-other MRI'
    }
        if (input$fileInput == 'T1-SE-extrp - 701'){
      pat_id <- 'pat_006'
      pat_name <- 'Bilbo'
      study <- 'Some-other MRI'
    }
      if (input$fileInput == 'T2W-FE-EPI - 501'){
      pat_id <- 'pat_007'
      pat_name <- 'Gollum'
      study <- 'Some-other MRI'
    }
    
    
    df <- data.frame(c(pat_id,pat_name,study), row.names = c('Patients ID: ','Name: ','Exam: '))
    colnames(df) <- NULL
    df
    
    
    })
  
  
 writeTable <- function (df, tablename)
{
    dbWriteTable(xap.conn, c(xap.db.sandbox, tablename), as.data.frame(df),
        row.names = F, overwrite = F,append=TRUE)
}
  
  btn <- reactive({
    
    })
  
  onoClick <- observeEvent(input$writeDB, {
    i <- input$writeDB
    if (i<1){
      return()
      }

    tableName <- 'image_analysis_findings'
    pat <- t(patientInfo())
    df <- outTable()[1,]
    
    output <- cbind(pat, df)
    
    
	writeTable(output, tableName)
    feedback$text <- paste("Dataframe written to database table", tableName)
	    progress <- shiny::Progress$new()
    progress$set(message = paste("Exporting to ", tableName, '...') , value = 0)
    Sys.sleep(5)
    on.exit(progress$close())
    })
  
  output$Axial <- renderPlot({
    try(image(hk40n(),  z = input$slider_z, plane="axial", plot.type = "single", col = gray(0:64/64)))
  })
  output$Sagittal <- renderPlot({
    try(image(hk40n(),  z = input$slider_x, plane="sagittal", plot.type = "single", col = gray(0:64/64)))
  })  
  
  output$Coronal <- renderPlot({
    try(image(hk40n(),  z = input$slider_y, plane="coronal", plot.type = "single", col = gray(0:64/64)))
  }) 
})