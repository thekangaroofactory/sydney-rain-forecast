

# -- load data (preprocessed with python notebooks)
readProcessedData <- function(path, file){
  
  # -- build url
  target_url <- file.path(path, file)
  
  # -- read file
  processed_df <- read.csv(target_url, header = TRUE)
  
  # -- define cols
  cols <- c("Location",
            "MinTemp",
            "MaxTemp",
            "Rainfall",
            "WindGustDir",
            "WindGustSpeed",
            "WindDir9am",
            "WindDir3pm",
            "WindSpeed9am",
            "WindSpeed3pm",
            "Humidity9am",
            "Humidity3pm",
            "Pressure9am",
            "Pressure3pm",
            "Temp9am",
            "Temp3pm",
            "RainToday",
            "RainTomorrow",
            "Month")
  
  # -- filter out
  processed_df <- processed_df[cols]
  
}

