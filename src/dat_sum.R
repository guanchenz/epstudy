#! /usr/bin/env Rscript 
# dat_sum.R
# 
# This script extracts the data for one star and performs
# Fourier Transform. The output csv file contains both the
# original flux time series and the data after Fourier Transform
#
# e.g. Rscript src/dat_sum.R ./data/exoTrain.rds ./data/quick_summary.csv 3

library(tidyverse)

args <- commandArgs(trailingOnly = TRUE)
path_input <- args[1]
path_output <- args[2]
star_index <- args[3]

raw <- readRDS(path_input)
df_raw <- as_tibble(raw)
star_index <- as.integer(star_index)

# load external functions for data processing
source("./src/dat_utils.R")

# get flux series for one star
series0 <- df_raw[star_index, ]

# remove outliers
series_filtered <- rm_upper_outlier(series0)

# fourier transform
xk <- fft(as.numeric(series_filtered[2:length(series_filtered)]))  # this returns a vector of complex numbers
harmonics <- 2 * Mod(xk)  # complex numbers to real
series_fft <- as_tibble(t(harmonics))
series_fft <- series_fft %>%
  mutate(LABEL = df_raw[star_index, ]$LABEL) %>%
  select(LABEL, everything())

names(series_fft) <- colnames(df_raw)

# results
df <- series_fft
df[2,] <- series_filtered
df <- df %>% mutate(type = c('frequency', 'time')) %>%
  select(type, everything())

write_csv(df, path_output)
