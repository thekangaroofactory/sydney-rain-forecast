
# --------------------------------------------------------------------------------
# This is the server definition of the Shiny web application
# --------------------------------------------------------------------------------

# -- Library

library(shiny)
#library(kpython)

# -- Init env
source("./init_env.R")


# -- Source scripts
cat("Source code from:", path$script, " \n")
for (nm in list.files(path$script, full.names = TRUE, recursive = TRUE, include.dirs = FALSE))
{
  source(nm)
}
rm(nm)


# -- Define server logic

shinyServer(
  function(input, output){
    
    # *******************************************************************************************************
    # DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG
    # *******************************************************************************************************
    
    # source(file.path(path$script, "map.R"))
    # source(file.path(path$script, "dataset.R"))
    # source(file.path(path$script, "analyze.R"))
    # source(file.path(path$script, "missingValues.R"))
    # source(file.path(path$script, "reccurentCheck.R"))
    
    # *******************************************************************************************************
    # DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG
    # *******************************************************************************************************
    
    cat("------------------------------------------------\n")
    cat("[SERVER] Application server is being started... \n")
    cat("------------------------------------------------\n")
    
    
    # declare r communication object
    # ----------------------------------------------------------------------
    r <- reactiveValues()
    
    
    # -- get App version
    app_version <- getVersion()
    
    # -- ouput version info
    output$version_timestamp <- renderText({paste("Version:", app_version[[1]])})
    output$version_comment <- renderText(app_version[[2]])
    
    # -- call back-end modules
    #pythonConnector_Server("python", script_path =  path$python_script, dependencies = path$resource)
    
    # -- call application modules
    map_Server("map")
    datasetManager_Server("model", r, path, file)
    analysisManager_Server("analyze", r)
    nanManager_Server("nan", r)
    reccurentCheck_Server("check", r)
    
    #res <- k_poc_add(5,2)
    #cat("Python call = ", res, "\n")
    #showNotification(paste("Python call = ", res))
    
  }
)
