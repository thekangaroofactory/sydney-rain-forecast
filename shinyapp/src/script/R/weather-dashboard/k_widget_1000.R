


k_widget_1000 <- function(x){
  
  
  title <- "Milestone"
  content <- "1000 Observations"
  comment <- "792 OK / 208 KO"
  
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
          p(class = "widget-text-light", comment),
          p(class = "widget-text-light", "Accuracy: 79.2%"),
          p(class = "widget-text-light", "Precision: 0.78"),
          p(class = "widget-text-light", "Recall: 0.73"))
      
  )
  
}