


getMissingObservations <- function(x, path){
  
  cat("Checking missing observations: \n")

  # 1. get latest obs
  #latest_obs_date <- as.Date("2021-12-15", "%Y-%m-%d")
  latest_obs_date <- max(x$Date)
  cat("-- latest observation:", latest_obs_date, "\n")
  
  # 2. check if obs complete
  isComplete <- any(is.na(x[x$Date == latest_obs_date, ]))
  cat("-- isComplete:", isComplete, "\n")
  
  # 3. set first needed obs (same or next day given 2.)
  seq_start <- if(isComplete) latest_obs_date + 1 else latest_obs_date
  
  # 3b. get last day of this month
  # *** fixing bug
  # year <- format(Sys.Date(), "%Y")
  # month <- format(Sys.Date(), "%m")
  # seq_end <- as.Date(paste0(year, "-", as.numeric(month) + 1, "-01")) - 1
  seq_end <- lubridate::ceiling_date(Sys.Date(), 'month') %m-% days(1)
  
  # 4. make sequence
  downloads_df <- format(seq(seq_start, seq_end, by = "month"), "%Y-%m")
  downloads_df <- as.data.frame(str_split_fixed(downloads_df, "-", 2))
  colnames(downloads_df) <- c("year", "month")
  
  # 5. call 
  helper <- function(x)
    downloadObservations(year = x$year, month = x$month, path = path)
  
  # apply helper
  # TODO: check if needed - empty or bad time for today ????
  if(dim(downloads_df)[1] != 0)
    list_downloads <- lapply(1:dim(downloads_df)[1], function(x) helper(downloads_df[x, ]))
  
  
}