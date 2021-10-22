

# -- Library
library(ggplot2)


#' getLinearModel
#'
#' @description Get linear model between 2 features
#'
#' @param data a datafame containing numerical features
#' @param x input feature of the linear model
#' @param y output feature of the linear model. y = slope * x + intercept
#'
#' @return a plot of the linear model between x and y
#'
#' @examples getLinearModel(data, x, y)


getLinearModel <- function(data, x, y)
{
  
  # compute formula
  f <- as.formula(paste(y, x, sep = " ~ "))
  
  # get linear regression model, store values
  model <- lm(f, data = data)
  intercept <- model$coefficients[[1]]
  cat("Intercept = ", intercept, "\n")
  slope <- model$coefficients[[2]]
  cat("Slope = ", slope, "\n")
  
  # plot data and model
  ggplot(data = data, aes_string(x = x, y = y)) + 
    geom_point() +
    stat_smooth() +
    geom_abline(intercept = intercept, slope = slope, color="red", linetype="dashed", size=1.5)
  
}
