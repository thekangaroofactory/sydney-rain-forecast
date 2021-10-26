

# ------------------------------------------------------------------------------
#' getConfusionPlot
#' 
#' @description Returns a confution matrix plot
#'
#' @param obs number of observations
#' @param tp number of true positive examples
#' @param fp number of false positive examples
#' @param fn number of false negative examples
#' @param tn number of true negative examples
#'
#' @return a plot from ggplot() function
#'
#' @examples p <- getConfusionPlot(273, 39, 3, 68, 162)
#' 
# ------------------------------------------------------------------------------

# -- library
library(ggplot2)

# -- function
getConfusionPlot <- function(obs, tp, fp, fn, tn){
  
  # -- build dataframe
  plotTable <- data.frame(Prediction = c("Rain", "NoRain", "NoRain", "Rain"),
                          Reference = c("NoRain", "NoRain", "Rain", "Rain"),
                          Freq = c(fp, tn, fn, tp),
                          Result = c("bad", "good", "bad", "good"),
                          Ratio = c(fp/obs, tn/obs, fn/obs, tp/obs))
  
  
  
  # -- create plot
  p <- ggplot(data = plotTable, mapping = aes(x = Prediction, y = Reference, fill = Result, alpha = Ratio)) +
    geom_tile() +
    geom_text(aes(label = Freq), vjust = .5, fontface  = "bold", alpha = 1) +
    scale_fill_manual(values = c(good = "green", bad = "red")) +
    theme_bw() +
    scale_x_discrete(position = "top", limits=c("Rain", "NoRain"))
  
}