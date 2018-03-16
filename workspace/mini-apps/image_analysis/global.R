

if(exists("xap.conn")) {
  home <- "~"
  datafile_path <- "datafiles/uploads/DICOM Images/"
} else {
  home <- workspace_path()
  datafile_path <- "datafiles/DICOM Images/"
}


writeTable <- function (df, tablename) {
  dbWriteTable(xap.conn, c(xap.db.sandbox, tablename), as.data.frame(df),
               row.names = F, overwrite = F,append=TRUE)
}
