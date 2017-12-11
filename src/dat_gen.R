#! /usr/bin/env Rscript
#
# Generate new data for training/testing in case of 
# unbalanced data

library(tidyverse)

train_raw <- read_csv("./data/exoTrain.csv")

test_set <- train_raw[1, 1:20]

divide_to_equal <- function(row, star_label) {
  cut_proportion <- floor((length(row) - 1) / 3)  # -1 to account for that the first col is labels
  # divide into equal length
  ranges <- list(1:(1 + cut_proportion),
    (1 + cut_proportion + 1):(1 + cut_proportion + cut_proportion),
    (1 + cut_proportion + cut_proportion + 1):(1 + cut_proportion + cut_proportion + cut_proportion))
  # star_label <- as.integer(train_raw[1,1])  # label
  attrs <- names(row[1, ranges[[1]]])  # column names
  
  dat_red <- row[1, ranges[[1]]]  # assign the first row first
  
  for (i in 2:length(ranges)) {
    tmp <- row[1, ranges[[i]]]
    tmp$LABEL <- star_label
    tmp <- tmp %>%
      select(LABEL, everything())
    names(tmp) <- attrs
    dat_red[i, ] <- tmp
  }
  
  return(dat_red)
}

dat_train_reduced <- divide_to_equal(train_raw[1, ], train_raw[1, ]$LABEL)
for (k in 2:nrow(train_raw)) {
  star_label <- train_raw[k, ]$LABEL
  tmp <- divide_to_equal(train_raw[k, ], star_label)
  dat_train_reduced <- bind_rows(dat_train_reduced, tmp)
}

test_raw <- read_csv("./data/exoTest.csv")
dat_test_reduced <- divide_to_equal(test_raw[1, ], test_raw[1, ]$LABEL)
for (k in 2:nrow(test_raw)) {
  star_label <- test_raw[k, ]$LABEL
  tmp <- divide_to_equal(test_raw[k, ], star_label)
  dat_test_reduced <- bind_rows(dat_test_reduced, tmp)
}

saveRDS(dat_train_reduced, "./data/exoTrainReduced.rds")
saveRDS(dat_test_reduced, "./data/exoTestReduced.rds")

# ncols <- dim(test_set)[2]
# cut_proportion <- round((ncols - 1) / 3)
# ranges <- list(1:(1 + cut_proportion),
#               (1 + cut_proportion + 1):(1 + cut_proportion + cut_proportion),
#               (1 + cut_proportion + cut_proportion + 1):(1 + cut_proportion + cut_proportion + cut_proportion))
# 
# star_lab <- as.integer(train_raw[1,1])
# attrs <- names(test_set[ranges[[1]]])
# 
# dat_red <- test_set[1, ranges[[1]]]
# 
# for (i in 2:length(ranges)) {
#   tmp <- test_set[1, ranges[[i]]]
#   tmp$LABEL <- star_lab
#   tmp <- tmp %>%
#     select(LABEL, everything())
#   names(tmp) <- attrs
#   dat_red[i, ] <- tmp
# }
