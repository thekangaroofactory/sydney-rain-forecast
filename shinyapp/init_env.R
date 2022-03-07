

# --------------------------------------------------------------------------------
# PATH
# --------------------------------------------------------------------------------

# -- Declare path
path <- list(script = "./src/script/R",
             python_script = "./src/script/Python",
             resource = "./src/resources",
             data = "./dataset",
             formated = "./dataset/formated",
             processed = "./dataset/processed",
             download = "./dataset/downloads",
             model = "./output/models")

# --------------------------------------------------------------------------------
# FILES
# --------------------------------------------------------------------------------

file <- list(raw_dataset = file.path(path$data, "sydney_2008_2017_raw.csv"),
             model_list = "model_list.csv",
             formated = "formated_data.csv")

