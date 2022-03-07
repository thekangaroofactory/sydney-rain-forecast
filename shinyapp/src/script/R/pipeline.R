

# ---------------------------------------------------------------------------
# Pipeline
# ---------------------------------------------------------------------------

pipeline <- function(x)
{
  
  # ------------------------------------------------
  # Preprocessing
  # ------------------------------------------------
  
  cat("Preprocessing \n")
  
  # -- Drop columns
  cat("- Drop columns: RISK_MM, Location\n")
  x$RISK_MM <- NULL
  x$Location <- NULL
  
  # -- Extract Month from Date, drop, reorder
  cat("- Format columns: Date (keep Month only) \n")
  x$Month <- lubridate::month(x$Date)
  x$Date <- NULL
  x <- x[c(dim(x)[2], 1:dim(x)[2]-1)]
  
  
  # ------------------------------------------------
  # NA Strategy
  # ------------------------------------------------
  
  cat("NA Strategy \n")
  
  # -- Drop rows with NA >= 5
  #cat("- Drop rows with >= 5 NA values \n")
  #x <- na.dropRows(x, nb.na = 5)
  
  # -- Return
  x
  
}
