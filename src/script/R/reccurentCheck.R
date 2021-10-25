

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


# -- DT table UI
itemTable_UI <- function(id)
{
  
  # namespace
  ns <- NS(id)
  
  # table
  DTOutput(ns("itemTable"))
  
}


# -- Value box nb_obs
nbObs_UI <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # box
  uiOutput(ns("nb_obs"))
  
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
    
    # -- selected model (name and model)
    r$selectedModel <- reactiveVal(NULL)
    r$model <- reactiveVal(NULL)
    
    # -- load model list from folder
    r$models <- reactiveVal(read.csv(file.path(path$model, file$model_list), header = TRUE))
    
    # -- input data for prediction
    r$test_ds <- reactiveVal(NULL)
    r$test_labels <- reactiveVal(NULL)
    
    # -- predictions
    r$predictions <- reactiveVal(NULL)
    
    
    # -------------------------------------
    # Outputs
    # -------------------------------------
    
    # -- select input (model list)
    output$model_select <- renderUI(selectInput(ns("model"), "Select model", choices = r$models()$Name))
    
    # -- selected model name
    output$summary <- renderUI(
      wellPanel(r$selectedModel()))
    
    # -- Main table
    output$itemTable <- renderDT(r$test_ds(),
                                 options = list(lengthMenu = c(5, 1),
                                                pageLength = 5,
                                                dom = "lfrtip", #tp
                                                ordering = TRUE,
                                                searching = TRUE,
                                                scrollX = TRUE),
                                 rownames = FALSE,
                                 selection = 'single')
    
    # -- number of observations
    output$nb_obs <- renderValueBox(
      valueBox(dim(r$test_ds())[1], "Nb obs", width = 4)
    )
    
    
    
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
      
      # -- notify
      showNotification("Model loaded.")
      
      # -- store
      r$model(model)

    }, ignoreInit = TRUE, ignoreNULL = TRUE)
    
   
    # -- model
    observeEvent(r$model(), {
      
      cat("observeEvent: .h5 model file loaded. \n")
      
      # -- get preprocessed data file name
      file_name <- r$models()[r$models()$Name == r$selectedModel(), ]$Input
      
      # -- load data
      processed_df <- readProcessedData(path$processed, file_name)
      
      # -- split input and labels
      labels_df <- processed_df["RainTomorrow"]
      input_df <- processed_df[, !names(processed_df) %in% c("RainTomorrow")]
      
      # -- store
      r$test_ds(input_df)
      r$test_labels(labels_df)
      
      
    }, ignoreInit = TRUE, ignoreNULL = TRUE)
    
    
    # -- test_ds
    observeEvent(r$test_ds(), {
      
      cat("observeEvent: test dataset updated, computing predictions... \n")
      
      # -- get values
      model <- r$model()
      input_df <<- r$test_ds()
      
      # -- set paramaters
      batch_size = 32 #default
      verbose = 1
      
      # -- call prediction function
      raw_predictions <- makePrediction(model, input_df, batch_size = batch_size, verbose = verbose, steps = NULL, callbacks = NULL)
      raw_predictions <- as.data.frame(raw_predictions)
      colnames(raw_predictions) <- c("Raw.Prediction")
        
      # notify
      showNotification("Compute prediction done.")
      
      # -- store
      r$predictions(raw_predictions)
      
      
    }, ignoreInit = TRUE, ignoreNULL = TRUE)
    
    
    # -- predictions
    observeEvent(r$predictions(), {
      
      cat("observeEvent: test predictions updated, computing metrics... \n")
      
      # -- get values
      test_labels <- r$test_labels()
      predictions <- r$predictions()
      
      # -- merge
      df <- cbind(test_labels, predictions)
      
      # -- call evalution function
      eval <- evaluateModel(df)
      
      
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

