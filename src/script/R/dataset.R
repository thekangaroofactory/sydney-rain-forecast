

# --------------------------------------------------------------------------------
# Shiny module: dataset
# --------------------------------------------------------------------------------

# -- Library


# --------------------------------------------------------------------------------
# UI ITEMS SECTION
# --------------------------------------------------------------------------------

# -- DT table UI
itemTable_UI <- function(id)
{
  
  # namespace
  ns <- NS(id)
  
  # table
  DTOutput(ns("itemTable"))
  
}


# -- RAW: Dataset nb observation
rawNbRow_UI <- function(id)
{
  
  # namespace
  ns <- NS(id)
  
  # box
  valueBoxOutput(ns("nbRows"))
  
}


# -- RAW: Dataset nb features
rawNbFeature_UI <- function(id)
{
  
  # namespace
  ns <- NS(id)
  
  # box
  valueBoxOutput(ns("nbFeature"))
  
}


# -- WIP: Dataset nb observation
wipNbRow_UI <- function(id)
{
  
  # namespace
  ns <- NS(id)
  
  # box
  valueBoxOutput(ns("wipNbRows"))
  
}


# WIP: nb feature
wipNbFeature_UI <- function(id)
{
  
  # namespace
  ns <- NS(id)
  
  # box
  valueBoxOutput(ns("wipNbFeature"))
  
}


# --------------------------------------------------------------------------------
# Button items section
# --------------------------------------------------------------------------------

# -- load button
loadData_btn <- function(id)
{
  # namespace
  ns <- NS(id)
  
  # button
  actionButton(ns("loadData"), label = "Load dataset")
  
}


# -- Init/Reset button
resetData_btn <- function(id)
{
  # namespace
  ns <- NS(id)
  
  # button
  actionButton(ns("resetData"), label = "Init / Reset")
  
}


# -- Drop feature button
dropFeature_btn <- function(id)
{
  # namespace
  ns <- NS(id)
  
  # button
  actionButton(ns("dropFeature"), label = "Drop")
  
}


# --------------------------------------------------------------------------------
# Server logic
# --------------------------------------------------------------------------------

datasetManager_Server <- function(id, r, path, file) {
  moduleServer(id, function(input, output, session) {
    
    # get namespace
    ns <- session$ns
    
    # -- declare
    r$raw_dataset <- reactiveVal(NULL)
    r$wip_dataset <- reactiveVal(NULL)
    
    
    # -------------------------------------
    # Outputs
    # -------------------------------------
    
    # -- Main table
    output$itemTable <- renderDT(r$raw_dataset(),
                                    options = list(lengthMenu = c(5, 1),
                                                   pageLength = 5,
                                                   dom = "lfrtip", #tp
                                                   ordering = TRUE,
                                                   searching = TRUE,
                                                   scrollX = TRUE),
                                    rownames = FALSE,
                                    selection = 'single')
    
    
    # -- DIM SECTION -----------------------------------------------------------------------------
    
    # -- Dataset nb observations
    output$nbRows <- renderValueBox({
      valueBox(ifelse(is.null(r$raw_dataset()), 0, dim(r$raw_dataset())[[1]]), 
               "Observations", 
               icon = icon("list"),
               color = "purple"
      )})
    
      
    # -- Dataset nb features
    output$nbFeature <- renderValueBox({
      valueBox(ifelse(is.null(r$raw_dataset()), 0, dim(r$raw_dataset())[[2]]),
               "Features", 
               icon = icon("list"),
               color = "purple"
      )})
    
    # -- WIP: Dataset nb observations
    output$wipNbRows <- renderValueBox({
      valueBox(ifelse(is.null(r$wip_dataset()), 0, dim(r$wip_dataset())[[1]]),
               "Observations", 
               icon = icon("list"),
               color = "purple",
      )})
    
    
    # -- WIP: Dataset nb features
    output$wipNbFeature <- renderValueBox({
      valueBox(ifelse(is.null(r$wip_dataset()), 0, dim(r$wip_dataset())[[2]]), 
               "Features", 
               icon = icon("list"),
               color = "purple"
      )})
    
    
    # -------------------------------------
    # observeEvent: buttons
    # -------------------------------------
    
    # -- Button: load data button
    observeEvent(input$loadData, {
      
      cat("Load dataset \n")
      
      if(is.null(r$raw_dataset()))
      {
        # load
        r$raw_dataset(loadDataset(file$raw_dataset))
        
        # notify
        showNotification("Dataset loaded.", type = "message")
      }
      else{
        showNotification("Dataset already loaded.", type = "warning")
      }
      
    })
    
    
    # -- Button: reset data
    observeEvent(input$resetData, {
      
      cat("Init / Reset dataset! \n")
      
      if(!is.null(r$raw_dataset()))
      {
        # get dataset
        x <- r$raw_dataset()
        
        # -- Extract Month from Date
        cat("- Add column: Month (from Date) \n")
        x$Month <- lubridate::month(x$Date)
        x$Date <- NULL
        x <- x[c(dim(x)[2], 1:dim(x)[2]-1)]
        
        # -- Add MonthAbb (for plot grouping)
        x$MonthAbb <- month.abb[x$Month]
        
        # -- store
        r$wip_dataset(x)
        
        # notify
        showNotification("Init / Reset data done.")
      }
      else{
        showNotification("Load data first!", type = "error")
      }
      
      
    })
    
    
    # -- Button: drop feature
    observeEvent(input$dropFeature, {
      
      cat("Drop features \n")
      
      # get dataset
      df <- r$wip_dataset()
      
      if(is.null(df))
      {
        # notify
        showNotification("Init data first!", type = "error")
      }
      else{
        if(dim(df)[[2]]>22)
        {
          
          # drop
          df <- df[, -which(names(df) %in% c("Location", "RISK_MM"))]
          
          # store
          r$wip_dataset(df)
          
          # notify
          showNotification("Drop feature done.")
          
        }
        else{
          # notify
          showNotification("Drop feature already done!", type = "warning")
        }
      }
    })
    

    # --------------------------------------------------------------------------------
  
  })
}

