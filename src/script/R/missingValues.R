

# --------------------------------------------------------------------------------
# Shiny module: Missing Values
# --------------------------------------------------------------------------------

# -- Library


# --------------------------------------------------------------------------------
# UI ITEMS SECTION
# --------------------------------------------------------------------------------

# -- Nb full rows
nbFullRow_UI <- function(id)
{
  
  # namespace
  ns <- NS(id)
  
  # text
  textOutput(ns("nbFullRow"))
  
}


# -- Nb of NA by row
naByRow_UI <- function(id)
{
  
  # namespace
  ns <- NS(id)
  
  # box
  tableOutput(ns("naByRow"))
  
}


# -- nb na by feature
naByFeature_UI <- function(id)
{
  
  # namespace
  ns <- NS(id)
  
  # box
  tableOutput(ns("naByFeature"))
  
}


# --------------------------------------------------------------------------------
# BUTTON ITEMS SECTION
# --------------------------------------------------------------------------------

# -- Drop rows button
dropRows_btn <- function(id)
{
  # namespace
  ns <- NS(id)
  
  # button
  actionButton(ns("dropRows"), label = "Drop rows")
  
}


# -- Get priorities button
getNaPriorities_btn <- function(id)
{
  # namespace
  ns <- NS(id)
  
  # button
  actionButton(ns("getNaPriorities"), label = "Get priorities")
  
}


# --------------------------------------------------------------------------------
# Server logic
# --------------------------------------------------------------------------------

nanManager_Server <- function(id, r) {
  moduleServer(id, function(input, output, session) {
    
    # get namespace
    ns <- session$ns
    
    # -- declare
    
    
    # -------------------------------------
    # Outputs
    # -------------------------------------
    
    # -- WIP NA SECTION -----------------------------------------------------------------------------
    # Compute NA counts when wip_dataset is updated
    
    observeEvent(r$wip_dataset(), {
      
      cat("observeEvent: wip_dataset updated, computing outputs... \n")
      
      # -- Compute na
      na_byRow <- na.byRow(r$wip_dataset())
      
      # -- OUTPUT: NA by row table
      output$naByRow <- renderTable(na_byRow)
      
      # -- OUTPUT: Nb full row
      output$nbFullRow <- renderText(paste("Full rows:", na_byRow[na_byRow$nb.na == 0, ]$count))
      
      # -- OUTPUT: NA by feature table
      output$naByFeature <- renderTable(na.byFeature(r$wip_dataset()), rownames = TRUE)
      
    }, ignoreInit = TRUE, ignoreNULL = TRUE)
  
    
    # -------------------------------------
    # observeEvent: buttons
    # -------------------------------------

    # -- Button: drop rows
    observeEvent(input$dropRows, {
      
      cat("Drop rows \n")
      
      # drop
      r$wip_dataset(na.dropRows(r$wip_dataset(), nb.na = 5))
      
      # notify
      showNotification("Drop rows done.")
      
    })
    
    
    # -- Button: get NA priorities
    observeEvent(input$getNaPriorities, {
      
      cat("Get NA priorities \n")
      
      # compute
      df <- na.byFeature(r$wip_dataset())
      df <- df[df$ratio > 1, ]
      df <- df[order(-df$na), ]
      
      # update
      output$naByFeature <- renderTable(df, rownames = TRUE)
      
      # notify
      showNotification("Get priorities done.")
      
    })
    
    
    # --------------------------------------------------------------------------------
    
  })
}

