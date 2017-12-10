## Build Random Forest model based on raw data (no removing outliers)

train_raw <- read_csv("./data/exoTrain.csv")

ncols <- dim(train_raw)[2]
dat_range <- 1:1500
dat_train_f_raw <- toFFT(train_raw[, dat_range])
dat_train2 <- as.h2o(dat_train_f_raw, destination_frame="dat_train2")
dat_train2$LABEL <- as.factor(dat_train2$LABEL)

dat_train_scaled2 <- dat_train2
dat_train_scaled2[, 2:dim(dat_train_scaled2)[2]] <- h2o.scale(dat_train_scaled2[, 2:dim(dat_train_scaled2)[2]])

test_raw <- read_csv("./data/exoTest.csv")
dat_test_f_raw <- toFFT(test_raw[, dat_range])
dat_test2 <- as.h2o(dat_test_f_raw, destination_frame="dat_test2")
dat_test2$LABEL <- as.factor(dat_test2$LABEL)

dat_test_scaled2 <- dat_test2
dat_test_scaled2[, 2:dim(dat_test_scaled2)[2]] <- h2o.scale(dat_test_scaled2[, 2:dim(dat_test_scaled2)[2]]) 

## Define response and predictors
col_range <- 1:round(dim(dat_train2)[2]/2)
y <- "LABEL"
x <- setdiff(names(dat_train2[, col_range]), c(y))

# Random Forest
rf_fit2 <- h2o.randomForest(x = x,
  y = y,
  training_frame = dat_train2[1:500, col_range],
  model_id = "rf_fit2",
  balance_classes = TRUE,
  # class_sampling_factors = c(1, 130),
  ntree = 50,
  seed = 1)
h2o.confusionMatrix(rf_fit2)

rf_perf2 <- h2o.performance(model = rf_fit2,
  newdata = dat_test2[, col_range])

rf_perf2
