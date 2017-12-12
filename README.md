## A simple data analysis on exoplanet data

Latest release: https://github.com/guanchenz/epstudy/releases/tag/v2.3

### Data

Data source: https://www.kaggle.com/keplersmachines/kepler-labelled-time-series-data

The original data are collected from Campaign 3 of Kepler's Mission. The Kaggle source filtered the original data and saved training and test data separately in csv.

The data contain the flux time series of over 3000 stars in the space. Flux is the brightness of a star measured by Kepler. When an exoplanent evolves inbetween the star and Kepler, it will block the light and thus the flux sensed by Kepler will decrease. This will occur periodally if a star has at least one exoplanet.


### Objectives

-   Data visualization: interactively plot flux data for each star
-   Data processing: clean up data for modeling. This involves removing outliers and Fourier Transform
-   Model for detecting exoplanets: build very simple model for classifying stars (have or do not have exoplanets)
-   Build workflow


### Scope

This analysis is only intended to present the workflow of data retrieval, visualization, processing and analysis.

### How to use

0.   Download the csv file from Kaggle and save it in `./data`.

1.   Compress the large csv file to rds

     -   args: raw csv file, target rds file

```
Rscript src/dat_prep.R ./data/exoTrain.csv ./data/exoTrain.rds
```

2.   Extract one star for data processing and visualization (demo only)

     -   args: compressed rds file, target csv file for one star, star index
     -   star index: from 1 to 3000

```
Rscript src/dat_sum.R ./data/exoTrain.rds ./results/quick_summary.csv 3
```

3.   Plot and save

     -   args: csv file for one star, plot saving directory

```
Rscript src/dat_viz.R ./results/quick_summary.csv ./results/
```

4.   Render Rmd summary

```
ezknitr::ezknit("./src/quick_summary.Rmd", out_dir = "./results")
