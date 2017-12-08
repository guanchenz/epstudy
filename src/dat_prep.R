# Prep data: read, process, clean

library(tidyverse)


dat_raw_train <- read_csv("./data/exoTrain.csv")

plot_flux_series <- function(star_idx, dat) {
  h_train <- t(dat[star_idx,])
  h_train <- h_train[2:length(h_train)]
  h_train <- tibble(
    time = 1:length(h_train),
    flux = h_train
  )
  
  h_train %>%
    ggplot(aes(x = time, y = flux)) + geom_path()
}

plot_flux_hist <- function(start_idx, dat) {
  h_train <- t(dat[star_idx,])
  h_train <- h_train[2:length(h_train)]
  h_train <- tibble(
    time = 1:length(h_train),
    flux = h_train
  )
  
  h_train %>%
    ggplot() + geom_histogram(aes(flux), bins = 40)
}

star_idx <- 3 #1525

plot_flux_series(star_idx, dat_raw_train)

plot_flux_hist(star_idx, dat_raw_train)
