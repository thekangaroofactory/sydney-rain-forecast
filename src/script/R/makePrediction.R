

# -- library
library(keras)

makePrediction <- function(model, input_df, batch_size = NULL, verbose = 1, steps = NULL, callbacks = NULL){
  
  # -- call Keras
  raw_predictions <- predict(model,
                             x = as.matrix(input_df),
                             batch_size = NULL,
                             verbose = 1,
                             steps = NULL,
                             callbacks = NULL)
  
}

