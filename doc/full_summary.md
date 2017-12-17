---
title: "auto_summary"
author: "Guanchen Zhang"
date: "December 15, 2017"
output: 
  html_document:
    keep_md: yes
---



## Auto-generated summary (Full verison)


```r
# load libraries
library(tidyverse)
```

### Overview

This summary shows the following:

-   Load the flux data and understand the data format
-   Plot the data to understand the data
-   Perform data processing the plot the processed data
-   Demonstrate a sample classification using a pre-compiled naive machine learning model

### Load the data

The flux data in csv format downloaded from Kaggle is first compressed to rds. Below shows how to load the compressed training data.


```r
raw <- readRDS('./data/exoTrain.rds')

# Show the first 9 columns of star 2, 10, 20, 50, 60, 70
head(raw[c(2, 10, 20, 50, 60, 70), 1:9])
```

```
## # A tibble: 6 x 9
##   LABEL  FLUX.1  FLUX.2  FLUX.3  FLUX.4  FLUX.5  FLUX.6  FLUX.7  FLUX.8
##   <int>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>
## 1     2  -38.88  -33.83  -58.54  -40.09  -79.31  -72.81  -86.55  -85.33
## 2     2 -265.91 -318.59 -335.66 -450.47 -453.09 -561.47 -606.03 -712.72
## 3     2  560.19  262.94  189.94  185.12  210.38  104.19  289.56  172.06
## 4     1 -355.12 -348.74 -373.37 -362.00 -291.00 -195.00  -77.12 -161.37
## 5     1  -42.97 -127.45 -101.61  -98.31  -71.39  -71.73  -84.81  -68.61
## 6     1 -115.54  -96.29 -103.12  -97.60  -79.73  -61.62  -77.75  -60.79
```

As shown above, the data consist of a `LABEL` column and `FLUX` columns (measured at different times). `LABEL` refers to whether the star is confirmed to have at least one planet. `2` indicates yes and `1` refers to no.

`FLUX` refers to the brightness over area measured in the [Kepler Mission](https://www.nasa.gov/mission_pages/kepler/main/index.html). Negative `FLUX` means there is some object (potentially exoplanets) blocks the star. Positive `FLUX` could indicate spot or other interference in the space.


### Interpret the data

One approach for detecting exoplanets is based on [transit](https://en.wikipedia.org/wiki/Methods_of_detecting_exoplanets#Transit_photometry). When the star and any of its exoplanets are aligned with Kepler's observation point, the flux measured by Kepler would decrease. When the exoplanet no longer blocks the light, the flux will increase.

Below show the flux time series for the selected star. We are mainly interested in the downward peaks that correspond to the possibility that some planet periodically blocks the light.

_Original flux data_

![flux time series](../results/figures/flux_original.png)


### Load external functioins for data analysis

The `dat_utils` script includes data utility functions that remove the outliers and perform Fourier Transform.


```r
source("./src/dat_utils.R")
```


### Filter the data and apply fourier transform

From the plot above, we may see some positive peaks that do not occur periodically and we do not know what caused these positive peaks. In transit, because we mainly consider the negative peaks, we may consider filtering out these positive peaks.

Another thing to consider is to apply Fourier Transform on the flux data in time series. Because the time series data could be interferred by unknown sources which may not be periodical, we may transform the time series data to the frequency domain to find periodical patterns. However, the effectivenss of the transformation in detecting exoplanets remain to be studied.


```r
# define star index first
# star_index <- 3

# get flux series for one star
series0 <- raw[star_index, ]

# remove outliers
series_filtered <- rm_upper_outlier(series0)

# fourier transform
xk <- fft(as.numeric(series_filtered[2:length(series_filtered)]))  # this returns a vector of complex numbers
harmonics <- 2 * Mod(xk)  # complex numbers to real
series_fft <- as_tibble(t(harmonics))
series_fft <- series_fft %>%
  mutate(LABEL = raw[star_index, ]$LABEL) %>%
  select(LABEL, everything())

# set the column names of series_fft to be same as raw
names(series_fft) <- colnames(raw)

# results
df <- series_fft
df[2,] <- series_filtered
df[3,] <- series0
df <- df %>% mutate(type = c('frequency', 'time_filtered', 'time0')) %>%
  select(type, everything())
```


### Visualize flux data in time and frequency domains

_Filtered vs. original flux data_

![flux_compare](../results/figures/flux_compare.png)

_Flux data in frequency domain (full spectrum)_

![fft_full](../results/figures/freq_plot_full.png)

_Flux data in frequency domain (zoomed in)_

![fft](../results/figures/freq_plot_zoom.png)


### Classifying whether a star has exoplanet

Below shows a very simple random forest model (in `./bin/`) that takes the flux time series ad input and classifies whether the star has exoplanets.

One of the challenges in the building the model is that the training data is extremely unbalanced, that is, only 37 out of 5000 stars have exoplanents. To tackle this issue, I divide each observation (a flux time series for a star) into 3 segments, assuming each segment is for one star. Thus, I can achieve `37*3=111` observations in the training set for stars that have exoplanets.

To further address the unbalance in training data, the random forest model is trained with `balance_classes=TRUE`. For details of how to build this model, please refer to `./src/build_mdl_reduce.R`.


```r
## Build Random Forest model based on raw data

library(h2o)

h2o.init(nthreads = -1)

col_range <- 1:1066  # specify data range

# load data from csv or rds
# test_raw <- read_csv("../data/exoTest.csv")
test_raw <- readRDS('../data/exoTest.rds')

# apply FFT or not
dat_test_f_raw <- test_raw #toFFT(test_raw[, 1:1066])

# to h2o dataframe
dat_test2 <- as.h2o(dat_test_f_raw[, col_range], destination_frame="dat_test2")
dat_test2$LABEL <- as.factor(dat_test2$LABEL)
col_range <- 1:dim(dat_test2)[2]

# scale the data using h2o.scale
# dat_test_scaled2 <- dat_test2
# dat_test_scaled2[, 2:dim(dat_test_scaled2)[2]] <- h2o.scale(dat_test_scaled2[, 2:dim(dat_test_scaled2)[2]]) 

# load the pre-built model
rf_model <- h2o.loadModel("../bin/rf_fit2")

# tests
rf_perf <- h2o.performance(model = rf_model,
  newdata = dat_test2[, col_range])

rf_perf
```


```r
errors <- read_csv("./results/errors.csv")
confusion <- read_csv("./results/confusion.csv")
```


```
## # A tibble: 1 x 2
##           mse       auc
##         <dbl>     <dbl>
## 1 0.008707997 0.9711504
```


```
## # A tibble: 3 x 4
##     `1`   `2`      Error    Rate
##   <int> <int>      <dbl>   <chr>
## 1   549    16 0.02831858 =16/565
## 2     1     4 0.20000000    =1/5
## 3   550    20 0.02982456 =17/570
```

The results show that the model needs further training. Possible improvement could include:

-   obtain more training and testing data or generate new data from the available data
-   further filter the data to extract better features and to remove noise
-   select a better model that fits the problem (possibly recurrent NN)

Nevertheless, we can use the results to locate where the errors occur and to have a close look at the specific stars to find any irregularities.
