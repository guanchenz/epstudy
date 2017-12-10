## Build machine learning model that classifies whether stars have planets

library(h2o)

h2o.init(nthreads = -1)

## Prepare training data

dat_train_range <- 1:1500
dat_train_f <- toFFT(dat_train_cleaned[, dat_train_range])

dat_train <- as.h2o(dat_train_f, destination_frame="dat_train")
dat_train$LABEL <- as.factor(dat_train$LABEL)

dat_train_scaled <- dat_train
ncols <- dim(dat_train_scaled)[2]
dat_train_scaled[, 2:ncols] <- h2o.scale(dat_train_scaled[,2:ncols])

## Prepare test data

test_raw <- read_csv("./data/exoTest.csv")

dat_test_f <- toFFT(test_raw)
dat_test <- as.h2o(dat_test_f, destination_frame="dat_test")
dat_test$LABEL <- as.factor(dat_test$LABEL)

dat_test_scaled <- dat_test
ncols <- dim(dat_test_scaled)[2]
dat_test_scaled[, 2:ncols] <- h2o.scale(dat_test_scaled[,2:ncols])

## Define response and predictors
y <- "LABEL"
x <- setdiff(names(data), c(y))

## Build
# Random Forest
rf_fit1 <- h2o.randomForest(x = x,
  y = y,
  training_frame = data[1:500,],
  model_id = "rf_fit1",
  balance_classes = TRUE,
  # class_sampling_factors = c(1, 130),
  ntree = 200,
  seed = 1)

rf_perf1 <- h2o.performance(model = rf_fit1,
  newdata = test)

rf_perf1

# h2o.auc(rf_perf1)

# deep learning
idx_trunc <- 1:round(dim(dat_train_scaled)[2]/2)
y <- "LABEL"
x <- setdiff(names(dat_train[, idx_trunc]), c(y)) 
dl_fit1 <- h2o.deeplearning(x = x,
  y = y,
  training_frame = dat_train_scaled[, idx_trunc],
  model_id = "dl_fit1",
  # epochs = 20,
  # hidden= c(500,500),
  # stopping_rounds = 0,
  balance_classes = TRUE,
  class_sampling_factors = c(1, 130),
  seed = 1)
dl_perf1 <- h2o.performance(model = dl_fit1,
  newdata = dat_test_scaled[, 1:round(dim(dat_train_scaled)[2]/2)])
dl_perf1
h2o.auc(dl_perf1)
