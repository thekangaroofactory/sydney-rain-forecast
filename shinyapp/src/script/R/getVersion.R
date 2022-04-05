
# ------------------------------------------------------------------------------
#' getVersion
#'
#' @param debug a logical, FALSE by default. TRUE will force read App version file instead of Git log file (even if exists)
#'
#' @return a list(last_commit, comment) where last_commit is a date (as.POSIXct) and comment a string.
#'
#' @examples getVersion() getVersion(debug = TRUE)
#' 
# ------------------------------------------------------------------------------

getVersion <- function(debug = FALSE){
  
  if(file.exists('.git/logs/HEAD') & !debug){
    
    cat("Reading version from Git HEAD log \n")
    
    # read git HEAD log file
    log_file <- read.csv('.git/logs/HEAD', header = FALSE, sep = "\t")
    
    # get last line
    log_file <- log_file[dim(log_file)[1], ]
    
    # store comment
    comment <- log_file$V2
    
    # split 1st colunm to get timestamp
    time_df <- setNames(do.call(rbind.data.frame, strsplit(unlist(log_file$V1), ' ')), 
                        c('a', 'b', 'c', 'd', 'timestamp', 'tz'))
    
    # store values
    timestamp <- as.numeric(time_df$timestamp)
    tz <- time_df$tz
    
    # commpute time to remove to timestamp
    if(tz == "+0200"){
      tz <- -2
    } else {
      tz <- -1
    }
    
    # build timestamp (CET time zone)
    last_commit <- as.POSIXct(timestamp + tz * 3600, origin="1970-01-01")
    
    # build df to save
    version_df <- data.frame("last_commit" = last_commit,
                                "comment" = comment)
    
    # save
    target_url = file.path("shinyapp", path$resource, "version.csv")
    cat("Writing git version to :", target_url, "\n")
    write.csv(version_df, file = target_url, row.names = FALSE)
    
    
  } else {
    
    cat("Reading version from App log \n")
    
    # read app version file
    target_url = file.path(path$resource, "version.csv")
    log_file <- read.csv(target_url, header = TRUE)
    
    # get values
    last_commit <- log_file$last_commit
    comment <- log_file$comment
    
  }
  
  # log
  cat("Last update: ", as.character(last_commit), "CET", comment, "\n")

  # return
  list(last_commit, comment)
  
}