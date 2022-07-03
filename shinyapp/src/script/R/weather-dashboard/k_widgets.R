

# ------------------------------------------------------------------------------
# Widget basics

widget_bkgd <- function(id, x){
  
  # build html
  div(id = paste0("widget-", id), 
      class = 'widget-background',
      
      x)
  
}


widget_card <- function(type, x){
  
  # build html
  div(class = paste0('widget-card-', type), x)
  
}

tick <- function(width, height, left = NULL, right = NULL, text = "", text.left = NULL, text.right = NULL){
  
  # html
  div(class = 'tick', style = css_style(width = width, height = height, left = left, right = right),
      div(style = css_style(position = "absolute", top = -12, left = text.left, right = text.right), text)
      
      )

}

# ------------------------------------------------------------------------------
# Features

feature_v <- function(id, range, min = NULL, max, values, width = 20, height = 100, tick.space = 10, tick.width = 5){

  # prepare
  step <- height / (max(range) - min(range))
  height_min <- min * step
  height_max <- max * step
  
  # check: if min null, then max is the only value
  max.text <- "max"
  if(is.null(min))
    max.text <- max
  
  
  # helper
  helper <- function(x){
    
    # extract
    text <- names(x[1])
    value <- x[[1]]
    
    # call tick
    tick(width = tick.width, height = value * step, right = width + tick.space, text = text, text.right = 10)
    
  }
  
  
  # build html
  div(class = 'feature-container',
      
      # dark background
      div(class = 'feature-v-dark', style = css_style(width = width, height = height),
          
          svg,
          
          # max value & tick
          div(class = 'feature-v-color', style = css_style(width = width, height = height_max)),
          tick(width = tick.width, height = height_max, left = width + tick.space, text = max.text, text.left = 10),
          
          # min value & tick
          if(!is.null(min)){
            tagList(
              div(class = 'feature-v-color', style = css_style(width = width, height = height_min)),
              tick(width = tick.width, height = height_min, left = width + tick.space, text = "min", text.left = 10))},
          
          # values & tick
          if(!is.null(values))
            lapply(1:length(values), function(x) helper(values[x]))
          
          ),
      
      ) # end divs
  
}


# ------------------------------------------------------------------------------
# Widgets

k_widget_v <- function(id, range, min = NULL, max, values = NULL, title){
  
  # build html
  widget_bkgd(id = id, 
              tagList(h2(title),
                      feature_v(id, range, min, max, values)))
  
}

