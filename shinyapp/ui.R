
# --------------------------------------------------------------------------------
# This is the user-interface definition of the Shiny web application
# --------------------------------------------------------------------------------

# -- Setup application environment
source("setup.R")

# -- Define UI
cat("------------------------------------------------\n")
cat("[UI] Building application UI \n")
cat("------------------------------------------------\n")

# Header
cat("  - Building dashboard header \n")
header <- dashboardHeader(title = "Sydney Rain Forecast")

# Sidebar
cat("  - Building sidebar \n")
sidebar <- dashboardSidebar(
    sidebarMenu(
        menuItem("Project Dashboard", tabName = "project", icon = icon("dashboard"), selected = TRUE),
        menuItem("Introduction", tabName = "introduction", icon = icon("file")),
        menuItem("Exploratory Analysis", tabName = "analyze", icon = icon("file")),
        menuItem("Missing values", tabName = "nan", icon = icon("file")),
        menuItem("Evaluation & Monitoring", tabName = "monitoring", icon = icon("file"))
        #menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard"), selected = FALSE)
        ), collapsed = FALSE)

# Body
cat("  - Building dashboard body \n")
body <- dashboardBody(
    
    # -- Include custom CSS files
    # tags$head(
    #   tags$link(rel = "stylesheet", type = "text/css", href = "kangarooai.css"),
    #   tags$link(rel = "stylesheet", type = "text/css", href = "sydney.css")
    # ),
    
    # -- To use sweet progressBar
    useSweetAlert("material-ui", ie = TRUE),
    
    tabItems(
        
        # -- TAB: Dashboard ----------------------------------------------------
        tabItem(tabName = "project",
                h2("Project Dashboard"),
                
                fluidRow(
                  column(width = 8,
                         
                         wellPanel(
                           
                           h3("Objectives"),
                           p("The projects is built around key objectives:"),
                           tags$ul(
                             tags$li("Train Machine Learning models using data from real life observations,"),
                             tags$li("Build a web application to deliver the models into a cloud production environment,"),
                             tags$li("Implement model and data live monitoring,"),
                             tags$li("Setup MLOps pipelines,"),
                             tags$li("Allow user to get an understanding of data science through playground components and a real life example.")))),
                  
                  column(width = 4, 
                         
                         h3("Version 1.3.9"),
                         p("This is a stable version of the App."),
                         tags$ul(
                           tags$li("In session Exploratory Analysis"),
                           tags$li("Missing Values (basic view)"),
                           tags$li("2 models delivered"),
                           tags$li("Live prediction & evaluation"),
                           tags$li("Automatic download of the new observations"),
                           tags$li("Automatic processing of the observations")
                           ),
                         
                         h3("Observations"),
                         p("Sep 2019 - Today")
                         
                         )),
                
                
                fluidRow(
                  column(width = 8, 
                         
                         wellPanel(
                           h3("Roadmap"),
                           tags$ol(
                             tags$li("Setup the pipeline:",
                                     tags$ul(
                                       tags$li("put in place different components"),
                                       tags$li("reuse the original project (used to be a training exercise"))),
                             tags$li("Automatize manual steps:",
                                     tags$ul(
                                       tags$li("Download new observations"),
                                       tags$li("Setup R/Python interface to reuse Python code"),
                                       tags$li("Pre-process new observations with Python"),
                                       tags$li("Make predictions using TensorFlow model"),
                                       tags$li("Evaluation model & predictions"),
                                       tags$li("Monitor model & incoming data"),
                                     )),
                             
                             tags$li("Allow user to perform live data science operation:",
                                     tags$ul(
                                       tags$li("Data exploration & analysis"),
                                       tags$li("Data cleaning & missing value"),
                                     )),
                             tags$li("Implement continuous improvement:",
                                     tags$ul(
                                       tags$li("setup error analysis to improve models.")))))),
                  
                  column(width = 4, 
                         
                         h3("GitHub"),
                         tags$a("https://github.com/kangarooaifr/sydney-rain-forecast", href = "https://github.com/kangarooaifr/sydney-rain-forecast"),
                         
                         # h3("Last Git commit"),
                         # textOutput("version_timestamp"),
                         # textOutput("version_comment"),

                         h3("Python"),
                         p("The TensorFlow/Keras interface to Python is setup through the Reticulate package.")
                         ))),
        
        # -- END: Dashboard ----------------------------------------------------
        
        
        # -- TAB: Introduction -------------------------------------------------
        tabItem(tabName = "introduction",
                h2("Introduction"),
                wellPanel(
                    
                    h3("Source"),
                    p("The original dataset is provided by the Australian Government - ", strong("Bureau of Meteorology (BOM)"), ": ", a("http://www.bom.gov.au/climate/data/", href = "http://www.bom.gov.au/climate/data/"), br(),
                    "It contains 140000+ examples, captured between 2008 and 2017 in different locations accross Australia, with daily observations and label whether there was rain or not on the next day."),
                    
                    h3("Sydney"),
                    p("To setup the new components for this application, I decided to focus on the city of Sydney.", br(),
                      "There are 6342 observations for Sydney in the main dataset.", br(),
                      "This subset will be used for the Exploratory Analysis & Missing Data sections."),
                    p("The current models have been trained using the whole dataset: one (M1) with all the data, one (M2) with balanced observations.", br(),
                      "Predictions and evaluation are performed on new observations for Sydney."),
                    
                    fluidRow(box(width = 6, map_UI("map"))),
                    
                    h3("Goals"),
                    tags$ul(
                        tags$li("Build models to predict whether it will rain on the next day,"),
                        tags$li("Focus on the ability to detect days with rain (Recall),")))),
        
        # -- END: Introduction -------------------------------------------------
        
        
        # -- TAB: Analyze ------------------------------------------------------
        tabItem(tabName = "analyze",
                
                h2("Exploratory Analysis"),
                
                # -- LOADING
                wellPanel(
                    
                    fluidRow(
                        
                        # -- Load button
                        column(width = 6,
                               h3("Load"),
                               p("First, click on below button to load and display the Sydney dataset"),
                               loadData_btn("model")),
                        
                        # -- Value boxes
                        column(width = 6,
                               rawNbFeature_UI("model"),
                               rawNbRow_UI("model"),
                               memorySize_UI("model"))),
                    
                    # -- Data explorer
                    fluidRow(
                        br(),
                        ItemTable_UI("model"))),
                
                
                # -- PREPROCESSING
                wellPanel(
                    
                    fluidRow(
                        
                        # -- Text & buttons
                        column(width = 6,
                               
                               h3("Init / reset dataset"),
                               p("Now, let's duplicate the original (raw) dataset so that we can reset the data at any time if something goes wrong."),
                               p("A Month column is also added to track seasonality during analysis, so there will be one more feature."),
                               resetData_btn("model"),
                               
                               h3("Drop feature"),
                               p("The following features need to be removed:"),
                               tags$ul(
                                   tags$li(strong("Location"), ": there are only two values (Sydney / SydneyAirport) which are very close."),
                                   tags$li(strong("RISK_MM"), ": this value is linked to RainTomorrow (forecasts the expected amout of rain).")),
                               dropFeature_btn("model")),
                        
                        # -- Value boxes
                        column(width = 6,
                               wipNbFeature_UI("model"),
                               wipNbRow_UI("model")))),
                
                
                # -- ANALYZE
                wellPanel(
                    
                    fluidRow(
                        
                        column(width = 12,
                               
                               h3("Analyze"),
                               p("The data exploratory analysis helps to understand the different variables in the dataset."),
                               p("This includes the following items:"),
                               tags$ul(
                                   tags$li("Type: type and format of the variable (Date, Numeric, Character..)"),
                                   tags$li("Distribution: range of values, outliers"),
                                   tags$li("Correlation: how do they interact with each other?"),
                                   tags$li("Correlation with target: how do they link with Rain / NoRain.")),
                               h3("Imbalanced dataset"),
                               p("The dataset is very imbalanced, meaning that one prediction class (rain tomorrow) has much fewer examples as compared to the other class (no rain tomorrow).", br(),
                                 "This will actually be one of the main challenge since we want to retrieve the days with rain."))),
                        
                    fluidRow(
                        
                        column(width = 6,
                               
                               balancePlot_UI("analyze")),
                        
                        column(width = 6,
                               
                               nbRainObs_UI("analyze"),
                               nbNoRainObs_UI("analyze"))),
                    
                    fluidRow(
                        
                        column(width = 12,
                               
                               h3("Numerical / Categorical"),
                               p("At this point, we will consider as numerical any variable with.. numbers (integer or float).", br(),
                                 "And as categorical all others (character)", br(),
                                 "Later on, we may decide that a numerical variable falls in fact under the categorical onces (See Feature Engineering)."),
                               
                               getTypes_btn("analyze"),
                               
                               h4("Numerical variables:"),
                               tags$i(wipNumFeat_UI("analyze")),
                               h4("Categorical variables:"),
                               tags$i(wipCatFeat_UI("analyze"))))),
                
                
                # -- NUMERICAL FEATURES
                wellPanel(
                    
                    fluidRow(
                        column(width = 6,
                               h3("Numerical Features Analysis"),
                               p("Select a variable to display the analysis."),
                               selectNumerical_input("analyze"),
                               tags$i("The list is empty until the 'Get Types' button from the previous tab is hit.")),
                        
                        column(width = 6,
                               singleBox_PLOT("analyze"))),
                    
                    fluidRow(
                        column(width = 6,
                               singleDist_PLOT("analyze")),
                        
                        column(width = 6,
                               timeBox_PLOT("analyze")))),
                
                
                # -- CORRELATION
                wellPanel(
                    
                    fluidRow(
                        
                        column(width = 6,
                               h3("Numerical features"),
                               getCorrelation_btn("analyze"),
                               wipCorrTxt_UI("analyze")),
                        
                        column(width = 6,
                               wipCorrelationPlot_UI("analyze"))))),
        
        
        
        # -- END: Analyze ------------------------------------------------------
    
        
        # -- TAB: Missing values -----------------------------------------------
        tabItem(tabName = "nan",
                
                h2("Missing Values"),
                
                fluidRow(
                    
                    column(width = 8,
                           wellPanel(
                               
                               p("Missing values in datasets are always a challenge (struggle) to deal with. Somehow, you have to set up a strategy to fix them before training the model.", br(),
                                 "- by deleting rows or features if they appear too weak", br(),
                                 "- by filling the empty values with some strategy"),
                               
                               h3("1. Drop observations"),
                               p("Because they are too weak, we are going to drop the rows with 5 and more empty values. They also represent 0.39% of the total dataset, which makes the effort to fix them too costly."),
                               dropRows_btn("nan"),
                               
                               h3("2. Get priorities"),
                               p("Now let's get a sense of priorities. Fixing a feature (variable) with a single missing value won't have much impact on our model. On the other hand, it makes sense to
                                                      try different strategies on a feature with many missing values in order to optimize the model."),
                               p("So let's get an ordered list of the features with > 1% missing values."),
                               getNaPriorities_btn("nan"))),
                    
                    column(width = 4,
                           fluidRow(
                               box(width = "70%",
                                   h3("Missing values by row"),
                                   naByRow_UI("nan"),
                                   nbFullRow_UI("nan"))),
                           
                           fluidRow(
                               box(width = "auto",
                                   h3("Missing values by feature"),
                                   naByFeature_UI("nan")))))),
                
        # -- END: Missing values -----------------------------------------------
        
        
        # -- TAB: Monitoring ---------------------------------------------------
        tabItem(tabName = "monitoring",
                
                h2("Evaluation & Monitoring"),
                
                # -- 1St row: Select model & data
                fluidRow(
                    
                    column(width = 6, 
                           wellPanel(
                               selectModel_INPUT("check"),
                               summary_UI("check"))),
                    
                    column(width = 6, 
                           wellPanel(
                               h3("Test data"),
                               p("The test dataset is made of Sydney weather observations collected from the Australian BOM since Septembre, 2019.
                                 It is (for now) manually downloaded and pre-processed using python scripts on monthly basis."),
                               nbObs_UI("check")))),
                
                wellPanel(
                    fluidRow(
                        column(width = 12, 
                               h3("Observations"),
                               p("There is one extra row corresponding to today's observation (it's avaible as an incomplete row until the next day)."),
                               itemTable_UI("check")))),
                
                
                # -- 2nd row: ROC Curve & AUC
                wellPanel(
                    fluidRow(
                        #column(width = 12, 
                               
                               column(width = 3, 
                                      h3("ROC Curve"),
                                      rocPlot_UI("check")),
                               column(width = 3, 
                                      h3("Area Under Curve"),
                                      auc_roc_UI("check"),
                                      p("ROC curves may provide an excessively optimistic view of the performance for highly imbalanced datasets.
                                        This is true with model M1: the dataset is highly screwed with only ~20% positive examples.")),
                
                
                
                # -- 3rd row: Precision/Recall Curve & AUC
                #wellPanel(
                    #fluidRow(
                        #column(width = 12, 
                               
                               column(width = 3, 
                                      h3("Precision/Recall Curve"),
                                      prPlot_UI("check")),
                               column(width = 3, 
                                      h3("Area Under Curve"),
                                      auc_pr_UI("check"),
                                      p("Precision and recall make it possible to assess the performance of a classifier on the minority class.")))),
                
                
                # -- 4th row: playground and monitoring
                wellPanel(
                    
                    # -- introduction
                    fluidRow(
                        column(width = 6, 
                               h3("Playground"),
                               tags$ul(
                                   tags$li("Select threshold to turn raw predictions into binary values (No rain / Rain),"),
                                   tags$li("Select date range to focus on a specific period of time.")))),
                    
                    
                    # -- input
                    fluidRow(
                        column(width = 3, 
                               thresholdSlider_INPUT("check")),
                        column(width = 4,
                               dateRange_INPUT("check"))),
                        
                    
                    # -- accuracy
                    fluidRow(
                        column(width = 6,
                               h3("Predictions & Accuracy"))),
                    fluidRow(
                        column(width = 3, nbSelectedObs_UI("check")),
                        column(width = 3, nbPredictionOK_UI("check")),
                        column(width = 3, nbPredictionKO_UI("check")),
                        column(width = 3, accuracy_UI("check"))),
                    
                    # -- confusion matrix
                    fluidRow(
                        column(width = 6, 
                               h3("Confusion Matrix"), 
                               confusionPlot_UI("check")),
                        column(width = 6, 
                               h3("Precision / Recall"),
                               precision_UI("check"),
                               recall_UI("check"),
                               f1Score_UI("check"))),
                    
                    # -- prediction density
                    fluidRow(
                        column(width = 6,
                               predictionDensityPlot_UI("check")),
                        column(width = 6,
                               accuracyDensityPlot_UI("check"))),
                    # fluidRow(
                    #     column(width = 6,
                    #            TPDensityPlot_UI("check")),
                    #     column(width = 6,
                    #            FPDensityPlot_UI("check"))),
                    # fluidRow(
                    #     column(width = 6,
                    #            TNDensityPlot_UI("check")),
                    #     column(width = 6,
                    #            FNDensityPlot_UI("check"))),
                    fluidRow(
                        column(width = 6,
                               RainPredictionDensityPlot_UI("check")),
                        column(width = 6,
                               NoRainPredictionDensityPlot_UI("check")))
                    )
                
        )
        
        # -- END: Monitoring ---------------------------------------------------
        
        
        # -- TAB: Dashboard ---------------------------------------------------
        # tabItem(tabName = "dashboard",
        # 
        #         h2("Weather Dashboard"),
        # 
        # 
        #         fluidRow(column(width = 4,
        #                         widget_date_UI("dashboard"))),
        # 
        #         fluidRow(column(width = 4,
        #                         widget_temperature_UI("dashboard")),
        #                  column(width = 4,
        #                         widget_sunshine_UI("dashboard"))),
        # 
        #         fluidRow(column(width = 4,
        #                         widget_1000_UI("dashboard")))
        # )
        
        # -- END: Dashboard ---------------------------------------------------
                  

    ) # -- tabItems
) # -- dashboardBody


# -- Put them together into a dashboard
cat("Building final dashboard UI \n")

dashboardPage(
    header,
    sidebar,
    body)

