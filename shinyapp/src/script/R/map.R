
# --------------------------------------------------------------------------------
# Shiny module: map
# --------------------------------------------------------------------------------

# -- Library
library(leaflet)


# -- Source dependencies


# -------------------------------------
# UI items section
# -------------------------------------

# -- Main map
map_UI <- function(id)
{
  
  # namespace
  ns <- NS(id)
  
  # map
  leafletOutput(ns("map"))
  
}



# -------------------------------------
# Server logic
# -------------------------------------

map_Server <- function(id, r, path) {
  moduleServer(id, function(input, output, session) {
    
    # -------------------------------------
    # Outputs
    # -------------------------------------
    
    # -- Output: map
    output$map <- renderLeaflet({
      
      leaflet() %>%
        
        # Add default OpenStreetMap map tiles
        addTiles(group = "OSM") %>%
        
        # Add water color map
        addProviderTiles(providers$Stamen.Watercolor) %>%
        
        # Set view point
        setView(lng = 133.69, lat = -25.70, zoom = 3) %>%
        
        # Add marker
        addMarkers(lng = 151.2153170814733, lat = -33.85683176662791, label = "Sydney")
      
        
    })
    
    # -- Declare proxy map
    #r$proxymap <- leafletProxy('map')
    
    
  })
}

