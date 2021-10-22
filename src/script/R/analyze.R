

# --------------------------------------------------------------------------------
# Shiny module: analyze
# --------------------------------------------------------------------------------

# -- Library
library(ggplot2)


# --------------------------------------------------------------------------------
# UI ITEMS SECTION
# --------------------------------------------------------------------------------

# -- Numerical features list
wipNumFeat_UI <- function(id)
{
  
  # namespace
  ns <- NS(id)
  
  # box
  textOutput(ns("wipNumFeat"))
  
}


# -- Categorical features list
wipCatFeat_UI <- function(id)
{
  
  # namespace
  ns <- NS(id)
  
  # box
  textOutput(ns("wipCatFeat"))
  
}


# -- Correlation text
wipCorrTxt_UI <- function(id)
{
  
  # namespace
  ns <- NS(id)
  
  # text
  conditionalPanel(condition = 'output.showCorrTxt == true',
                   ns = ns,
                   p("In this specific case, we are not learning much from this correlation matrix - most correlations are just as expected.",br(),
                     "But it's a great example:", br(),
                     "- MinTemp has positive correlation with Temp9am ; the higher the temperature at 9am is, the higher the minimum temperature is.", br(),
                     "- Sunshine has negative correlation with Cloud3pm ; more clouds at 3pm means less sunshine hours")
  )
}


# --------------------------------------------------------------------------------
# PLOT ITEMS SECTION
# --------------------------------------------------------------------------------

# -- p1: single box plot
singleBox_PLOT <- function(id)
{
  
  # namespace
  ns <- NS(id)
  
  # box
  plotOutput(ns("singleBoxPlot"))
  
}


# -- p2: single distribution plot
singleDist_PLOT <- function(id)
{
  
  # namespace
  ns <- NS(id)
  
  # box
  plotOutput(ns("singleDistPlot"))
  
}


# -- p3: time box plot
timeBox_PLOT <- function(id)
{
  
  # namespace
  ns <- NS(id)
  
  # box
  plotOutput(ns("timeBoxPlot"))
  
}


# -- RainTomorrow balance plot
balancePlot_UI <- function(id)
{
  
  # namespace
  ns <- NS(id)
  
  # box
  plotOutput(ns("balancePlot"))
  
}


# -- Numerical correlation plot
wipCorrelationPlot_UI <- function(id)
{
  
  # namespace
  ns <- NS(id)
  
  # box
  plotOutput(ns("wipCorrelation"))
  
}


# --------------------------------------------------------------------------------
# BUTTON ITEMS SECTION
# --------------------------------------------------------------------------------

# -- Get types
getTypes_btn <- function(id)
{
  # namespace
  ns <- NS(id)
  
  # button
  actionButton(ns("getTypes"), label = "Get types")
  
}


# -- Continuous correlation
getCorrelation_btn <- function(id)
{
  # namespace
  ns <- NS(id)
  
  # button
  actionButton(ns("getCorrelation"), label = "Get correlation")
  
}


# --------------------------------------------------------------------------------
# INPUT ITEMS SECTION
# --------------------------------------------------------------------------------

# -- select numerical feature
selectNumerical_input <- function(id)
{
  # namespace
  ns <- NS(id)
  
  # input
  selectInput(inputId = ns("selectNumFeat"), label = "-", choices = NULL, width = 200)
  
}


# --------------------------------------------------------------------------------
# Server logic
# --------------------------------------------------------------------------------

analysisManager_Server <- function(id, r) {
  moduleServer(id, function(input, output, session) {
    
    # get namespace
    ns <- session$ns
    
    # -- declare
    output$showCorrTxt <- reactive(FALSE)
    outputOptions(output, "showCorrTxt", suspendWhenHidden = FALSE)
    # -- Numerical feature list
    output$wipNumFeat <- renderText("-")
    # -- Categorical feature list
    output$wipCatFeat <- renderText("-")
    
    
    # --------------------------------------------------------------------------------
    # OUTPUTS
    # --------------------------------------------------------------------------------
    
    # --------------------------------------------------------------------------------
    # observeEvent: dataset
    # --------------------------------------------------------------------------------
    
    # -- Dataset balance plot
    observeEvent(r$raw_dataset(), {
      
      output$balancePlot <- renderPlot({
        ggplot(r$raw_dataset(), aes(x = RainTomorrow, fill = RainTomorrow)) + 
          geom_bar(width = 0.25, alpha = 0.5, fill = c("#999999", "#E69F00")) +
          coord_flip()
      })
      
    })
    
    
    # --------------------------------------------------------------------------------
    # observeEvent: buttons
    # --------------------------------------------------------------------------------
    
    # -- Button: get types
    observeEvent(input$getTypes, {
      
      cat("Get feature types \n")
      
      if(!is.null(r$wip_dataset()))
      {
        # -- WIP: numerical list
        output$wipNumFeat <- renderText(paste0(colnames(df.numerical(subset(r$wip_dataset(), select = -c(Month)))), collapse = ", "))
        
        # -- WIP: categorical list
        output$wipCatFeat <- renderText(paste0(colnames(df.categorical(r$wip_dataset())), collapse = ", "))
        
        # Update numerical select input
        updateSelectInput(session, inputId = "selectNumFeat", label = "Select variable:", choices = colnames(df.numerical(subset(r$wip_dataset(), select = -c(Month)))), selected = NULL)
        
      }
      else{
        showNotification("Init data first!", type = "error")
      }
      
    })
    
    
    # -- Button: get correlation button
    observeEvent(input$getCorrelation, {
      
      cat("Get correlation \n")
      
      if(!is.null(r$wip_dataset()))
      {
        # generate plot
        output$wipCorrelation <- renderPlot(correlation(df.numerical(r$wip_dataset())),
                                            width = 500,
                                            height = 500)
        
        # show text
        output$showCorrTxt <- reactive(TRUE)
      }
      else{
        showNotification("Init data first!", type = "error")
      }
      
    })
    
    
    # --------------------------------------------------------------------------------
    # observeEvent: inputs
    # --------------------------------------------------------------------------------
    
    # -- Input: select numerical feature
    observeEvent(input$selectNumFeat, {
      
      # check
      req(input$selectNumFeat)
      
      # Create a Progress object
      progress <- shiny::Progress$new()
      # Make sure it closes when we exit this reactive, even if there's an error
      on.exit(progress$close())
      # Init
      progress$set(message = "Building plots...", value = 0)
      
      
      # get value
      feature <- input$selectNumFeat
      cat("Numerical feature selected ", feature, "\n")
      
      # compute plot 1 and set output (single line = bug:blank plot)
      p1 <- plot.singleBox3(r$wip_dataset(), feature, "RainTomorrow")
      output$singleBoxPlot <- renderPlot(p1)
      
      # update progress
      progress$inc(1/3, detail = "Plot.1 : done")
      
      # compute plot 2 and set output (single line = bug:blank plot)
      p2 <- plot.singleDist(r$wip_dataset(), feature, "RainTomorrow")
      output$singleDistPlot <- renderPlot(p2)
      
      # update progress
      progress$inc(2/3, detail = "Plot.2 : done")
      
      # compute plot 3 and set output (single line = bug:blank plot)
      p3 <- plot.timeBox2(r$wip_dataset(), feature, "MonthAbb", "RainTomorrow")
      output$timeBoxPlot <- renderPlot(p3)
      
      # update progress
      progress$inc(3/3, detail = "Plot.3 : done")
      
    })
    
    
    # --------------------------------------------------------------------------------
    
  })
}

