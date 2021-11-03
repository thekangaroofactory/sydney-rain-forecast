

# --------------------------------------------------------------------------------
# PATH
# --------------------------------------------------------------------------------

# -- Declare path
path <- list(script = "./src/script/R",
             data = "./dataset",
             formated = "./dataset/formated",
             processed = "./dataset/processed",
             model = "./output/models")

# --------------------------------------------------------------------------------
# FILES
# --------------------------------------------------------------------------------

file <- list(raw_dataset = file.path(path$data, "sydney_2008_2017_raw.csv"),
             model_list = "model_list.csv",
             formated = "formated_data.csv")


# --------------------------------------------------------------------------------
# SOURCES
# --------------------------------------------------------------------------------

# source("D:/Work/R/Library/Correlation/correlation.R")
# source("D:/Work/R/Library/Correlation/getLinearModel.R")
# source("D:/Work/R/Library/NaN/na_tools.R")
# source("D:/Work/R/Library/Stats/meanByGroup.R")
# source("D:/Work/R/Library/Dataframe/dataframe.R")
# source("D:/Work/R/Library/Plot/plot_tools.R")

#library(kangarooAI)