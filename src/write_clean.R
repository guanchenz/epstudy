## Write processed data to csv

library(tidyverse)

exit_status <- tryCatch({
    path <- './data/exoTrainProcessed.csv'
    
    write_csv(series, path, na = "NA", append = FALSE)
    es <- 0
  }, warning = function (war) {
    paste("Warning: ", war)
    es <- 1
  }, error = function (err) {
    paste("Error: ", err)
    es <- 1
  }, finally = {
    print("Writing file successful.")
  })

exit_status