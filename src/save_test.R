#! /usr/bin/env Rscript
#
# Build Random Forest model based on raw data (no removing outliers).
# Save the selected test results to csv. Using h2o functions to 
# change the output you want to save.

library(tidyverse)
library(h2o)

h2o.init(nthreads = -1)

col_range <- 1:1066  # to-do: change this to a var, now only use half of the data

## Load csv or rds
# test_raw <- read_csv("../data/exoTest.csv")
test_raw <- readRDS('./data/exoTest.rds')

## Apply FFT or not
dat_test_f_raw <- test_raw #toFFT(test_raw[, 1:1066])

## To h2o dataframe
dat_test2 <- as.h2o(dat_test_f_raw[, col_range], destination_frame="dat_test2")
dat_test2$LABEL <- as.factor(dat_test2$LABEL)
col_range <- 1:dim(dat_test2)[2]

# Scale the data using h2o.scale
# dat_test_scaled2 <- dat_test2
# dat_test_scaled2[, 2:dim(dat_test_scaled2)[2]] <- h2o.scale(dat_test_scaled2[, 2:dim(dat_test_scaled2)[2]]) 

## Load the pre-built model
rf_model <- h2o.loadModel("../bin/rf_fit2")

## Test
rf_perf <- h2o.performance(model = rf_model,
  newdata = dat_test2[, col_range])

# rf_perf


## Save test results to csv for rendering in Rmd
results.error <- tibble(
  mse = h2o.mse(rf_perf),
  auc = h2o.auc(rf_perf)
)
results.confusion <- as_tibble(h2o.confusionMatrix(rf_perf))

path1 <- "./results/errors.csv"
write_csv(results.error, path1, na = "NA", append = FALSE)
path2 <- "./results/confusion.csv"
write_csv(results.confusion, path2, na = 'NA', append = FALSE)
