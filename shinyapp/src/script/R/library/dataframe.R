
library(dplyr)

# ---------------------------------------------------
# Dataframe tools
# ---------------------------------------------------

# -- Get numerical features
df.numerical <- function(x)
{
  x %>% 
    select(where(is.numeric))
}


# -- get categorical features
df.categorical <- function(x)
{
  x %>% 
    select(where(is.character))
}