



k_widget_date <- function(x){
  
  # check x (list or POSIXct)
  if(is.list(x)){
    
    content <- paste(x$day, x$date, x$month, x$year)
    comment <- paste("Last update:", x$time, x$tz)
    
  } else {
    
    content <- "other content"
    
  }
  
  title <- "Today"
    
  
  # build html
  div(id = 'widget-date', 
      class = 'widget-background',
      
      # title
      div(id = 'widget-date-title', 
          class = 'widget-text-light',
          title),
      
      # card
      div(id = 'widget-date-content', 
          class = 'widget-card-light',
          h3(content)),
      
      # comment
      div(id = 'widget-date-comment', 
          class = 'widget-card-dark',
          p(class = "widget-text-light", comment))
      
      )
  
}