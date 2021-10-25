

evaluateModel <- function(df, threshold = 0.5){
  
  # -- add binary prediction column
  df$Binary.Prediction <- ifelse(df$Raw.Prediction < threshold, 0, 1)
  
  # -- add match column
  df$match <- df$Binary.Prediction == df$RainTomorrow
  
  # -- count obs
  observations <- dim(df)[[1]]
  
  # -- predictions ok/ko
  prediction_ok <- sum(df$match)
  prediction_ko <- observations - prediction_ok
  
  # -- accuracy
  accuracy <- round(prediction_ok / observations * 100, digits = 2)
  
  # -- confusion matrix
  true_positive <- sum((df$Binary.Prediction == 1) & (df$RainTomorrow == 1))
  false_positive <- sum((df$Binary.Prediction == 1) & (df$RainTomorrow == 0))
  true_negative <- sum((df$Binary.Prediction == 0) & (df$RainTomorrow == 0))
  false_negative <- sum((df$Binary.Prediction == 0) & (df$RainTomorrow == 1))
  
  # -- precision / recall
  precision <- round(true_positive / (true_positive + false_positive), digits = 2)
  recall <- round(true_positive / (true_positive + false_negative), digits = 2)
  
  # -- F1 Score
  f1_score <- 2 * (recall * precision) / (recall + precision)
  
  # -- print summary to console
  
  cat("Evaluation Summary: \n")
  cat("- Observations: ", observations, "\n")
  cat("- Predictions OK: ", prediction_ok, "\n")
  cat("- Predictions KO: ", prediction_ko, "\n")
  cat("- Accuracy: ", accuracy, "\n")
  cat("- True Positive: ", true_positive, "\n")
  cat("- False Positive: ", false_positive, "\n")
  cat("- True Negative: ", true_negative, "\n")
  cat("- False Negative: ", false_negative, "\n")
  cat("- Precision: ", precision, "\n")
  cat("- Recall: ", recall, "\n")
  cat("- F1 Score: ", f1_score, "\n")

  
}