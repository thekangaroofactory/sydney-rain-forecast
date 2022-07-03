

getUpdateTime <- function(path, file){
  
  # build url
  target_url <- file.path(path, file)
  
  # read 2nd line
  x <- read.csv(target_url, header = FALSE, skip = 1, nrows = 1)
  
  # split by space
  x <- unlist(strsplit(x[[1]], split = " "))
  
  # select tokens not in..
  x <- x[which(!x %in% c("Prepared", "at", "on", "", ""))]
  
  # extract values
  time <- x[[1]]
  tz <- x[[2]]
  day <- x[[3]]
  date <- x[[4]]
  month <- x[[5]]
  year <- x[[6]]
  
  cat("Observation date:", day, date, month, year, "at", time, tz, "\n")
  
  # return
  list("time" = time, 
       "tz" = tz, 
       "day" = day, 
       "date" = date, 
       "month" = month, 
       "year" = year)
  
}