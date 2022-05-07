

# ------------------------------------------------------------------------------
# Shiny module: Reccurent check
# ------------------------------------------------------------------------------

# -- Library
library(data.table)
library(PRROC)
library(shinyWidgets)
library(keras)

# ------------------------------------------------------------------------------
# UI ITEMS SECTION
# ------------------------------------------------------------------------------

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

# -- Value box nb_select_obs
nbSelectedObs_UI <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # box
  uiOutput(ns("nb_select_obs"))
  
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

# -- Prediction density plot
predictionDensityPlot_UI <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # plot
  plotOutput(ns("prediction_density_plot"), width = "400px", height = "400px")
  
}

# -- Accuracy density plot
accuracyDensityPlot_UI <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # plot
  plotOutput(ns("accuracy_density_plot"), width = "400px", height = "400px")
  
}

# -- TP density plot
TPDensityPlot_UI <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # plot
  plotOutput(ns("TP_density_plot"), width = "400px", height = "400px")
  
}

# -- FP density plot
FPDensityPlot_UI <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # plot
  plotOutput(ns("FP_density_plot"), width = "400px", height = "400px")
  
}

# -- TN density plot
TNDensityPlot_UI <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # plot
  plotOutput(ns("TN_density_plot"), width = "400px", height = "400px")
  
}

# -- FN density plot
FNDensityPlot_UI <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # plot
  plotOutput(ns("FN_density_plot"), width = "400px", height = "400px")
  
}

# -- Rain prediction density plot
RainPredictionDensityPlot_UI <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # plot
  plotOutput(ns("rain_prediction_density_plot"), width = "400px", height = "400px")
  
}

# -- No rain prediction density plot
NoRainPredictionDensityPlot_UI <- function(id){
  
  # namespace
  ns <- NS(id)
  
  # plot
  plotOutput(ns("norain_prediction_density_plot"), width = "400px", height = "400px")
  
}


# ------------------------------------------------------------------------------
# INPUT ITEMS SECTION
# ------------------------------------------------------------------------------

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


# ------------------------------------------------------------------------------
# BUTTON ITEMS SECTION
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Server logic
# ------------------------------------------------------------------------------

reccurentCheck_Server <- function(id, r) {
  moduleServer(id, function(input, output, session) {
    
    cat("Starting reccurentCheck server... \n")
    
    # -- get namespace
    ns <- session$ns
    
    # --------------------------------------------------------------------------
    # Declare objects
    # --------------------------------------------------------------------------
    
    # -- ProgressBar triggers
    trigger_progress <- reactiveVal(-1)
    trigger_nb_steps <- reactiveVal(0)
    pb_debug = FALSE #debug add 1s sleep!
    
    # -- Loaded model (.h5 format)
    tf_model <- reactiveVal(NULL)
    
    # -- Model list
    model_list <- reactiveVal()
    
    # -- input data for prediction
    test_ds <- reactiveVal(NULL)
    test_labels <- reactiveVal(NULL)
    
    # -- subset index data (date range)
    subset_index_list <- reactiveVal(NULL)
    
    # -- formatted data (to retrieve dates)
    formated_ds <- reactiveVal(NULL)
    
    # -- predictions
    predictions <- reactiveVal(NULL)
    
    # -- monitoring
    monitoring <- reactiveVal(NULL)
    monitoring_plots <- reactiveVal(NULL)
    
    # -- AUC values (Area Under Curves)
    auc_roc <- reactiveVal(NULL)
    auc_pr <- reactiveVal(NULL)
    
    # -- plots
    p_confusion <- reactiveVal(NULL)
    p_roc <- reactiveVal(NULL)
    p_pr <- reactiveVal(NULL)
    
    # -- date range
    date_min <- NULL
    date_max <- NULL
    
    # -- default threshold values
    default_threshold <- list("Model_m1" = 0.28,
                              "Model_m2" = 0.60)
    
    
    # --------------------------------------------------------------------------
    # Code to be run once
    # --------------------------------------------------------------------------
    
    # -- load model list from folder & store
    list <- read.csv(file.path(path$model, file$model_list), header = TRUE)
    cat("Model list loaded, size =", dim(list)[1], "\n")
    model_list(list)
    
    # -- load pre-formatted dataset & store
    formated_df <- read.csv(file.path(path$formated, file$formated), header = TRUE)
    formated_df$Date <- as.Date(formated_df$Date, format = "%Y-%m-%d")
    cat("Test dataset loaded, size =", dim(formated_df), "\n")
    formated_ds(formated_df)
    
    # -- get min & max date range
    date_min <- min(formated_df$Date)
    date_max <- max(formated_df$Date)
    
    
    # --------------------------------------------------------------------------
    # OUPUTS SECTION
    # --------------------------------------------------------------------------
    
    # -- INPUT widgets --------------------
    
    # -- select input (model list)
    output$model_select <- renderUI(selectInput(ns("selected_model"), h3("Select model"), choices = model_list()$Name))
    
    # -- select threshold input (slider)
    output$thresholdSlider <- renderUI(sliderInput(ns("thresholdSlider"), label = h3("Threshold"), 
                                                   min = 0, max = 1, value = default_threshold[[input$selected_model]]))
    
    # -- select date range input
    output$date_range <- renderUI(dateRangeInput(ns("date_range"), label = h3("Date range"), 
                                                 start = date_min, end = date_max, min = date_min, max = date_max))
    
    
    # -- Text & Table --------------------
    
    # -- selected model name
    output$summary <- renderUI(tagList(
      p("Name:", input$selected_model),
      p("Version:", model_list()[model_list()$Name == input$selected_model, ]$Version),
      p("Description:"),
      p(model_list()[model_list()$Name == input$selected_model, ]$Description)))
      
    
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
    
    # -- ValueBox objects --------------------
    
    # -- number of observations
    output$nb_obs <- renderValueBox(
      valueBox(dim(test_ds())[1], "Nb obs", width = 4, color = "purple")
    )
    
    # -- number of selected observations
    output$nb_select_obs <- renderValueBox(
      valueBox(sum(subset_index_list()), "Nb selected obs", width = 4, color = "purple")
    )
    
    # -- number of predictions OK
    output$predictions_ok <- renderValueBox(
      valueBox(monitoring()$Predictions.OK, "Predictions OK", width = 4, color = "purple")
    )
    
    # -- number of predictions KO
    output$predictions_ko <- renderValueBox(
      valueBox(monitoring()$Predictions.KO, "Predictions KO", width = 4, color = "purple")
    )
    
    # -- accuracy
    output$accuracy <- renderValueBox(
      valueBox(monitoring()$Accuracy, "Accuracy", width = 4, color = "purple")
    )
    
    # -- precision
    output$precision <- renderValueBox(
      valueBox(monitoring()$Precision, "Precision", width = 4, color = "purple")
    )
    
    # -- recall
    output$recall <- renderValueBox(
      valueBox(monitoring()$Recall, "Recall", width = 4, color = "purple")
    )
    
    # -- F1 score
    output$f1_score <- renderValueBox(
      valueBox(monitoring()$F1.Score, "F1 Score", width = 4, color = "purple")
    )
    
    # -- AUC ROC value
    output$auc_roc <- renderValueBox(
      valueBox(auc_roc(), "AUC", width = 4, color = "purple")
    )
    
    # -- AUC PR value
    output$auc_pr <- renderValueBox(
      valueBox(auc_pr(), "AUC", width = 4, color = "purple")
    )
    
    
    # -- Plot objects --------------------
    
    # -- confusion matrix plot
    output$confusion_plot <- renderPlot(p_confusion())
    
    # -- ROC curve plot
    output$roc_plot <- renderPlot(p_roc())
    
    # -- PR curve plot
    output$pr_plot <- renderPlot(p_pr())
    
    # -- Plots accross prediction range
    output$prediction_density_plot <- renderPlot(monitoring_plots()[1])
    output$accuracy_density_plot <- renderPlot(monitoring_plots()[2])
    output$TP_density_plot <- renderPlot(monitoring_plots()[3])
    output$FP_density_plot <- renderPlot(monitoring_plots()[4])
    output$TN_density_plot <- renderPlot(monitoring_plots()[5])
    output$FN_density_plot <- renderPlot(monitoring_plots()[6])
    output$rain_prediction_density_plot <- renderPlot(monitoring_plots()[7])
    output$norain_prediction_density_plot <- renderPlot(monitoring_plots()[8])
    
    
    # --------------------------------------------------------------------------
    # OBSERVERS SECTION
    # --------------------------------------------------------------------------

    # --------------------------------------------------------------------------
    # Input Observers
    # --------------------------------------------------------------------------
    
    # -- Observe selectInput: selected_model
    observeEvent(input$selected_model, {

      cat("[observeEvent] New selected_model input value =", input$selected_model, "\n")
      
      # -- init progressBar
      setProgress(value = 0, total = 6, title = "Loading TensorFlow model...")

      # -- get model file name
      model_file <- model_list()[model_list()$Name == input$selected_model, ]$File
      
      # -- load model & store
      cat("  - Load TF model from file \n")
      model <- loadTFmodel(path$model, model_file)
      tf_model(model)


      # -- update progressBar
      updateProgress(title = "Loading pre-processed data...", debug = pb_debug)
      
      # -- get pre-processed data file name
      data_file <- model_list()[model_list()$Name == input$selected_model, ]$Input
      
      # -- load data
      cat("  - Read pre-processed dataset from file \n")
      processed_df <- readProcessedData(path$processed, data_file)
      
      # -- split input and labels
      labels_df <- processed_df["RainTomorrow"]
      input_df <- processed_df[, !names(processed_df) %in% c("RainTomorrow")]
      
      # -- store
      test_ds(input_df)
      test_labels(labels_df)
      
      
    }, ignoreInit = TRUE, ignoreNULL = TRUE)
    
    
    # -- Observe dateRangeInput: date_range
    observeEvent(input$date_range, {
      
      cat("[observeEvent] New date_range input value =", input$date_range, "\n")
      
      # -- get indexes matching date range
      index <- formated_ds()$Date >= input$date_range[[1]] & formated_ds()$Date <= input$date_range[[2]]
      cat("  - Selected rows = ", sum(index), "\n")
      
      # -- store
      subset_index_list(index)
      
    }, ignoreInit = TRUE, ignoreNULL = TRUE)
    
    
    # --------------------------------------------------------------------------
    # Observer buttons
    # --------------------------------------------------------------------------
    
    
    # --------------------------------------------------------------------------
    # reactiveVal Observers
    # --------------------------------------------------------------------------
    
    # -- Observe reactiveVal: test_ds (tf_model and test_ds are updated in same bloc, hence following last one)
    observeEvent(test_ds(), {
      
      cat("[observeEvent] Model & test dataset updated \n")
      
      # -- update progressBar
      updateProgress(title = "Making predictions...", debug = pb_debug)
      
      # -- get values
      model <- tf_model()
      input_df <- test_ds()
      
      # -- set parameters
      batch_size = 32 #default
      verbose = 1
      
      # -- make predictions
      cat("  - Compute predictions \n")
      raw_predictions <- makePrediction(model, input_df, batch_size = batch_size, verbose = verbose, steps = NULL, callbacks = NULL)
      raw_predictions <- as.data.frame(raw_predictions)
      colnames(raw_predictions) <- c("Raw.Prediction")
      
      # -- store
      predictions(raw_predictions)
      
    }, ignoreInit = TRUE, ignoreNULL = TRUE)
      
    
    # -- Observe reactiveVal: predictions
    observeEvent(predictions(), {
      
      cat("[observeEvent] New predictions available \n")
      
      # -- update progressBar
      updateProgress(title = "Evaluating model...", debug = pb_debug)
      
      # -- get values
      test_labels <- test_labels()
      predictions <- predictions()
      
      
      # *********************************************
      # BS for yearly check -- to be removvvvveeeeeeeeedddddddddddddd !!!
      
      # debug__predictions <<- predictions
      
      # *********************************************
      
      # -- merge
      to_eval_df <- cbind(test_labels, predictions)
      
      # -- eval along threshold sequence
      cat("  - Evaluating model along threshold sequence... \n")
      eval_list <- lapply(seq(0, 1, by = 0.025), function(x) evaluateModel(to_eval_df, x))
      eval_df <- rbindlist(eval_list)
      
      # ---- 1. ROC & AUC
      
      # -- update progressBar
      updateProgress(title = "Building ROC Curve...", debug = pb_debug)
      
      # -- reorder (to avoid geom_line to plot in wrong direction)
      eval_df <- eval_df[with(eval_df, order(FP.Rate, TP.Rate)), ]
      
      # -- get ROC curve plot
      cat("  - Make ROC Curve plot \n")
      p1 <- getROCPlot(eval_df)
    
      # -- prepare for AUC
      fg <- to_eval_df[to_eval_df$RainTomorrow == 1, ]$Raw.Prediction
      bg <- to_eval_df[to_eval_df$RainTomorrow == 0, ]$Raw.Prediction
        
      # AUC ROC Curve    
      cat("  - Compute AUC ROC Curve value \n")
      roc <- roc.curve(scores.class0 = fg, scores.class1 = bg, curve = FALSE)
      
      # -- store
      p_roc(p1)
      auc_roc(round(roc$auc, digits = 3))
      
      
      # ---- 2. Precision/Recall & AUC
      
      # -- update progressBar
      updateProgress(title = "Building PR Curve...", debug = pb_debug)
      
      # -- get Precision/Recall curve plot
      cat("  - Make PR Curve plot \n")
      p2 <- getPrecRecallPlot(eval_df)
      
      # -- compute AUC PR
      cat("  - Compute AUC PR Curve value \n")
      pr <- pr.curve(scores.class0 = fg, scores.class1 = bg, curve = FALSE)
      
      # -- store
      p_pr(p2)
      auc_pr(round(pr$auc.integral, digits = 3))
      
      
      # -- update progressBar (and close)
      updateProgress(title = "Evaluation done.", debug = pb_debug)
      
      
    }, ignoreInit = TRUE, ignoreNULL = TRUE)
    
    
    # -- Observe reactiveVal: predictions, subset_index_list and input: thresholdSlider
    observeEvent({
      predictions()
      input$thresholdSlider
      subset_index_list()
      }, {
        
        # ** otherwise it's called when prediction is NULL (idk...)
        req(predictions(), input$thresholdSlider, subset_index_list())
        
        cat("[observeEvent] Need to update metrics... \n")
        
        # -- get values
        test_labels <- test_labels()
        predictions <- predictions()
        
        # -- merge
        df_to_eval <- cbind(test_labels, predictions)
        
        # -- subset give subset_index_list
        df_to_eval <- df_to_eval[subset_index_list(), ]
        
        # **********************************************************************
        # -- DEBUG
        
        DEBUG_df_to_eval <<- df_to_eval
        
        # **********************************************************************
        
        
        # -- call distribution plot function
        cat("  - Build predictions distribution plots \n")
        dist_plots <- getDistributionPlots(stats_df = df_to_eval, threshold = input$thresholdSlider, break_by = 0.05)
        
        # -- store
        monitoring_plots(dist_plots)
        
        # -- call evaluation function
        cat("  - Evaluate selected predictions \n")
        eval <- evaluateModel(df_to_eval, input$thresholdSlider, verbose = TRUE)
        
        # -- store
        monitoring(eval)
        
        # get plot
        cat("  - Make confusion matrix plot \n")
        p <- getConfusionPlot(obs = monitoring()$Observations,
                              tp = monitoring()$True.Positive,
                              fp = monitoring()$False.Positive,
                              fn = monitoring()$False.Negative,
                              tn = monitoring()$True.Negative)
        
        # -- store
        p_confusion(p)
        
        
      }, ignoreInit = TRUE, ignoreNULL = TRUE)
    
 
    # --------------------------------------------------------------------------
    # ProgressBar component
    # --------------------------------------------------------------------------
    
    # -- Helper function: set progress bar
    setProgress <- function(value = 0, total = 0, title = ""){
      
      # -- log
      cat("[setProgress] =", value, "/", total, "\n")

      # -- store values
      trigger_progress(value)
      trigger_nb_steps(total)
      
      # -- set progress bar
      progressSweetAlert(id = "progress", session = session, value = value, total = total, display_pct = TRUE, striped = TRUE, title = title)
      
    }
    
    
    # -- Helper function: update progress bar
    updateProgress <- function(title = "", debug = FALSE){
      
      # *** DEBUG ******************************************************* 
      if(debug){
        
        cat("[WARNING] updateProgress DEBUG mode ON -- sleep 1s !!! \n")
        Sys.sleep(1)
        
      }
      # *** DEBUG ******************************************************* 
     
      # -- update trigger
      trigger_progress(trigger_progress() + 1)
      
      # -- log
      cat("[updateProgress] =", trigger_progress(), "/", trigger_nb_steps(), "\n")
      
      # -- update progress
      updateProgressBar(session, "progress", value = trigger_progress(), total = trigger_nb_steps(), title = title)
      
      # -- check final step
      if(trigger_progress() == trigger_nb_steps()){
        cat("[updateProgress] Final step reached, close dialog. \n")
        closeSweetAlert(session)
        trigger_progress(-1)
        trigger_nb_steps(0)
      }
      
    }
    
    # --------------------------------------------------------------------------
    
  })
}

