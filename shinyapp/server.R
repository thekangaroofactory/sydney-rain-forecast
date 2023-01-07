
# --------------------------------------------------------------------------------
# This is the server definition of the Shiny web application
# --------------------------------------------------------------------------------

# -- Define server logic
shinyServer(
  function(input, output){
    
    # *******************************************************************************************************
    # DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG
    # *******************************************************************************************************
    
    
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
    
    # -- call application modules
    map_Server("map")
    datasetManager_Server("model", r, path, file)
    analysisManager_Server("analyze", r)
    nanManager_Server("nan", r)
    reccurentCheck_Server("check", r)
    
    # -- dashboard
    weatherDashboard_Server("dashboard", r, path, file)
        
  }
)
