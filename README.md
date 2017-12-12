## A simple data analysis on exoplanet data

Latest release: https://github.com/guanchenz/epstudy/releases/tag/v2.2

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
