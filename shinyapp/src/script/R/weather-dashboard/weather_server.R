
# --------------------------------------------------------------------------------
# Shiny module: 
# --------------------------------------------------------------------------------

# -- Library
library(leaflet)
library(stringr)


# -------------------------------------
# Server logic
# -------------------------------------

weatherDashboard_Server <- function(id, r, path, file) {
  moduleServer(id, function(input, output, session) {
    
    # ***********************************
    # Check new observation
    # >> this should go into a data module !!!
    
    observeEvent(r$formated_ds(), {
      
      # check and download observations
      list_downloads <- getMissingObservations(r$formated_ds(), path$download)
      
      # pre processing
      observations <- pre_process(list_downloads, r$formated_ds())
      
      cat("Save formated data \n")
      formated_data_url <- file.path(path$formated, file$formated)
      write.csv(observations, formated_data_url, row.names = FALSE, quote = FALSE)
      
      # feature engineering
      feat_M1 <- featureEngineering(observations, "M1")

      cat("Save processed data \n")
      processed_dataset_url <- file.path(path$processed, paste0("M1_", file$processed))
      write.csv(feat_M1, processed_dataset_url, row.names = FALSE, quote = FALSE)
      
      showNotification("New observations are now ready to use")
      
      # store
      #r$formated_ds(observations)
      
    })

    # ***********************************
        
    
    # build file name
    # file_url <- paste0("IDCJDW2124.", format(Sys.Date(), '%Y'), format(Sys.Date(), '%m'), ".csv")
    # 
    # # extract update time
    # last_update <- getUpdateTime(path$download, file_url)
    # 
    # 
    # # -------------------------------------
    # # Widgets
    # # -------------------------------------
    # 
    # # Widget: date
    # output$widget_date <- renderUI(k_widget_date(last_update))
    # 
    # # Widget: temperature
    # output$widget_temperature <- renderUI(k_widget_v(id = "temperature",
    #                                                  range = c(0, 40),
    #                                                  min = 12.4,
    #                                                  max = 23.8,
    #                                                  values = list("9am" = 14.6,
    #                                                                "3pm" = 23.5),
    #                                                  title = "Temperature (\u00B0C)"))
    # 
    # # Widget: sunshine
    # output$widget_sunshine <- renderUI(k_widget_v(id = "sunshine",
    #                                               range = c(0, 10),
    #                                               max = 8,
    #                                               title = "Sunshine (h)"))
    # 
    # # Widget: sunshine
    # output$widget_svg <- renderUI(svg)
    # 
    # 
    # # widget: 1000 obs
    # output$widget_1000 <- renderUI(k_widget_1000("x"))
    

    
  })
}

