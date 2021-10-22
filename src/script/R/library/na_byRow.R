

# -------------------------------------------------
# Get amount of NA by row
# -------------------------------------------------

na.byRow <- function(x)
{
  
  # Add column with na by row count
  x$nb.na <- apply(x, 1, function(x) sum(is.na(x)))
  
  # Count rows
  na_by_row <- x %>% 
    group_by(nb.na) %>% 
    summarise(count = n(),
              ratio = round(n()/dim(x)[1]*100, digits = 2))
  
}