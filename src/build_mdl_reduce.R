## Build Random Forest model based on raw data (no removing outliers)

library(h2o)

h2o.init(nthreads = -1)

dat_train_reduced <- readRDS("./data/exoTrainReduced.rds")
train_raw <- dat_train_reduced[1:5000, ]

ncols <- dim(train_raw)[2]
dat_range <- 1:dim(train_raw)[2]
dat_train_f_raw <- train_raw[, dat_range] #toFFT(train_raw[, dat_range])
dat_train2 <- as.h2o(dat_train_f_raw, destination_frame="dat_train2")
dat_train2$LABEL <- as.factor(dat_train2$LABEL)

dat_train_scaled2 <- dat_train2
dat_train_scaled2[, 2:dim(dat_train_scaled2)[2]] <- h2o.scale(dat_train_scaled2[, 2:dim(dat_train_scaled2)[2]])

test_raw <- read_csv("./data/exoTest.csv")
test_raw <- readRDS("./data/exoTestReduced.rds")
dat_test_f_raw <- test_raw #toFFT(test_raw[, 1:1066])
dat_test2 <- as.h2o(dat_test_f_raw[, 1:1066], destination_frame="dat_test2")
dat_test2$LABEL <- as.factor(dat_test2$LABEL)

dat_test_scaled2 <- dat_test2
dat_test_scaled2[, 2:dim(dat_test_scaled2)[2]] <- h2o.scale(dat_test_scaled2[, 2:dim(dat_test_scaled2)[2]]) 

## Define response and predictors
# col_range <- 1:round(dim(dat_train2)[2]/2)
col_range <- 1:dim(dat_train2)[2]
y <- "LABEL"
x <- setdiff(names(dat_train2[, col_range]), c(y))

# Random Forest
rf_fit2 <- h2o.randomForest(x = x,
  y = y,
  training_frame = dat_train2[1:5000, col_range],
  model_id = "rf_fit2",
  balance_classes = TRUE,
  # class_sampling_factors = c(1, 130),
  ntree = 200,
  seed = 1)
h2o.confusionMatrix(rf_fit2)

rf_perf2 <- h2o.performance(model = rf_fit2,
  newdata = dat_test2[, col_range])

rf_perf2

h2o.saveModel(object=rf_fit2, path="./bin", force=TRUE)

# deep learning
idx_trunc <- 1:dim(dat_train2)[2]
y <- "LABEL"
x <- setdiff(names(dat_train2[, idx_trunc]), c(y)) 
dl_fit3 <- h2o.deeplearning(x = x,
  y = y,
  training_frame = dat_train2[, idx_trunc],
  model_id = "dl_fit3",
  # epochs = 20,
  # hidden= c(500,500),
  # stopping_rounds = 0,
  balance_classes = TRUE,
  # class_sampling_factors = c(1, 130),
  seed = 1)
h2o.confusionMatrix(dl_fit3)
# dl_perf1 <- h2o.performance(model = dl_fit1,
#   newdata = dat_test_scaled[, 1:round(dim(dat_train_scaled)[2]/2)])
dl_perf3 <- h2o.performance(model = dl_fit3,
  newdata = dat_test2[, idx_trunc])
dl_perf3
