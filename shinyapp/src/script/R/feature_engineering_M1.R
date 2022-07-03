

library(jsonlite)


featureEngineering <- function(x, model){
  
  cat(">> featureEngineering() \n")
  
  # -------------------------------------
  # Input parameters
  
  
  # list of column to remove
  list_remove <- c('RISK_MM')
  
  
  # -------------------------------------
  # Load dataset JSON report (schema)
  
  cat("Load data schema \n")
  json_report_url <- file.path(path$schema, model, file$dataset_report)
  data_schema <- fromJSON(json_report_url)
  
  
  # -------------------------------------
  # Extract lists from report
  feature_list <- data_schema[['colname']]
  
  # Extract numerical related lists
  numerical_index <- which(data_schema[['coltype']] == "float")
  numerical_features <- feature_list[numerical_index]
  range_list <- data_schema[['range']][numerical_index]
  mean_list <- data_schema[['mean']][numerical_index]

  
  # Extract categorical related lists
  categorical_index <- which(data_schema[['coltype']] == "str")
  categorical_features <- feature_list[categorical_index]
  category_list <- data_schema[['unique_str']][categorical_index]
  
 
  # -------------------------------------
  # Load bucket mappings
  
  cat("Load mapping \n")
  location_mapping_url <- file.path(path$schema, file$mapping_Location)
  location_mapping <- read.csv(location_mapping_url, sep = ',')

  
  # -------------------------------------
  # Load mean by location report
  
  # Open csv file
  cat("Load mean by location \n")
  mean_by_location_url <- file.path(path$schema, model, file$means_by_location)
  mean_by_loc_df <- read.csv(mean_by_location_url, sep = ',')
  

  # -------------------------------------
  # Feature engineering
  
  cat("Apply feature engineering: \n")
  
  # Step.0: -- drop columns
  x <- x[!colnames(x) %in% list_remove]
  
  # Step.1: -- extract Month from Date
  cat("-- extract Month from Date \n")
  x['Month'] <- format(x['Date'], "%m")
  x['Date'] <- NULL
  
  # Step.2: -- Categorical features  
  # 2.1: Fill values out of schema with unknown
  cat("-- Fill categorical values out of schema \n")
  x[!x$WindGustDir %in% category_list[[2]], ]$WindGustDir <- "UNK"
  x[!x$WindDir9am %in% category_list[[3]], ]$WindDir9am <- "UNK"
  x[!x$WindDir3pm %in% category_list[[4]], ]$WindDir3pm <- "UNK"

  # 2.2: Index categorical features (remove 1 because python started at 0...)
  cat("-- Index categorical features \n")
  # wind
  x$WindGustDir <- match(x$WindGustDir, c("UNK", category_list[[2]])) - 1
  x$WindDir9am <- match(x$WindDir9am, c("UNK", category_list[[3]])) - 1
  x$WindDir3pm <- match(x$WindDir3pm, c("UNK", category_list[[4]])) - 1
  
  # location
  x$Location <- location_mapping[match(x$Location, location_mapping$Location), ]$Mapping
  
  # rain
  x$RainToday <- match(x$RainToday, category_list[[5]]) - 1
  x$RainTomorrow <- match(x$RainTomorrow, category_list[[6]]) - 1
  
  
  # Step.3: -- Numerical features
  # 3.1: Fill NaN values
  
  # -- helper
  fill_num_nan <- function(col){
    
    cat("   * Dealing with column:", col, "\n")
    
    # col name
    meancol = paste0('Mean', col)
    
    # replace from mean_by_loc_df or mean_list by default
    if(meancol %in% colnames(mean_by_loc_df))
      x[is.na(x[col]), col] <-  mean_by_loc_df[mean_by_loc_df$Location == "Sydney", meancol]
    
    else
      x[is.na(x[col]), col] <- mean_list[which(numerical_features == col)]
    
    # return
    x[[col]]
    
    }
  
  # -- apply helper
  cat("-- Fill numerical missing values \n")
  x[numerical_features] <- lapply(numerical_features, fill_num_nan)
  
  # 3.2: features normalization [(x - mean) / range]
  cat("-- Numerical features normalization \n")

  # -- helper
  feat_norm <- function(col, mean, range){
    
    cat("Col =", col, "mean =", mean, "range=", range, "\n")
    
    # normalization
    x[col] <- (x[col] - mean) / range
    
    # return
    x[[col]]
    
  }
  
  # apply helper
  x[numerical_features] <- lapply(numerical_features, function(col) feat_norm(col, 
                                                                              mean_list[match(col, numerical_features)], 
                                                                              range_list[match(col, numerical_features)]))
  
  
  cat("<< featureEngineering() \n")
  
  # -------------------------------------
  # return
  
  x[1:dim(x)[1]-1, ]
  
}
