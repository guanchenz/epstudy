#! /usr/bin/env Rscript 
# data visualization
#
# Visualizes raw data

library(tidyverse)

args <- commandArgs(trailingOnly = TRUE)
path_input <- args[1]
path_output <- args[2]

df <- read_csv(path_input)

ncols <- dim(df)[2]
ncols_freq <- round(ncols/2)

# use line to have better viz
freq_plot_full <- ggplot() +
  geom_line(aes(1:(ncols_freq-2), as.numeric(df[1, 3:ncols_freq]))) +
  scale_x_continuous("frequency") +
  scale_y_continuous("strength") +
  ggtitle("Flux strength in frequency domain")

# bar
freq_plot_zoom <- ggplot() +
  aes(1:20, as.numeric(df[1, 3:22])) +
  geom_bar(stat = 'identity', width = 0.3) +
  scale_x_continuous("frequency") +
  scale_y_continuous("strength") +
  ggtitle("Flux strength in frequency domain")

tmp2 <- as.numeric(df[2, 3:ncols])
# tmp3 <- as.numeric(df[3, 3:ncols])
flux <- ggplot() +
  geom_line(aes(1:length(tmp2), tmp2)) #+
  # geom_line(aes(1:length(tmp3), tmp), color = 'red', alpha=0.8)

ggsave(paste0(path_output, "freq_plot_full.png"), plot = freq_plot_full)
ggsave(paste0(path_output, "freq_plot_zoom.png"), plot = freq_plot_zoom)
ggsave(paste0(path_output, "flux.png"), plot = flux)
