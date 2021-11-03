

# --------------------------------------------------------------------------------
# Shiny module: Reccurent check
# --------------------------------------------------------------------------------

# -- Library
library(data.table)
library(pROC)
library(PRROC)
library(shinyWidgets)


# --------------------------------------------------------------------------------
# UI ITEMS SECTION
# --------------------------------------------------------------------------------

# -- Summary
summary_UI <- function(id){

  # namespace
  ns <- NS(id)

  # box
  uiOutput(ns("summary"))

}


# -- Table section --------------------

# -- DT table UI
itemTable_UI <- function(id){
  
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

# -- Value box AUC ROC
auc_roc_UI <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # box
  uiOutput(ns("auc_roc"))
  
}

# -- Value box AUC PR
auc_pr_UI <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # box
  uiOutput(ns("auc_pr"))
  
}


# -- Plot section --------------------

# -- Confusion matrix plot
confusionPlot_UI <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # plot
  plotOutput(ns("confusion_plot"), width = "500px", height = "400px")
  
}

# -- ROC curve plot
rocPlot_UI <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # plot
  plotOutput(ns("roc_plot"), width = "400px", height = "400px")
  
}

# -- PR curve plot
prPlot_UI <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # plot
  plotOutput(ns("pr_plot"), width = "400px", height = "400px")
  
}


# --------------------------------------------------------------------------------
# INPUT ITEMS SECTION
# --------------------------------------------------------------------------------

# -- Select model input
selectModel_INPUT <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # text
  uiOutput(ns("model_select"))
  
}

# -- Threshold slider input
thresholdSlider_INPUT <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # text
  uiOutput(ns("thresholdSlider"))
  
}

# -- Date range input
dateRange_INPUT <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # text
  uiOutput(ns("date_range"))
  
}


# --------------------------------------------------------------------------------
# BUTTON ITEMS SECTION
# --------------------------------------------------------------------------------


# --------------------------------------------------------------------------------
# Server logic
# --------------------------------------------------------------------------------

reccurentCheck_Server <- function(id, r) {
  moduleServer(id, function(input, output, session) {
    
    # get namespace
    ns <- session$ns
    
    # -- ProgressBar
    trigger_progress <- reactiveVal(-1)
    trigger_nb_steps <- reactiveVal(0)
    trigger_title <- reactiveVal(NULL)
    
    # -- selected model (name and model)
    r$selectedModel <- reactiveVal(NULL)
    r$model <- reactiveVal(NULL)
    
    # -- load model list from folder
    r$models <- reactiveVal(read.csv(file.path(path$model, file$model_list), header = TRUE))
    
    # -- input data for prediction
    r$test_ds <- reactiveVal(NULL)
    r$test_labels <- reactiveVal(NULL)
    
    # -- subset index data (date range)
    subset_index <- reactiveVal(NULL)
    
    # -- formated data (to retireve dates)
    formated_ds <- reactiveVal(NULL)
    
    # -- predictions
    r$predictions <- reactiveVal(NULL)
    
    # -- monitoring
    r$monitoring <- reactiveVal(NULL)
    
    # -- AUC (Area Under Curves)
    auc_roc <- reactiveVal(NULL)
    auc_pr <- reactiveVal(NULL)
    
    # -- plots
    p_confusion <- reactiveVal(NULL)
    p_roc <- reactiveVal(NULL)
    p_pr <- reactiveVal(NULL)
    
    
    # -- load formated dataset (to get dates)
    formated_df <- read.csv(file.path(path$formated, file$formated), header = TRUE)
    formated_df$Date <- as.Date(formated_df$Date, format = "%Y-%m-%d")
    
    # -- store
    formated_ds(formated_df)
    
    # -- get min max date range
    date_min <- min(formated_df$Date)
    date_max <- max(formated_df$Date)
    
    
    # -------------------------------------
    # Outputs
    # -------------------------------------
    
    # -- INPUT section --------------------
    
    # -- select input (model list)
    output$model_select <- renderUI(selectInput(ns("model"), "Select model", choices = r$models()$Name))
    
    # -- select threshold input (slider)
    output$thresholdSlider <- renderUI(sliderInput(ns("thresholdSlider"), h3("Threshold"), 
                                                   min = 0, max = 1, value = 0.5))
    
    # -- select date range input
    output$date_range <- renderUI(dateRangeInput(ns("date_range"), label = "Select date", start = date_min, end = date_max, min = date_min, max = date_max))
    
    # -- UI section --------------------
    
    # -- selected model name
    output$summary <- renderUI(tagList(
      p("Name:", r$selectedModel()),
      p("Description:"),
      p(r$models()[r$models()$Name == r$selectedModel(), ]$Description),
      p("Version:", r$models()[r$models()$Name == r$selectedModel(), ]$Version)))
      
    
    # -- Main table
    output$itemTable <- renderDT(formated_ds(),
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
    
    # -- AUC ROC value
    output$auc_roc <- renderValueBox(
      valueBox(auc_roc(), "AUC", width = 4, color = "purple")
    )
    
    # -- AUC PR value
    output$auc_pr <- renderValueBox(
      valueBox(auc_pr(), "AUC", width = 4, color = "purple")
    )
    
    
    # -- Plot section --------------------
    
    # -- confusion matrix plot
    output$confusion_plot <- renderPlot(p_confusion())
    
    # -- ROC curve plot
    output$roc_plot <- renderPlot(p_roc())
    
    # -- PR curve plot
    output$pr_plot <- renderPlot(p_pr())
    
    
    # --------------------------------------------------------------------------
    # Observer values
    # --------------------------------------------------------------------------

    # -- selectedModel
    observeEvent(r$selectedModel(), {

      cat("observeEvent: selectedModel updated \n")

      # -- update progress
      trigger_title("Loading ML model...")
      trigger_progress(trigger_progress() + 1)
      
      # -- prepare
      path <- path$model
      file <- r$models()[r$models()$Name == r$selectedModel(), ]$File
      
      # -- load model
      model <- loadTFmodel(path, file)
      
      # -- notify
      #showNotification("Model loaded.")
      
      # -- store
      r$model(model)

    }, ignoreInit = TRUE, ignoreNULL = TRUE)
    
   
    # -- model
    observeEvent(r$model(), {
      
      cat("observeEvent: .h5 model file loaded. \n")
      
      # -- update progress
      trigger_title("Loading test data...")
      trigger_progress(trigger_progress() + 1)
      
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
    
    
    # -- input$date_range
    observeEvent(input$date_range, {
      
      cat("Date Range min =", as.Date(input$date_range[[1]]), "\n")
      cat("Date Range max =", as.Date(input$date_range[[2]]), "\n")
      
      # -- get indexes matching date range
      index <- formated_ds()$Date >= input$date_range[[1]] & formated_ds()$Date <= input$date_range[[2]]
      cat("Selected rows = ", sum(index), "\n")
      
      # -- subset and store
      subset_index(index)
      
    }, ignoreInit = TRUE, ignoreNULL = TRUE)
    
    
    # -- test_ds
    observeEvent(r$test_ds(), {
      
      cat("observeEvent: test dataset updated, computing predictions... \n")
      
      # -- update progress
      trigger_title("Computing predictions...")
      trigger_progress(trigger_progress() + 1)
      
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
      
      # -- store
      r$predictions(raw_predictions)
      
      
      # -- update progress
      trigger_title("Computing ROC & AUC...")
      trigger_progress(trigger_progress() + 1)
      
      
    }, ignoreInit = TRUE, ignoreNULL = TRUE)
    
    
    # -- predictions
    observeEvent({
      r$predictions()
      input$thresholdSlider
      subset_index()
      auc_roc()}, {
        
        # ** otherwise it's called when prediction is NULL (idk...)
        # ** adding auc_roc() as a trigger to for progress order
        req(r$predictions(), input$thresholdSlider, auc_roc())
        
        cat("observeEvent: updating metrics... \n")
        
        # -- update progress
        if(trigger_progress() != -1){
          trigger_title("Computing metrics...")
          trigger_progress(trigger_progress() + 1)
        }
        
        # -- get values
        test_labels <- r$test_labels()[subset_index(), ]
        str(test_labels)
        predictions <- r$predictions()[subset_index(), ]
        str(predictions)
        
        # -- merge
        df <- cbind(test_labels, predictions)
        str(df)
        
        # -- call evalution function
        eval <- evaluateModel(df, input$thresholdSlider, verbose = TRUE)
        
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
      
      # -- update progress
      if(trigger_progress() != -1){
        trigger_progress(trigger_progress() + 1)
      }
      
      
    }, ignoreInit = TRUE, ignoreNULL = TRUE)
      
    
    # -- predictions
    observeEvent(r$predictions(), {
      
      # --log
      cat("Computing evaluation... \n")
      
      # -- get values
      test_labels <- r$test_labels()
      predictions <- r$predictions()
      
      # -- merge
      to_eval_df <- cbind(test_labels, predictions)
      
      # -- eval along threshold sequence
      eval_list <- lapply(seq(0, 1, by = 0.025), function(x) evaluateModel(to_eval_df, x))
      eval_df <- rbindlist(eval_list)
      
      # ---- 1. ROC & AUC
      # -- reorder (to avoid geom_line to plot in wrong direction)
      eval_df <- eval_df[with(eval_df, order(FP.Rate, TP.Rate)), ]
      
      # -- get ROC curve plot
      p1 <- getROCPlot(eval_df)
      
      # -- get AUC value (explicit call to package to avoid conflict)
      area_under_ROC <- pROC::auc(to_eval_df$RainTomorrow, to_eval_df$Raw.Prediction, levels=c(0, 1), direction = '<')
      
      # ROC Curve    
      # roc <- roc.curve(scores.class0 = fg, scores.class1 = bg, curve = T)
      
      # -- store
      p_roc(p1)
      auc_roc(round(area_under_ROC, digits = 3))
      
      # --log
      cat("ROC curve & AUC done. \n")
      
      # ---- 2. Precision/Recall & AUC
      
      # -- get Precision/Recall curve plot
      p2 <- getPrecRecallPlot(eval_df)
      
      # -- get AUC value
      fg <- to_eval_df[to_eval_df$RainTomorrow == 1, ]$Raw.Prediction
      bg <- to_eval_df[to_eval_df$RainTomorrow == 0, ]$Raw.Prediction
      
      # -- compute AUC PR
      pr <- pr.curve(scores.class0 = fg, scores.class1 = bg, curve = F)
      
      # -- store
      p_pr(p2)
      auc_pr(round(pr$auc.integral, digits = 3))
      
      
    }, ignoreInit = TRUE, ignoreNULL = TRUE)
    
    
    # --------------------------------------------------------------------------
    # Observer inputs
    # --------------------------------------------------------------------------
    
    # -- SelectInput: select model
    observeEvent(input$model, {

      # log
      cat("Selected model = ", input$model, "\n")
      
      # Create a Progress object
      trigger_progress(0)
      trigger_nb_steps(6)

      # store value
      r$selectedModel(input$model)

    })
    
    
    # --------------------------------------------------------------------------
    # Observer buttons
    # --------------------------------------------------------------------------
    
    
    
    # --------------------------------------------------------------------------
    # ProgressBar 
    # --------------------------------------------------------------------------
    
    observeEvent(trigger_progress(), {
      
      # -- log
      cat("Trigger_progress =", trigger_progress(), "\n")
      cat("Trigger_title =", trigger_title(), "\n")
      
      
      # *** DEBUG ******************************************************* 
      #
      #Sys.sleep(1)
      #
      # *** DEBUG ******************************************************* 
      
      
      # -- check progress trigger
      if(trigger_progress() == 0){
        
        # -- set progress bar
        progressSweetAlert(id = "progress", session = session, value = 0, total = trigger_nb_steps(), display_pct = TRUE, striped = TRUE, title = "Initializing TensorFlow...")
        
      } else {
        
        # -- update progress
        updateProgressBar(session, "progress", value = trigger_progress(), total = trigger_nb_steps(), title = trigger_title())
      }
      
      # -- check final step
      if(trigger_progress() == trigger_nb_steps()){
        closeSweetAlert(session)
        trigger_progress(-1)
        trigger_nb_steps(0)
        trigger_title(NULL)
      }
      
    }, ignoreInit = TRUE)
    
    # --------------------------------------------------------------------------
    
  })
}

