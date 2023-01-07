


# -- Detect local run
is_local <- Sys.getenv('SHINY_PORT') == ""

# -- Detect if code run in shiny
is_shiny <- shiny::isRunning()

# -- Debug
DEBUG <- ifelse(is_local, TRUE, FALSE)



# --------------------------------------------------------------------------------
# PATH
# --------------------------------------------------------------------------------

# -- project path
home <- if(!is_shiny) "./shinyapp" else "."

# -- Declare path
path <- list(script = file.path(home, "src/script/R"),
             python_script = file.path(home, "src/script/Python"),
             resource = file.path(home, "src/resources"),
             data = file.path(home, "dataset"),
             formated = file.path(home, "dataset/formated"),
             processed = file.path(home, "dataset/processed"),
             download = file.path(home, "dataset/downloads"),
             model = file.path(home, "output/models"),
             schema = file.path(home, "output/schemas"))


# --------------------------------------------------------------------------------
# FILES
# --------------------------------------------------------------------------------

file <- list(raw_dataset = file.path(path$data, "sydney_2008_2017_raw.csv"),
             model_list = "model_list.csv",
             formated = "formated_data.csv",
             processed = "processed_dataset_v1.csv",
             dataset_report = "dataset_report.json",
             means_by_location = "means_by_location.csv",
             mapping_Location = "mapping_Location.csv")

