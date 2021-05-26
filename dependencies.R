#######################
##### DEPENDECIES #####
#######################


# Packages needed to run the app
packages <- c("oro.dicom", "oro.nifti", "DBI", "RPostgreSQL", "purr", "shiny", "RPSLite")


# Install packages if not already installed
package_install <- function(x){
  
  for (i in x){
    # Check if the package is installed
    if (!require(i, character.only = TRUE)){
      install.packages(i)
    }
  }
  
}


package_install(packages)