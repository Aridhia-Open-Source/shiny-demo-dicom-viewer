
library(shiny)
library(oro.dicom)
library(oro.nifti)
library(DBI)
library(RPostgreSQL)
library(purrr)

source("config.R")

datafile_path <- "data/dicom_images/"

writeTable <- function(df, tablename) {
  dbWriteTable(con, tablename, as.data.frame(df),
               row.names = FALSE, overwrite = FALSE, append = TRUE)
}

pth <- datafile_path
dirs <- list.dirs(path = pth, full.names = FALSE, recursive = TRUE)
default_dicom <- dirs[2]
