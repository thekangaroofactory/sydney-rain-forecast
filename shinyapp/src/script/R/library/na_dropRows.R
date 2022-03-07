

# ------------------------------------------------------------------------------
# Drop rows containing a number of na values > nb.na
# ------------------------------------------------------------------------------

na.dropRows <- function(x, nb.na)
{
  
  # Add column with na by row count
  x$nb.na <- apply(x, 1, function(x) sum(is.na(x)))
  
  # Get row index with NA > nb.na
  index <- which(x$nb.na >= nb.na)
  
  # display
  cat("Nb of rows =", length(index), "(",  round(length(index)/dim(x)[1]*100, digits = 2), "%)\n")
  
  # drop col
  x$nb.na <- NULL
  
  # return df without those rows
  if(length(index) != 0)
  {
    x <- x[-index,]
  }
  
  #return
  x
  
}
