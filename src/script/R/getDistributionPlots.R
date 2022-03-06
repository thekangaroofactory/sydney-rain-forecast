

# -- Library
library(dplyr)
library(ggplot2)


getDistributionPlots <- function(stats_df = NULL, threshold = 0.5, break_by = 0.05){
  
  # convert real prediction probability into binary values
  stats_df$BinaryPrediction <- ifelse(stats_df$Raw.Prediction >= threshold, 1, 0)
  
  # add column if prediction is good
  stats_df$Accurate <- ifelse(stats_df$RainTomorrow == stats_df$BinaryPrediction,1,0)
  
  # compare predictions with labels
  stats_df$TruePositive <- ifelse((stats_df$BinaryPrediction == 1) & (stats_df$RainTomorrow == 1),1,0)
  stats_df$FalsePositive <- ifelse((stats_df$BinaryPrediction == 1) & (stats_df$RainTomorrow == 0),1,0)
  stats_df$TrueNegative <- ifelse((stats_df$BinaryPrediction == 0) & (stats_df$RainTomorrow == 0),1,0)
  stats_df$FalseNegative <- ifelse((stats_df$BinaryPrediction == 0) & (stats_df$RainTomorrow == 1),1,0)
  
  
  # ------------------------------------------------ 
  # - Prepare df by slice
  # ------------------------------------------------ 
  # set up cut-off values 
  breaks <- seq(0,1, by = break_by)
  
  # bucket
  stats_df$Range <- cut(stats_df$Raw.Prediction, breaks=breaks)
  
  # count
  stats_by_group = stats_df %>% 
    group_by(Range) %>% 
    summarise(Count = n(),
              PredictionOK = sum(Accurate),
              Accuracy = sum(Accurate)/n()*100,
              TruePositive = sum(TruePositive)/n()*100,
              FalsePositive = sum(FalsePositive)/n()*100,
              TrueNegative = sum(TrueNegative)/n()*100,
              FalseNegative = sum(FalseNegative)/n()*100
    )
  
  
  # ------------------------------------------------ 
  # - Compute accuracy
  # ------------------------------------------------
  
  # number of prediction / ok
  nb_prediction <- dim(stats_df)[1]
  nb_prediction_ok <- sum(stats_df$Accurate)

  # accuracy
  accuracy <- nb_prediction_ok / nb_prediction * 100
  
  
  # ------------------------------------------------ 
  # - Define plots
  # ------------------------------------------------ 
  
  # Plot.1: distribution of Prediction
  p1 <- ggplot(stats_df, aes(x=Raw.Prediction)) +
    geom_density(alpha=0.4, fill="#E69F00", size=1) +
    geom_vline(aes(xintercept=median(Raw.Prediction)), color="grey", linetype="dashed", size=1) +
    geom_rug()
  
  
  # Plot.2: accuracy by prediction slice
  p2 <- ggplot(stats_by_group
               , aes(x = Range, y = Accuracy, size = Count, group = 1)) +
    geom_ribbon(aes(ymin = 0, ymax = Accuracy), fill = "#E69F00", col = "black", alpha = 0.5, size = 1) +
    geom_point() +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
    geom_hline(yintercept = accuracy, colour = "#999999", linetype = "dashed")
  
  
  # Plot.3: true positive by prediction slice
  p3 <- ggplot(stats_by_group
               , aes(x = Range, y = TruePositive, group = 1)) +
    geom_point() +
    geom_ribbon(aes(ymin = 0, ymax = TruePositive), fill = "#E69F00", col = "black", alpha = 0.5, size = 1) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))
  
  
  # Plot.4: false positive by prediction slice
  p4 <- ggplot(stats_by_group
               , aes(x = Range, y = FalsePositive, group = 1)) +
    geom_point() +
    geom_ribbon(aes(ymin = 0, ymax = FalsePositive), fill = "#E69F00", col = "black", alpha = 0.5, size = 1) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
    ylim(0, 100)
  
  
  # Plot.5: true negative by prediction slice
  p5  <- ggplot(stats_by_group
                , aes(x = Range, y = TrueNegative, group = 1)) +
    geom_point() +
    geom_ribbon(aes(ymin = 0, ymax = TrueNegative), fill = "#E69F00", col = "black", alpha = 0.5, size = 1) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))
  
  
  # Plot.6: false negative by prediction slice
  p6  <- ggplot(stats_by_group
                , aes(x = Range, y = FalseNegative, group = 1)) +
    geom_point() +
    geom_ribbon(aes(ymin = 0, ymax = FalseNegative), fill = "#E69F00", col = "black", alpha = 0.5, size = 1) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
    ylim(0, 100)
  
  
  # Plot.7: ability to predict days without rain
  p7 <- ggplot(stats_df[stats_df$RainTomorrow == 0,], aes( x = Raw.Prediction)) +
    geom_density(alpha = 0.4, fill = "#E69F00", size = 1) +
    geom_vline(aes(xintercept = median(Raw.Prediction)), color = "grey", linetype = "dashed", size=1) +
    geom_rug() +
    xlab("Predictions for days without rain")
  
  
  # Plot.8: ability to predict days with rain
  p8 <- ggplot(stats_df[stats_df$RainTomorrow == 1,], aes( x = Raw.Prediction)) +
    geom_density(alpha = 0.4, fill = "#E69F00", size = 1) +
    geom_vline(aes(xintercept = median(Raw.Prediction)), color = "grey", linetype = "dashed", size=1) +
    geom_rug() +
    ylim(0,4) +
    xlab("Predictions for days with rain")
  
  
  # Return
  list(p1, p2, p3, p4, p5, p6, p7, p8)

}

