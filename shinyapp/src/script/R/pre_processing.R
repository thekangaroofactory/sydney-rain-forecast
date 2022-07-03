
library(data.table)


pre_process <- function(inputs, formated_ds){
  
  # colClasses
  colClasses <- c("X" = "character",
                  "Date" = "character",
                  "Minimum.temperature...C." = "numeric",
                  "Maximum.temperature...C." = "numeric",
                  "Rainfall..mm." = "numeric",
                  "Evaporation..mm." = "numeric",
                  "Sunshine..hours." = "numeric",
                  "Direction.of.maximum.wind.gust." = "character",
                  "Speed.of.maximum.wind.gust..km.h." = "numeric",
                  "Time.of.maximum.wind.gust" = "character",
                  "X9am.Temperature...C." = "numeric",
                  "X9am.relative.humidity...." = "numeric",
                  "X9am.cloud.amount..oktas." = "numeric",
                  "X9am.wind.direction" = "character",
                  "X9am.wind.speed..km.h." = "numeric",
                  "X9am.MSL.pressure..hPa." = "numeric",
                  "X3pm.Temperature...C." = "numeric",
                  "X3pm.relative.humidity...." = "numeric",
                  "X3pm.cloud.amount..oktas." = "numeric",
                  "X3pm.wind.direction" = "character",
                  "X3pm.wind.speed..km.h." = "numeric",
                  "X3pm.MSL.pressure..hPa." = "numeric")
    
  
  # colnames
  col_names <- c('Date',
            'MinTemp', 
            'MaxTemp',
            'Rainfall',
            'Evaporation',
            'Sunshine',
            'WindGustDir',
            'WindGustSpeed',
            'Temp9am',
            'Humidity9am',
            'Cloud9am',
            'WindDir9am',
            'WindSpeed9am',
            'Pressure9am',
            'Temp3pm',
            'Humidity3pm',
            'Cloud3pm',
            'WindDir3pm',
            'WindSpeed3pm',
            'Pressure3pm')
  
  # Reorder columns
  col_order = c('Date',
              'MinTemp',
              'MaxTemp',
              'Rainfall',
              'Evaporation',
              'Sunshine',
              'WindGustDir',
              'WindGustSpeed',
              'WindDir9am',
              'WindDir3pm',
              'WindSpeed9am',
              'WindSpeed3pm',
              'Humidity9am',
              'Humidity3pm',
              'Pressure9am',
              'Pressure3pm',
              'Cloud9am',
              'Cloud3pm',
              'Temp9am',
              'Temp3pm')
  
  # list files in input folder
  cat("New files to be processed:", length(inputs), "\n")

  # helper function
  helper <- function(x){
    
    # read file
    cat("Processing file:", x, "\n")
    raw_df <- read.csv(x, header = TRUE, colClasses = colClasses, skip = 8, encoding = "ANSI")
    
    # ---------------------------------------------------
    # Columns
    
    # drop cols
    raw_df[c('X', 'Time.of.maximum.wind.gust')] <- NULL
    
    # rename
    colnames(raw_df) <- col_names
    
    # reorder
    raw_df = raw_df[col_order]
    
    # ---------------------------------------------------
    # Format

    # Date column
    raw_df$Date = as.Date(raw_df$Date, format = '%Y-%m-%d')
    
    # ---------------------------------------------------
    # Add columns to fit original data
    
    raw_df <- cbind("Location" = "Sydney", raw_df)
    
    raw_df$RainToday <- "No"
    # check for cases where no rows meet condition
    if(any(raw_df$Rainfall > 0))
      # fix: use which to avoid pb with NA's
      raw_df[which(raw_df$Rainfall > 0), ]$RainToday <- "Yes"
    
    raw_df$RISK_MM <- 0 # will be ignored anyway
    raw_df$RainTomorrow <- "No" # default value, will be updated 
    
    # return
    raw_df
    
  }
  
  # apply helper
  obs <- lapply(inputs, function(x) helper(x))
  
  # merge new obs
  obs <- rbindlist(obs)
  
  # ---------------------------------------------------
  # merge with existing obs
  cat("Merge observations \n")
  
  # slice (exclude duplicates from existing obs -- will be updated)
  formated_ds <- formated_ds[!formated_ds$Date %in% obs$Date, ]
  
  # merge
  obs <- rbind(formated_ds, obs)
  
  
  # Fill in RainTomorrow values (last raw remains as NA)
  obs[which(obs$RainToday == 'Yes')-1, ]$RainTomorrow <- "Yes"
  obs[dim(obs)[1], ]$RainTomorrow <- "Na"
  
  # log
  cat("Processing done. \n")
  
  # return
  obs
  
}

