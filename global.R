
library(shiny)
library(oro.dicom)
library(oro.nifti)
library(RPostgreSQL)
library(purrr)

datafile_path <- "data/dicom_images/"

writeTable <- function(df, tablename) {
  dbWriteTable(xap.conn, c(xap.db.sandbox, tablename), as.data.frame(df),
               row.names = F, overwrite = F, append = TRUE)
}

pth <- datafile_path
dirs <- list.dirs(path = pth, full.names = FALSE, recursive = TRUE)
default_dicom <- dirs[2]
