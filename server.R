
server <- function(input, output, session) {
  
  selected_file <- eventReactive(input$fileInput, {
    filename <- file.path(pth, input$fileInput)
    if(length(filename) == 0 || !dir.exists(filename) || is.na(filename)) {
      filename <- list.files(file.path(pth, default_dicom))
    }
    return(filename)
  })
  
  observe({
    val <- selected_nifti()
    d <- nifti_dim()
    # update sliders with the selected DICOM dimensions
    withProgress(message = "Updating Position...", value = 1, {
      updateSliderInput(session, "slider_x", value = as.integer(d[1]/2), max = d[1])
      updateSliderInput(session, "slider_y", value = as.integer(d[2]/2), max = d[2])
      updateSliderInput(session, "slider_z", value = as.integer(d[3]/2), max = d[3])
    })
  })
  
  dcm_images <- reactive({
    dicoms <- selected_file()
    
    withProgress(message = "Processing DICOM file...", {
      # Very similar to what readDICOM does. This allows updates to the progress bar as each file is read.
      filenames <- list.files(dicoms, full.names = TRUE)
      nfiles <- length(filenames)
      headers <- images <- vector("list", nfiles)
      names(images) <- names(headers) <- filenames
      for(i in 1:nfiles) {
        incProgress(1/nfiles)
        dcm <- readDICOMFile(filenames[i])
        images[[i]] <- dcm$img
        headers[[i]] <- dcm$hdr
      }
      return(list(hdr = headers, img = images))
    })
  })
  
  out_table <- reactive({
    withProgress(message = "Extracting information...", {
      hdr <- dcm_images()$hdr
      header_fields <- c("StudyID", "StudyDescription", "StudyDate", "ProtocolName",
                         "AcquisitionDate", "Modality", "PatientsName", "PatientID",
                         "PatientsBirthDate", "RequestedProcedureID")
      header_values <- map(header_fields, ~extractHeader(hdr, ..1, numeric = FALSE))
      df <- as.data.frame(header_values)
      names(df) <- header_fields
      df$Findings <- "No findings"
      return(df)
    })
  })

  output$table <- renderTable({
    table <- out_table()
    names(table) <- sapply(names(table), function(x) gsub("(.)([A-Z][a-z])|([a-z])([A-Z][A-Z])","\\1\\3 \\2\\4", x))
    table[1, ]
  })
  
  selected_nifti <- reactive({
    dicom2nifti(dcm_images())
  })
  
  nifti_dim <- reactive({
    dim(selected_nifti())
  })
 
  output$distPlot <- renderPlot({
    #withProgress(message = "Updating Orthongonal Positions...", value = 1, {
    img <- selected_nifti()
    x <- min(c(input$slider_x, nifti_dim()[1]))
    y <- min(c(input$slider_y, nifti_dim()[2]))
    z <- min(c(input$slider_z, nifti_dim()[3]))
    orthographic(
      img,
      col.crosshairs = "green",
      xyz = c(x, y, z),
      oma = rep(0, 4),
      mar = rep(0.5, 4),
      col = gray(0:64/64),
      text = paste(
        "StudyID: "   , out_table()[1, "StudyID"], "\n",
        "Study Type: ", out_table()[1, "StudyType"], "\n",
        "Date: "      , out_table()[1, "AcquisitionDate"], "\n",
        "Patient: "   , out_table()[1, "PatientsName"], "\n",
        "PatientID: " , out_table()[1, "PatientID"], "\n"
      ),
      text.color = "white",
      text.cex = 1,
      useRaster = TRUE
    )
  })
  
  patientInfo <- reactive({
    pat <- switch(input$fileInput,
      "SOUS - 702" = c("pat_001", "Gandalf", "Brain MRI"),
      "sT2-TSE-T - 301" = c("pat_002", "Aragorn", "Neck MRI"),
      "sT2W-FLAIR - 401" = c("pat_003", "Legolas", "Pituitary MRI"),
      "T1-3D-FFE-C - 801" = c("pat_004", "Gimli", "Thoratic-spine MRI"),
      "T1-SE-extrp - 601" = c("pat_005", "Frodo", "Some-other MRI"),
      "T1-SE-extrp - 701" = c("pat_006", "Bilbo", "Some-other MRI"),
      "T2W-FE-EPI - 501" = c("pat_007", "Gollum", "Some-other MRI"),
      c("Unspecified", "Unspecified", "Unspecified")
    )
    
    df <- data.frame(pat, row.names = c("Patients ID: ", "Name: ", "Exam: "))
    colnames(df) <- NULL
    return(df)
  })

  onoClick <- observeEvent(input$writeDB, {
    i <- input$writeDB
    if (i < 1){
      return()
    }

    tableName <- "image_analysis_findings"
    pat <- t(patientInfo())
    df <- out_table()[1, ]
    
    output <- cbind(pat, df)
    
    withProgress(message = paste("Exporting to ", tableName, "..."), {
      writeTable(output, tableName)
      #feedback$text <- paste("Dataframe written to database table", tableName)
    })
  })
  
  output$axial <- renderPlot({
    #withProgress(message = "Updating Axial Image...", value = 1, {
      image(selected_nifti(), z = input$slider_z, plane = "axial",
            plot.type = "single", col = gray(0:64/64), useRaster = TRUE)
    #})
  })
  
  output$sagittal <- renderPlot({
      image(selected_nifti(), z = input$slider_x, plane = "sagittal",
            plot.type = "single", col = gray(0:64/64), useRaster = TRUE)
  })  
  
  output$coronal <- renderPlot({
      image(selected_nifti(), z = input$slider_y, plane = "coronal",
            plot.type = "single", col = gray(0:64/64), useRaster = TRUE)
  })
  
  # 
  observe({
    n <- input$axialn
    if(is.null(input$axialn)) {
      return()
    }
    change <- sign(input$axialdy)
    isolate(updateSliderInput(session, "slider_z", value = input$slider_z + change))
  })

  observe({
    n <- input$sagittaln
    if(is.null(input$sagittaln)) {
      return()
    }
    change <- sign(input$sagittaldy)
    isolate(updateSliderInput(session, "slider_x", value = input$slider_x + change))
  })

  observe({
    n <- input$coronaln
    if(is.null(input$coronaln)) {
      return()
    }
    change <- sign(input$coronaldy)
    isolate(updateSliderInput(session, "slider_y", value = input$slider_y + change))
  })

}
