######################
####### GLOBAL #######
######################

# Load libraries
library(shiny)
library(oro.dicom)
library(oro.nifti)
library(DBI)
library(RPostgreSQL)
library(purrr)



# Source code
source("./code/help_tab.R")


# Path to images
datafile_path <- "data/dicom_images/"

# Writes to database (Only works on the workspace)
con <- dbConnect(RSQLite::SQLite(), ":memory:")
writeTable <- function(df, tablename) {
  dbWriteTable(con, tablename, as.data.frame(df),
               row.names = FALSE, overwrite = FALSE, append = TRUE)
}

# List all the directories at dicom_images folder
dirs <- list.dirs(path = datafile_path, full.names = FALSE, recursive = TRUE)
# Setting default directory
default_dicom <- dirs[2]
