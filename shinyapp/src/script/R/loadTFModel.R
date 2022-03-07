

# -- load model
loadTFmodel <- function(path, file){
  
  # build url
  target_url <- file.path(path, file)
  
  # load
  model <- load_model_hdf5(target_url, custom_objects = NULL, compile = TRUE)
  
}

