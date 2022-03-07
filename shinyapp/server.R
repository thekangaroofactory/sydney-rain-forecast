
# --------------------------------------------------------------------------------
# This is the server definition of the Shiny web application
# --------------------------------------------------------------------------------

# -- Library

library(shiny)
library(kpython)
library(reticulate)

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
    
    
    output$list_dir <- renderUI(
      HTML(paste0(list.dirs(input$my_input, recursive = F), collapse = '<br/>')))

    output$list_file <- renderUI(
      HTML(paste0(list.files(path = input$my_input, all.files = TRUE, include.dirs = FALSE), collapse = '<br/>')))
      
    # System path to python
    output$which_python <- renderText({
      paste0('Python path: ', Sys.which('python'))
    })
    
    # Python version
    output$python_version <- renderUI({
      rr = reticulate::py_discover_config(use_environment = 'python35_env')
      #paste0('Python version: ', rr$version)
      HTML(paste0(rr, collapse = '<br/>'))
    })
    
    
    #reticulate::use_virtualenv("r-reticulate", required = T)
    source_python("./src/script/Python/add.py", envir = globalenv())
    
    
    # -- call application modules
    map_Server("map")
    datasetManager_Server("model", r, path, file)
    analysisManager_Server("analyze", r)
    nanManager_Server("nan", r)
    reccurentCheck_Server("check", r)
    
    res <- k_poc_add(5,2)
    cat("Python call = ", res, "\n")
    showNotification(paste("Python call = ", res))
    
  }
)
