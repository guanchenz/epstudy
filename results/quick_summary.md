quick\_results
================
GZ
December 10, 2017

Quick results that visualize the flux data and the machine learning prediction
------------------------------------------------------------------------------

``` r
# load libraries
library(tidyverse)
```

    ## Loading tidyverse: ggplot2
    ## Loading tidyverse: tibble
    ## Loading tidyverse: tidyr
    ## Loading tidyverse: readr
    ## Loading tidyverse: purrr
    ## Loading tidyverse: dplyr

    ## Conflicts with tidy packages ----------------------------------------------

    ## filter(): dplyr, stats
    ## lag():    dplyr, stats

### Load the data from rds

The flux data in csv format is first compressed to rds. Below shows how to load the compressed training data.

``` r
# read training data from rds
raw <- readRDS('../data/exoTrain.rds')
# index of the selected star to plot
star_index <- 3
```

### Quick look at the data

As shown below, the data consist of a `LABEL` column and `FLUX` columns (measured at different times). `LABEL` refers to whether the star is confirmed to have at least one planet. `2` indicates yes and `1` refers to no.

`FLUX` refers to the brightness over area measured in the [Kepler Mission](https://www.nasa.gov/mission_pages/kepler/main/index.html). Negative `FLUX` means there is some object blocks the star. Positive `FLUX` could indicate spot or other interference in the space.

``` r
head(raw[, 1:10])
```

    ## # A tibble: 6 x 10
    ##   LABEL   FLUX.1   FLUX.2   FLUX.3   FLUX.4   FLUX.5   FLUX.6  FLUX.7
    ##   <int>    <dbl>    <dbl>    <dbl>    <dbl>    <dbl>    <dbl>   <dbl>
    ## 1     2    93.85    83.81    20.10   -26.98   -39.56  -124.71 -135.18
    ## 2     2   -38.88   -33.83   -58.54   -40.09   -79.31   -72.81  -86.55
    ## 3     2   532.64   535.92   513.73   496.92   456.45   466.00  464.50
    ## 4     2   326.52   347.39   302.35   298.13   317.74   312.70  322.33
    ## 5     2 -1107.21 -1112.59 -1118.95 -1095.10 -1057.55 -1034.48 -998.34
    ## 6     2   211.10   163.57   179.16   187.82   188.46   168.13  203.46
    ## # ... with 2 more variables: FLUX.8 <dbl>, FLUX.9 <dbl>

### Interpret the data

One approach for detecting exoplanets is based on [transit](https://en.wikipedia.org/wiki/Methods_of_detecting_exoplanets#Transit_photometry). When the star and any of its exoplanets are aligned with Kepler's observation point, the flux measured by Kepler would decrease. When the exoplanet no longer blocks the light, the flux will increase.

Below is an example of a star having exoplanets. The downward peaks correspond to some planet that periodically blocks the light.

``` r
tmp <- as.numeric(raw[2, 2:dim(raw)[2]])
ggplot() +
  aes(1:length(tmp), tmp) +
  geom_line() +
  scale_x_continuous("Time") +
  scale_y_continuous("Flux") +
  ggtitle("Flux time series for star 2")
```

![](quick_summary_files/figure-markdown_github/unnamed-chunk-4-1.png)

### Load external functioins for data analysis

The `dat_utils` script includes data utility functions that remove the outliers and perform Fourier Transform.

``` r
source("./dat_utils.R")
```

### Filter the data and apply fourier transform

From the plot above, we see some positive peaks that do not occur periodically and we do not know what caused these positive peaks. In transit, because we mainly consider the negative peaks, we may consider filtering out these positive peaks.

Another thing to consider is to apply Fourier Transform on the flux data in time series. Because the time series data could be interferred by unknown sources which may not be periodical, we may transform the timer series data to the frequency domain to find periodical patterns. However, the effectivenss of the transformation in detecting exoplanets remain to be studied.

``` r
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

``` r
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
tmp3 <- as.numeric(df[3, 3:ncols])
flux <- ggplot() +
  geom_line(aes(1:length(tmp3), tmp3, color = 'original')) +
  geom_line(aes(1:length(tmp2), tmp2, color = 'filtered'), alpha=0.8) +
  scale_x_continuous("Time") +
  scale_y_continuous("Flux")
```

``` r
freq_plot_zoom
```

![](quick_summary_files/figure-markdown_github/unnamed-chunk-8-1.png)

``` r
flux
```

![](quick_summary_files/figure-markdown_github/unnamed-chunk-9-1.png)

### Classifying whether a star has exoplanet

Below shows a very simple random forest model (in `./bin/`) that takes the flux time series ad input and classifies whether the star has exoplanets.

One of the challenges in the building the model is that the training data is extremely unbalanced, that is, only 37 out of 5000 stars have exoplanents. To tackle this issue, I divide each observation (a flux time series for a star) into 3 segments, assuming each segment is for one star. Thus, I can achieve `37*3=111` observations in the training set for stars that have exoplanets.

To further address the unbalance in training data, the random forest model is trained with `balance_classes=TRUE`. For details of how to build this model, please refer to `./src/build_mdl_reduce.R`.

``` r
## Build Random Forest model based on raw data (no removing outliers)

library(h2o)

h2o.init(nthreads = -1)
```

    ##  Connection successful!
    ## 
    ## R is connected to the H2O cluster: 
    ##     H2O cluster uptime:         2 hours 5 minutes 
    ##     H2O cluster version:        3.14.0.3 
    ##     H2O cluster version age:    2 months and 18 days  
    ##     H2O cluster name:           H2O_started_from_R_guanchen_crm247 
    ##     H2O cluster total nodes:    1 
    ##     H2O cluster total memory:   1.50 GB 
    ##     H2O cluster total cores:    2 
    ##     H2O cluster allowed cores:  2 
    ##     H2O cluster healthy:        TRUE 
    ##     H2O Connection ip:          localhost 
    ##     H2O Connection port:        54321 
    ##     H2O Connection proxy:       NA 
    ##     H2O Internal Security:      FALSE 
    ##     H2O API Extensions:         XGBoost, Algos, AutoML, Core V3, Core V4 
    ##     R Version:                  R version 3.4.2 (2017-09-28)

``` r
col_range <- 1:1066
test_raw <- read_csv("../data/exoTest.csv")
dat_test_f_raw <- test_raw #toFFT(test_raw[, 1:1066])
dat_test2 <- as.h2o(dat_test_f_raw[, col_range], destination_frame="dat_test2")
```

    ## 
      |                                                                       
      |                                                                 |   0%
      |                                                                       
      |=================================================================| 100%

``` r
dat_test2$LABEL <- as.factor(dat_test2$LABEL)

# dat_test_scaled2 <- dat_test2
# dat_test_scaled2[, 2:dim(dat_test_scaled2)[2]] <- h2o.scale(dat_test_scaled2[, 2:dim(dat_test_scaled2)[2]]) 

col_range <- 1:dim(dat_test2)[2]
rf_model <- h2o.loadModel("./bin/rf_fit2")

rf_perf <- h2o.performance(model = rf_model,
  newdata = dat_test2[, col_range])

rf_perf
```

    ## H2OBinomialMetrics: drf
    ## 
    ## MSE:  0.008707997
    ## RMSE:  0.09331665
    ## LogLoss:  0.05026151
    ## Mean Per-Class Error:  0.1141593
    ## AUC:  0.9711504
    ## Gini:  0.9423009
    ## 
    ## Confusion Matrix (vertical: actual; across: predicted) for F1-optimal threshold:
    ##          1  2    Error     Rate
    ## 1      549 16 0.028319  =16/565
    ## 2        1  4 0.200000     =1/5
    ## Totals 550 20 0.029825  =17/570
    ## 
    ## Maximum Metrics: Maximum metrics at their respective thresholds
    ##                         metric threshold    value idx
    ## 1                       max f1  0.003663 0.320000  18
    ## 2                       max f2  0.003663 0.500000  18
    ## 3                 max f0point5  0.003663 0.235294  18
    ## 4                 max accuracy  0.009755 0.989474   0
    ## 5                max precision  0.003663 0.200000  18
    ## 6                   max recall  0.003049 1.000000  29
    ## 7              max specificity  0.009755 0.998230   0
    ## 8             max absolute_mcc  0.003663 0.391067  18
    ## 9   max min_per_class_accuracy  0.003049 0.952212  29
    ## 10 max mean_per_class_accuracy  0.003049 0.976106  29
    ## 
    ## Gains/Lift Table: Extract with `h2o.gainsLift(<model>, <data>)` or `h2o.gainsLift(<model>, valid=<T/F>, xval=<T/F>)`

The results show that the model needs further training. Possible improvement could include:

-   obtain more training and testing data
-   further filter the data to extract better features and to remove noise

Nevertheless, we can use the results to locate where the errors occur and to have a close look at the specific stars to find any irregularities.
