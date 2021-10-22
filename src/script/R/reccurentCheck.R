

# --------------------------------------------------------------------------------
# Shiny module: Reccurent check
# --------------------------------------------------------------------------------

# -- Library


# --------------------------------------------------------------------------------
# UI ITEMS SECTION
# --------------------------------------------------------------------------------

# -- Select model input
selectModel_INPUT <- function(id)
{

  # namespace
  ns <- NS(id)

  # text
  uiOutput(ns("model_select"))
  
}


# -- Summary
summary_UI <- function(id)
{

  # namespace
  ns <- NS(id)

  # box
  uiOutput(ns("summary"))

}


# --------------------------------------------------------------------------------
# BUTTON ITEMS SECTION
# --------------------------------------------------------------------------------

# -- Drop rows button
# dropRows_btn <- function(id)
# {
#   # namespace
#   ns <- NS(id)
#   
#   # button
#   actionButton(ns("dropRows"), label = "Drop rows")
#   
# }


# --------------------------------------------------------------------------------
# Server logic
# --------------------------------------------------------------------------------

reccurentCheck_Server <- function(id, r) {
  moduleServer(id, function(input, output, session) {
    
    # get namespace
    ns <- session$ns
    
    # -- declare
    r$selectedModel <- reactiveVal(NULL)
    r$model <- reactiveVal(NULL)
    
    # -- load model list from folder
    r$models <- reactiveVal(read.csv(file.path(path$model, file$model_list), header = TRUE))
    
    
    # -------------------------------------
    # Outputs
    # -------------------------------------
    
    output$model_select <- renderUI(selectInput(ns("model"), "Select model", choices = r$models()$Name))
    
    
    # --------------------------------------------------------------------------
    # Observer values
    # --------------------------------------------------------------------------

    # -- selectedModel
    observeEvent(r$selectedModel(), {

      cat("observeEvent: selectedModel updated \n")

      # -- prepare
      path <- path$model
      file <- r$models()[r$models()$Name == r$selectedModel(), ]$File
      
      # -- load model
      model <- loadTFmodel(path, file)
      
      # notify
      showNotification("Model loaded.")
      
      # -- store
      r$model(model)

    }, ignoreInit = TRUE, ignoreNULL = TRUE)
    
   
    # -- model
    observeEvent(r$model(), {
      
      output$summary <- renderUI(
        wellPanel(summary(r$model()))
      )
      
    }, ignoreInit = TRUE, ignoreNULL = TRUE)
    
    
    # --------------------------------------------------------------------------
    # Observer buttons
    # --------------------------------------------------------------------------
    
    # -- Button: select model
    observeEvent(input$model, {

      # log
      cat("Selected model = ", input$model, "\n")
      
      # store value
      r$selectedModel(input$model)

    })
    
    
    # --------------------------------------------------------------------------
    
  })
}

