
# --------------------------------------------------------------------------------
# This is the user-interface definition of the Shiny web application
# --------------------------------------------------------------------------------

# -- Library

library(shiny)
library(shinydashboard)
library(DT)

# -- Modules
source(file.path("./src/script/R", "map.R"))
source(file.path("./src/script/R", "dataset.R"))
source(file.path("./src/script/R", "analyze.R"))
source(file.path("./src/script/R", "missingValues.R"))
source(file.path("./src/script/R", "reccurentCheck.R"))

# -- Define UI

# Header
header <- dashboardHeader(title = "Sydney Rain Forecast")

# Sidebar
sidebar <- dashboardSidebar(
    sidebarMenu(
        menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard"), selected = TRUE),
        menuItem("Dataset", tabName = "dataset", icon = icon("file")),
        menuItem("Exploratory Analysis", tabName = "analyze", icon = icon("file")),
        menuItem("Missing values", tabName = "nan", icon = icon("file")),
        menuItem("Monitoring", tabName = "monitoring", icon = icon("file"))
    )
)

# Body
body <- dashboardBody(
    
    useSweetAlert("material-ui", ie = TRUE),
    
    tabItems(
        
        # TAB: Dashboard
        tabItem(tabName = "dashboard",
                h2("Dashboard"),
                wellPanel(
                    
                    h3("*** Draft version ***"),
                    p("This is a draft (development) version of the App. It will be updated when new (and stable) content is added."),
                    p("The goal of this App is to put into production a rain prediction model based on Machine Learning, evaluate it in real
                      time with new observations, and demonstrate how AI and Data Science work."),
                    
                    h3("Current Content"),
                    tags$ul(
                        tags$li("Introduction"),
                        tags$li("Load dataset, preprocess"),
                        tags$li(span("Exploratory Analysis ~InWork", style = "color:blue")),
                        tags$li(span("Missing values ~Draft", style = "color:blue")),
                        tags$li(span("Feature engineering ~NotImplemented", style = "color:grey; font-style: italic")),
                        tags$li(span("Train model ~NotImplemented", style = "color:grey; font-style: italic")),
                        tags$li(span("Monitoring ~InWork", style = "color:blue"))
                    ),
                    
                    h3("How it works"),
                    p("Go down through the sidebar item list, then use the main area tabs from left to right."),
                    p("All operations, plots are done live with the real data in memory."),
                    
                    balancePlot_UI("analyze")
                    
                )
                
        ),
        
        # TAB: Dataset
        tabItem(tabName = "dataset",
                h2("Dataset"),
                
                tabsetPanel(type = "tabs",
                            
                            # -- INTRO
                            tabPanel("Introduction",
                                     wellPanel(
                                         h3("Source"),
                                         p("The original dataset is provided by the Australian Government - ", strong("Bureau of Meteorology (BOM)"), ": ", a("http://www.bom.gov.au/climate/data/", href = "http://www.bom.gov.au/climate/data/")),
                                         p("It contains 140000+ examples, captured between 2008 and 2017 in different locations accross Australia, with daily observations and label whether there was rain or not on the next day.", br(),
                                           "Goal is to predict whether or not it will rain on the next day.")
                                         ,
                                         h3("Sydney"),
                                         p("For this application, and because I want to setup in place some sort of reccurence, I decided to focus on the city of Sydney.", br(),
                                           "The dataset used for this app is a subset of the BOM dataset containing 6342 observations for Sydney."),
                                         fluidRow(box(width = 6, map_UI("map")))
                                     )
                            ),
                            
                            # -- LOADING
                            tabPanel("Load",
                                     fluidRow(
                                         column(width = 6,
                                                wellPanel(
                                                    h3("Load"),
                                                    p("Click on below button to load and display the Sydney dataset"),
                                                    loadData_btn("model"))),
                                         column(width = 6,
                                                rawNbFeature_UI("model"),
                                                rawNbRow_UI("model"))
                                     ),
                                         
                                      
                                     fluidRow(
                                         box(title = "Explorer", width = 12, status = "primary", height = "500", solidHeader = T, itemTable_UI("model"))
                                     )
                            )
                )
        ),
        
        # TAB: Analyze
        tabItem(tabName = "analyze",
                h2("Exploratory Analysis"),
                tabsetPanel(type = "tabs",
 
                            # -- PREPROCESSING
                            tabPanel("Preprocessing",
                                     
                                     fluidRow(
                                         column(width = 6,
                                                wellPanel(
                                                    
                                                    h3("1. Init / reset dataset"),
                                                    p("First, let's duplicate the original (raw) dataset so that we can reset the data at any time if something goes wrong."),
                                                    resetData_btn("model"),
                                                    
                                                    h3("2. Drop feature"),
                                                    p("The following features need to be removed:", br(),
                                                      "- ", strong("Location"), ": there are only two values (Sydney / SydneyAirport) which are very close.", br(),
                                                      "- ", strong("RISK_MM"), ": this value is linked to RainTomorrow (forecasts the expected amout of rain)."),
                                                    dropFeature_btn("model"))),
                                         
                                         column(width = 6,
                                                p("Dataset size:"),
                                                wipNbFeature_UI("model"),
                                                wipNbRow_UI("model")))),
                            
                            # -- INTRODUCTION
                            tabPanel("Introduction",
                                     fluidRow(
                                         column(width = 8,
                                                wellPanel(
                                                    h3("Introduction"),
                                                    p("The data exploratory analysis helps understanding the different variables in the dataset."),
                                                    p("This includes the following items:", br(),
                                                      "- type: type and format of the variable (Date, Numeric, Character..)",br(),
                                                      "- distribution: range of values, outliers",br(),
                                                      "- correlation: how do they interact with each other?"),
                                                    h3("Numerical / Categorical"),
                                                    p("At this point, we will consider as numerical any variable with.. numbers (integer or float).", br(),
                                                      "And as categorical all others (character)", br(),
                                                      "Later on, we may decide that a numerical variable falls in fact under the categorical onces (See Feature Engineering)."),
                                                    getTypes_btn("analyze"),
                                                    h4("Numerical variables:"),
                                                    tags$i(wipNumFeat_UI("analyze")),
                                                    h4("Categorical variables:"),
                                                    tags$i(wipCatFeat_UI("analyze"))
                                                )
                                         ))
                            ),
                            
                            # -- NUMERICAL
                            tabPanel("Numerical",
                                     
                                     wellPanel(
                                         
                                         fluidRow(
                                             column(width = 6,
                                                    h3("Analysis"),
                                                    p("Select a variable to display the analysis."),
                                                    selectNumerical_input("analyze"),
                                                    tags$i("The list is empty until the 'Get Types' button from the previous tab is hit.")
                                             ),
                                             
                                             column(width = 6,
                                                    singleBox_PLOT("analyze")
                                             )
                                         ),
                                         
                                         fluidRow(
                                             column(width = 6,
                                                    singleDist_PLOT("analyze")
                                                    ),
                                             
                                             column(width = 6,
                                                    timeBox_PLOT("analyze")
                                             )
                                         )
                                         
                                     )
                                     
                            ),
                            
                            # -- CORRELATION
                            tabPanel("Correlation",
                                     fluidRow(
                                         column(width = 8,
                                                wellPanel(
                                                    h3("Numerical features"),
                                                    getCorrelation_btn("analyze"),
                                                    wipCorrTxt_UI("analyze")
                                                )
                                         ),
                                         
                                         column(width = 4,
                                                wipCorrelationPlot_UI("analyze")
                                         )
                                     ))
                )
                
        ),
        
        # TAB: Missing values
        tabItem(tabName = "nan",
                h2("Missing Values"),
                tabsetPanel(type = "tabs",
                            
                            # -- MISSING VALUES
                            tabPanel("Missing Values",
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
                                                    getNaPriorities_btn("nan")
                                                    
                                                )
                                         ),
                                         column(width = 4,
                                                fluidRow(
                                                    box(width = "70%",
                                                        h3("Missing values by row"),
                                                        naByRow_UI("nan"),
                                                        nbFullRow_UI("nan")
                                                    )),
                                                fluidRow(
                                                    box(width = "auto",
                                                        h3("Missing values by feature"),
                                                        naByFeature_UI("nan")
                                                    ))
                                         )
                                     )
                            )
                )
                
        ), #tabItem -- ENDTAB: Missing values
        
        
        # TAB: Monitoring
        tabItem(tabName = "monitoring",
                
                h2("Monitoring"),
                
                fluidRow(
                    
                    # input panel
                    column(width = 4,
                           wellPanel(
                               selectModel_INPUT("check"),
                               thresholdSlider_INPUT("check")
                           )),
                    
                    column(width = 4,
                        wellPanel(
                            summary_UI("check"),
                        )
                    )),
                
                fluidRow(
                    column(width = 3, nbObs_UI("check")),
                    column(width = 3, nbPredictionOK_UI("check")),
                    column(width = 3, nbPredictionKO_UI("check")),
                    column(width = 3, accuracy_UI("check"))),
                
                fluidRow(
                    column(width = 6, box(width = 12, title = "Confusion Matrix", confusionPlot_UI("check"))),
                    column(width = 6, precision_UI("check"),
                           recall_UI("check"),
                           f1Score_UI("check"))),
                
                fluidRow(
                    column(width = 6, box(width = 12, title = "ROC Curve", rocPlot_UI("check"))),
                    column(width = 6, auc_UI("check")))
                
                
                #itemTable_UI("check")
                
        ) #tabItem -- ENDTAB: Reccurent check
        
        
    ) #tabItems
) #dashboardBody


# -- Put them together into a dashboard

dashboardPage(
    header,
    sidebar,
    body
)

