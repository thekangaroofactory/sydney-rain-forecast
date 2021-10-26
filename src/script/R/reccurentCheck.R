

# --------------------------------------------------------------------------------
# Shiny module: Reccurent check
# --------------------------------------------------------------------------------

# -- Library
library(data.table)

# --------------------------------------------------------------------------------
# UI ITEMS SECTION
# --------------------------------------------------------------------------------

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

# -- Value box Predictions_OK
nbPredictionOK_UI <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # box
  uiOutput(ns("predictions_ok"))
  
}

# -- Value box Predictions_KO
nbPredictionKO_UI <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # box
  uiOutput(ns("predictions_ko"))
  
}

# -- Value box Accuracy
accuracy_UI <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # box
  uiOutput(ns("accuracy"))
  
}

# -- Value box Precision
precision_UI <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # box
  uiOutput(ns("precision"))
  
}

# -- Value box recall
recall_UI <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # box
  uiOutput(ns("recall"))
  
}

# -- Value box F1 Score
f1Score_UI <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # box
  uiOutput(ns("f1_score"))
  
}


# -- Confusion matrix plot
confusionPlot_UI <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # plot
  plotOutput (ns("confusion_plot"))
  
}


# --------------------------------------------------------------------------------
# INPUT ITEMS SECTION
# --------------------------------------------------------------------------------

# -- Select model input
selectModel_INPUT <- function(id)
{
  
  # namespace
  ns <- NS(id)
  
  # text
  uiOutput(ns("model_select"))
  
}


# -- Threshold slider input
thresholdSlider_INPUT <- function(id)
{
  
  # namespace
  ns <- NS(id)
  
  # text
  uiOutput(ns("thresholdSlider"))
  
}


# --------------------------------------------------------------------------------
# BUTTON ITEMS SECTION
# --------------------------------------------------------------------------------

# -- ROC button
getROC_btn <- function(id)
{
  # namespace
  ns <- NS(id)

  # button
  actionButton(ns("roc_btn"), label = "ROC Curve")

}


# --------------------------------------------------------------------------------
# Server logic
# --------------------------------------------------------------------------------

reccurentCheck_Server <- function(id, r) {
  moduleServer(id, function(input, output, session) {
    
    # get namespace
    ns <- session$ns
    
    # -- default threshold
    r$threshold <- reactiveVal(NULL)
    
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
    
    # -- monitoring
    r$monitoring <- reactiveVal(NULL)
    
    # -- plots
    p_confusion <- reactiveVal(NULL)
    
    
    # -------------------------------------
    # Outputs
    # -------------------------------------
    
    # -- select input (model list)
    output$model_select <- renderUI(selectInput(ns("model"), "Select model", choices = r$models()$Name))
    
    # -- select threshold input (slider)
    output$thresholdSlider <- renderUI(sliderInput(ns("thresholdSlider"), h3("Threshold"), 
                                                   min = 0, max = 1, value = 0.5))
    
    
    # -- selected model name
    output$summary <- renderUI(tagList(
      h3(r$selectedModel()),
      p("Description:"),
      p(r$models()[r$models()$Name == r$selectedModel(), ]$Description),
      p("Version:"),
      p(r$models()[r$models()$Name == r$selectedModel(), ]$Version)))
    
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
    
    # -- ValueBox section --------------------
    
    # -- number of observations
    output$nb_obs <- renderValueBox(
      valueBox(dim(r$test_ds())[1], "Nb obs", width = 4, color = "light-blue")
    )
    
    # -- number of predictions OK
    output$predictions_ok <- renderValueBox(
      valueBox(r$monitoring()$Predictions.OK, "Predictions OK", width = 4, color = "light-blue")
    )
    
    # -- number of predictions KO
    output$predictions_ko <- renderValueBox(
      valueBox(r$monitoring()$Predictions.KO, "Predictions KO", width = 4, color = "light-blue")
    )
    
    # -- accuracy
    output$accuracy <- renderValueBox(
      valueBox(r$monitoring()$Accuracy, "Accuracy", width = 4, color = "light-blue")
    )
    
    # -- precision
    output$precision <- renderValueBox(
      valueBox(r$monitoring()$Precision, "Precision", width = 4, color = "light-blue")
    )
    
    # -- recall
    output$recall <- renderValueBox(
      valueBox(r$monitoring()$Recall, "Recall", width = 4, color = "light-blue")
    )
    
    # -- F1 score
    output$f1_score <- renderValueBox(
      valueBox(r$monitoring()$F1.Score, "F1 Score", width = 4, color = "light-blue")
    )
    
    
    # -- Plot section --------------------
    
    # -- confusion matrix plot
    output$confusion_plot <- renderPlot(p_confusion())
    
    
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
      input_df <- r$test_ds()
      
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
    observeEvent({
      r$predictions()
      r$threshold()}, {
        
        # ** otherwise it's called when prediction is NULL (idk...)
        req(r$predictions(), r$threshold())
        
        cat("observeEvent: predictions or threshold updated, computing metrics... \n")
        
        # -- get values
        test_labels <- r$test_labels()
        predictions <- r$predictions()
        
        # -- merge
        df <- cbind(test_labels, predictions)
        
        # -- call evalution function
        eval <- evaluateModel(df, r$threshold(), verbose = TRUE)
        
        # -- store
        r$monitoring(eval)
        
        
      }, ignoreInit = TRUE, ignoreNULL = TRUE)
    
    
    # -- test_ds
    observeEvent(r$monitoring(), {
      
      # get plot
      p <- getConfusionPlot(obs = r$monitoring()$Observations,
                            tp = r$monitoring()$True.Positive,
                            fp = r$monitoring()$False.Positive,
                            fn = r$monitoring()$False.Negative,
                            tn = r$monitoring()$True.Negative)
      
      # -- strore
      p_confusion(p)
      
    }, ignoreInit = TRUE, ignoreNULL = TRUE)
    
    
    # --------------------------------------------------------------------------
    # Observer inputs
    # --------------------------------------------------------------------------
    
    # -- SelectInput: select model
    observeEvent(input$model, {

      # log
      cat("Selected model = ", input$model, "\n")
      
      # store value
      r$selectedModel(input$model)

    })
    
    
    # -- SliderInput: thresholdSlider
    observeEvent(input$thresholdSlider, {
      
      # log
      cat("Threshold = ", input$thresholdSlider, "\n")
      
      # store value
      r$threshold(input$thresholdSlider)
      
    })
    
    
    # --------------------------------------------------------------------------
    # Observer buttons
    # --------------------------------------------------------------------------
    
    # -- button: ROC Curve
    observeEvent(input$roc_btn, {
      
      # log
      cat("Computing ROC curve... \n")
      
      # -- get values
      test_labels <- r$test_labels()
      predictions <- r$predictions()
      
      # -- merge
      df <- cbind(test_labels, predictions)
      
      # -- eval along threshold sequence
      eval_list <- lapply(seq(0, 1, by = 0.05), function(x) evaluateModel(df, x))
      eval_df <<- rbindlist(eval_list)

    })
    
    
    # --------------------------------------------------------------------------
    
  })
}

