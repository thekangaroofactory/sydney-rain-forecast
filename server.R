
# --------------------------------------------------------------------------------
# This is the server definition of the Shiny web application
# --------------------------------------------------------------------------------

# -- Library

library(shiny)

# -- Init env
source("./init_env.R")


# -- Source scripts

cat("Source code... \n")
for (nm in list.files(path$script, full.names = TRUE, recursive = TRUE, include.dirs = FALSE))
{
    cat("Loading source: ", nm, "\n")
    source(nm)
}
rm(nm)


# -- Define server logic

shinyServer(
    function(input, output){
        
        # *******************************************************************************************************
        # DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG
        # *******************************************************************************************************
        
        source(file.path(path$script, "map.R"))
        source(file.path(path$script, "dataset.R"))
        source(file.path(path$script, "analyze.R"))
        source(file.path(path$script, "missingValues.R"))
        source(file.path(path$script, "reccurentCheck.R"))
        
        # *******************************************************************************************************
        # DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG
        # *******************************************************************************************************
        
        # declare r communication object
        # ----------------------------------------------------------------------
        # - models: list of models
        # - selectedModel: active model
        
        r <- reactiveValues()
        
        
        # -- declare modules
        map_Server("map")
        datasetManager_Server("model", r, path, file)
        analysisManager_Server("analyze", r)
        nanManager_Server("nan", r)
        
        reccurentCheck_Server("check", r)
        
    }
)
