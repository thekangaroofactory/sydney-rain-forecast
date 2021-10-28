

# --------------------------------------------------------------------------------
# Shiny module: Reccurent check
# --------------------------------------------------------------------------------

# -- Library
library(data.table)
library(pROC)


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


# -- Table section --------------------

# -- DT table UI
itemTable_UI <- function(id)
{
  
  # namespace
  ns <- NS(id)
  
  # table
  DTOutput(ns("itemTable"))
  
}


# -- ValueBox section --------------------

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

# -- Value box AUC
auc_UI <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # box
  uiOutput(ns("auc"))
  
}


# -- Plot section --------------------

# -- Confusion matrix plot
confusionPlot_UI <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # plot
  plotOutput (ns("confusion_plot"))
  
}


# -- ROC curve plot
rocPlot_UI <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # plot
  plotOutput (ns("roc_plot"))
  
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
# getROC_btn <- function(id)
# {
#   # namespace
#   ns <- NS(id)
# 
#   # button
#   actionButton(ns("roc_btn"), label = "ROC Curve")
# 
# }


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
    
    # -- AUC (Area Under the ROC Curve)
    auc <- reactiveVal(NULL)
    
    # -- plots
    p_confusion <- reactiveVal(NULL)
    p_roc <- reactiveVal(NULL)
    
    
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
      valueBox(dim(r$test_ds())[1], "Nb obs", width = 4, color = "purple")
    )
    
    # -- number of predictions OK
    output$predictions_ok <- renderValueBox(
      valueBox(r$monitoring()$Predictions.OK, "Predictions OK", width = 4, color = "purple")
    )
    
    # -- number of predictions KO
    output$predictions_ko <- renderValueBox(
      valueBox(r$monitoring()$Predictions.KO, "Predictions KO", width = 4, color = "purple")
    )
    
    # -- accuracy
    output$accuracy <- renderValueBox(
      valueBox(r$monitoring()$Accuracy, "Accuracy", width = 4, color = "purple")
    )
    
    # -- precision
    output$precision <- renderValueBox(
      valueBox(r$monitoring()$Precision, "Precision", width = 4, color = "purple")
    )
    
    # -- recall
    output$recall <- renderValueBox(
      valueBox(r$monitoring()$Recall, "Recall", width = 4, color = "purple")
    )
    
    # -- F1 score
    output$f1_score <- renderValueBox(
      valueBox(r$monitoring()$F1.Score, "F1 Score", width = 4, color = "purple")
    )
    
    # -- AUC value
    output$auc <- renderValueBox(
      valueBox(auc(), "AUC", width = 4, color = "purple")
    )
    
    
    # -- Plot section --------------------
    
    # -- confusion matrix plot
    output$confusion_plot <- renderPlot(p_confusion())
    
    # -- ROC curve plot
    output$roc_plot <- renderPlot(p_roc())
    
    
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
      #showNotification("Model loaded.")
      
      # -- update progress
      progress$inc(1/4, detail = "Load model: done")
      
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
      
      # -- update progress
      progress$inc(2/4, detail = "Load data: done")
      
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
      #showNotification("Compute prediction done.")
      # -- update progress
      progress$inc(3/4, detail = "Compute predictions: done")
      
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
      
      # -- store
      p_confusion(p)
      
    }, ignoreInit = TRUE, ignoreNULL = TRUE)
      
    
    # -- test_ds
    observeEvent(r$predictions(), {
      
      # log
      cat("Computing ROC curve & AUC... \n")
      
      # -- get values
      test_labels <- r$test_labels()
      predictions <- r$predictions()
      
      # -- merge
      to_eval_df <- cbind(test_labels, predictions)
      
      # -- eval along threshold sequence
      eval_list <- lapply(seq(0, 1, by = 0.025), function(x) evaluateModel(to_eval_df, x))
      eval_df <- rbindlist(eval_list)
      
      # -- reorder (to avoid geom_line to plot in wrong direction)
      eval_df <- eval_df[with(eval_df, order(FP.Rate, TP.Rate)), ]
      
      # -- get ROC curve plot
      p <- getROCPlot(eval_df)
      
      # -- get AUC value (explicit call to package to avoid conflict)
      area_under_ROC <- pROC::auc(to_eval_df$RainTomorrow, to_eval_df$Raw.Prediction, levels=c(0, 1), direction = '<')
      area_under_ROC <- round(area_under_ROC, digits = 3)
      
      # -- update progress
      progress$inc(4/4, detail = "Evaluate model: done")
      
      # -- store
      p_roc(p)
      auc(area_under_ROC)
      
      
    }, ignoreInit = TRUE, ignoreNULL = TRUE)
    
    
    # --------------------------------------------------------------------------
    # Observer inputs
    # --------------------------------------------------------------------------
    
    # -- SelectInput: select model
    observeEvent(input$model, {

      # log
      cat("Selected model = ", input$model, "\n")
      
      # Create a Progress object
      progress <- shiny::Progress$new()
      # Make sure it closes when we exit this reactive, even if there's an error
      #on.exit(progress$close())
      # Init
      progress$set(message = "Loading model...", value = 0)
      
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
    
    
    
    # --------------------------------------------------------------------------
    
  })
}

