

css_style <- function(width = NULL,
                      height = NULL,
                      position = NULL,
                      top = NULL,
                      left = NULL,
                      right = NULL){
  
  # init string
  x <- ""
  
  # position
  if(!is.null(position))
    x <- c(x, paste0('position:', position, ';'))
  
  # px
  if(!is.null(width))
    x <- c(x, paste0('width:', width, 'px;'))
  
  if(!is.null(height))
    x <- c(x, paste0('height:', height, 'px;'))

  if(!is.null(top))
    x <- c(x, paste0('top:', top, 'px;'))
  
  if(!is.null(left))
    x <- c(x, paste0('left:', left, 'px;'))
  
  if(!is.null(right))
    x <- c(x, paste0('right:', right, 'px;'))
  
  # return
  x
  
}