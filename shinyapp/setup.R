

# ------------------------------------------------------------------------------
# Setup application environment
# ------------------------------------------------------------------------------

cat("------------------------------------------------\n")
cat("[SETUP] Init application environment \n")
cat("------------------------------------------------\n")

# -- Detect local run
is_local <- Sys.getenv('SHINY_PORT') == ""
cat("  - Local run =", is_local, "\n")

# -- Detect if code runs in shiny
is_shiny <- shiny::isRunning()
cat("  - Shiny =", is_shiny, "\n")

# -- Debug
DEBUG <- ifelse(is_local, TRUE, FALSE)
cat("  - DEBUG =", DEBUG, "\n")

# -- Load dependencies
cat("Loading package dependencies ... \n")
library(shiny)
library(shinydashboard)
library(shinyWidgets)

library(data.table)
library(DT)

library(stringr)

library(ggplot2)
library(PRROC)
library(leaflet)

library(keras)


# ------------------------------------------------------------------------------
# RETICULATE / PYTHON
# ------------------------------------------------------------------------------

# Local : do not fully load reticulate because it would search for python install
# and create conflicts since you can't switch to a different python afterward.
# use_condaenv instead, to set the target python env.
# Server : load full package, it will find the python install on shinyapps.io

cat("Init reticulate / python environment \n")

if(is_local){
  
  cat("  - Running local, init conda env \n")
  reticulate::use_condaenv("r-reticulate", required = TRUE)
  
} else {
  
  cat("  - Running server, loading full reticulate package \n")
  library(reticulate)
  
}

# ------------------------------------------------------------------------------

# -- Init config
source("config.R")

# -- Source code
cat("Source code from:", path$script, " \n")
for (nm in list.files(path$script, full.names = TRUE, recursive = TRUE, include.dirs = FALSE))
{
  cat("  - script :", nm, "\n")
  source(nm)
}
rm(nm)

