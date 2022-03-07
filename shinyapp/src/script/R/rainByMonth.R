

# ---------------------------------------------
# Rain by month
# ---------------------------------------------

rainByMonth <- function(x)
{
  
  x %>%
    group_by(Month) %>%
    summarise(Yes = sum(RainTomorrow == 'Yes'),
              No = sum(RainTomorrow == 'No'),
              Ratio = sum(RainTomorrow == 'Yes')/n()*100)
  
}
