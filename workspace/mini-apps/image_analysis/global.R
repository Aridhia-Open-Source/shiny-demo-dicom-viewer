
xap.require("oro.dicom", "oro.nifti", "RPostgreSQL", "purrr")


if(exists("xap.conn")) {
  home <- "~"
} else {
  home <- workspace_path()
}

datafile_path <- "datafiles/DICOM Images/"

writeTable <- function (df, tablename) {
  dbWriteTable(xap.conn, c(xap.db.sandbox, tablename), as.data.frame(df),
               row.names = F, overwrite = F, append = TRUE)
}

pth <- file.path(home, datafile_path)
dirs <- list.dirs(path = pth, full.names = FALSE, recursive = TRUE)
default_dicom <- dirs[2]
