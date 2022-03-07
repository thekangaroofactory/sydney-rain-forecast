

# -------------------------------------------------
# Get amount of NA by feature
# -------------------------------------------------

na.byFeature <- function(x)
{
  
  # get NA by column
  df <- as.data.frame(sapply(x, function(x) sum(is.na(x))))
  colnames(df) <- c("na")
  
  # add ratio column
  df$ratio <- round(df$na / dim(x)[1] * 100, digits = 2)
  
  # return
  df
  
}