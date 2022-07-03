

check_df <- function(df1, df2){
  
  helper <- function(colname, col_x, col_y){
    
   
    is_same <- !any(col_x != col_y, na.rm = TRUE)
    cat("Dealing with column:", colname, " -- isValid ==", is_same, "\n")
    
  }
  
  lapply(1:dim(df1)[2], function(x) helper(colnames(df1[x]), df1[x], df2[x]))
  
  "done"
  
}


merge <- function(){
  
  mintemp <- as.data.frame(cbind(BACKUP_M1_processed_dataset_v1$MinTemp, output_processed_973$MinTemp))
  colnames(mintemp) <- c("backup", "new")
  mintemp$check <- mintemp$backup == mintemp$new
  
  mintemp
  
}