# Utility functions for data processing

get_upper_outlier <- function (series, q) {
  if (q > 0 & q < 1) {
    quantile(as.numeric(series), q, na.rm = TRUE)
  } else {
    print("Invalid arg q: quantile must be in the range (0, 1).")
    return(NA_real_)
  }
}

# method: average of 4 neighbors
rm_upper_outlier <- function (series) {
  # remove LABEL on the first column
  
  # init series_clean by copying series
  series_clean <- as.numeric(series[2:length(series)])
  # get the filter threshold
  thres <- get_upper_outlier(series[2:length(series)], .95)
  
  for (i in 1:length(series_clean)) {
    if (series_clean[i] > thres) {
      # indices before the point where the value is larger than the threshold
      idx_before <- c(i-2, i-1)
      if (i < length(series_clean)) {  # if not exceeding the upper bound
        next_idx <- get_next_index(series_clean, i+1, thres)
      } else {  # else add a random number to make it larger than the length
        next_idx <- length(series_clean) + 10
      }
      # indices after the point where the value is larger than the threshold and
      # the indices correspond to values less than the threshold
      idx_after <- next_idx:next_idx+2
      
      # if idx_before and idx_after are in range
      if (min(idx_before) > 0 & max(idx_after) <= length(series_clean)) {
        # change series_clean[i] to the average of the values correspond to c(idx_before, idx_after)
        series_clean[i] <- mean(series_clean[c(idx_before, idx_after)], na.rm = TRUE)
      }
    }
  }
  return(c(series[1], series_clean))
}

# get the index of next flux under the threshold
get_next_index <- function (series_clean, idx_start, thres) {
  next_idx <- 0
  # use for loop to find the next value that is not larger than threshold
  for (i in idx_start:length(series_clean)) {
    if (series_clean[i] < thres) {
      next_idx <- i
      break
    }
  }
  return(next_idx)
}

# test instance
test_idx <- 3
series1 <- as.numeric(dat_raw_train[test_idx, 2:dim(dat_raw_train)[2]])

series <- dat_raw_train[1:10,]
# flux_rm_outlier <- rm_upper_outlier(series)

# flux_rm_outlier <- matrix(, nrow = nrow(series), ncol = dim(series)[2]-1)
for (n in 1:nrow(series)) {
  # flux_rm_outlier[n,] <- rm_upper_outlier(series[n,])
  series[n,] <- rm_upper_outlier(series[n, ])
}

ncols <- dim(dat_raw_train)[2]

# see the effect after removing the upper outliers
ggplot() +
  geom_line(aes(1:(ncols-1), series1)) +
  geom_line(aes(1:(ncols-1), as.numeric(series[test_idx, 2:ncols])), color = 'red', alpha=0.8)
  # geom_line(aes(1:(ncols-1), flux_rm_outlier[test_idx,]), color = 'red', alpha=0.8)

