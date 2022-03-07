

# -- Library

library(Hmisc)
library(corrplot)


#' Title
#'
#' @description Num columns correlation
#'
#' @param x data.frame containing numerical features
#' @param method method parameter (default = 'circle') to be passed to corrplot function
#' @param addCoef.col addCoef.col parameter (default = NULL) to be passed to corrplot function
#'
#' @return a correlation plot (result of the corrplot function)
#'
#' @examples correlation(my_dataframe, method = 'circle', addCoef.col = NULL)


correlation <- function(x, method = 'circle', addCoef.col = NULL)
{
  
  # compute correlation matrix
  cor_mat <- rcorr(as.matrix(x))
 
  # plot matrix
  corrplot(cor_mat$r,
           p.mat = cor_mat$P,
           order = "hclust",
           type = "upper",
           method = method,
           # Hide diagonal
           diag = FALSE,
           # Insignificant values
           insig = "blank",
           # Add coef
           addCoef.col = addCoef.col,
           number.cex = 0.7,
           # Text label color & rotation
           tl.col = "black",
           tl.srt = 45)
  
}