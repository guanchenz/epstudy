#! /usr/bin/env Rscript 
# dat_prep.R
# 
# This script reads the downloaded data, compresses the data, 
# and saves it to a compressed format.

library(tidyverse)

args <- commandArgs(trailingOnly = TRUE)
path_input <- args[1]
path_output <- args[2]

exit_status <- tryCatch({
  dat_raw_train <- read_csv(path_input)
  saveRDS(dat_raw_train, file = path_output)  # save the compressed
  es <- 0
}, warning = function (war) {
  paste("Warning: ", war)
  es <- 1
}, error = function (err) {
  paste("Error: ", err)
  es <- 1
}, finally = {
  print("CSV loaded successfully.")
})

exit_status

