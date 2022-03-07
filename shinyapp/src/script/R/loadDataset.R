

loadDataset <- function(file){
  
  # read file
  x <- read.csv(file , header = T)
  
  # format Date
  x$Date <- as.Date(x$Date, "%d/%m/%Y")
  
  # return
  x
  
}