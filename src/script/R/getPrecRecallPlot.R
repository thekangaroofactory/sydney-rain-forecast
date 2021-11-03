

# ------------------------------------------------------------------------------
#' getPrecRecallPlot
#' 
#' @description The function builds and returns a plot of the ROC curve
#'
#' @param data a dataframe with columns FP.Rate (false positive rate) and TP.Rate (true positive rate)
#'
#' @return a plot (ggplot) of the ROC curve
#'
#' @examples getROCPlot(data)
#' 
# ------------------------------------------------------------------------------


getPrecRecallPlot <- function(data){
  
  # -- extract x and y columns
  plot_df <- data[, c("Recall", "Precision")]
  
  # -- remove duplicate points (to avoid crazy lines)
  plot_df <- plot_df[!duplicated(plot_df), ]
  
  # -- create plot
  p <- ggplot(plot_df, aes(x = Recall, y = Precision)) +
    geom_point() +
    geom_line() +
    geom_segment(aes(x = 0, y = 0, xend = 1, yend = 0), linetype = "dashed", color = "blue")
  
}