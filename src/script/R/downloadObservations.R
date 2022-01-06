
library (RCurl)


# -- param
year <- "2021"
month <- "12"
station <- "IDCJDW2124"


# -- prepare target url
target_url <- "http://www.bom.gov.au/climate/dwo/"
target_url <- paste(target_url, year, month, "/text/", sep = "")
target_url <- paste(target_url, station, ".", year, month, ".csv", sep = "")

print(target_url)

# -- download target url
download <- getURL(target_url)

# -- drop extra line breaks and save to file
download <- gsub('[\r]','', download)


# -- prepare file name
target_file <- paste(station, paste(year,month, sep = ""), "csv", sep = ".")
target_file <- file.path(path$download, target_file)

# -- write file
write(download, target_file)
