
library(dplyr)

# -------------------------------------------------
# Compute means by group (= feature to group by)
# -------------------------------------------------

meanByGroup <- function(x, group)
{
  
  # get mean by month
  x %>%
    group_by(across(all_of(group))) %>%
    summarise(across(everything(), ~mean(., na.rm = TRUE)))
  
}