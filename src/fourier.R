## Basic Fourier Transform
# Transform time-series flux data to the frequency domain

toFFT <- function (df) {
  #' Batch transform a data frame to frequency domain
  #' 
  #' @description Transforms time-series flux data in data frame to the frequency domain
  #' @param df The data frame to be transformed
  #' @return The data frame transformed from the input data frame
  #' @note
  #' This function assumes each row of the input contains a set of time-series data.
  #' The first column of the input contains the labels of the stars.
  
  # holder for harmonic calculation
  harms <- matrix(rep(0, nrow(df) * (dim(df)[2] - 1)), nrow = nrow(df))
  
  for (idx in 1:nrow(df)) {
    X <- t(df[idx,])  # transpose to column
    X <- X[2:length(X)]  # remove the label on the first column
    # X_scaled <- scale(X)
    
    Xk <- fft(X)  # this returns a vector of complex numbers
    
    harms[idx,] <- Mod(Xk)  # complex numbers to real
    harms[idx, 2:length(Xk)] <- 2 * harms[idx, 2:length(Xk)]
  }
  
  # return
  df_transformed <- as_tibble(harms)
  df_transformed <- df_transformed %>%
    mutate(LABEL = df$LABEL[1:nrow(df)]) %>%
    select(LABEL, everything())
  names(df_transformed) <- colnames(df)
  return(df_transformed)
}

# Test and verify
# to-do: get series from cleaned csv
f <- toFFT(series)

plot.frequency.spectrum <- function(X.k, xlimits=c(0,length(X.k))) {
  plot.data  <- cbind(0:(length(X.k)-1), Mod(X.k))
  
  plot.data[2:length(X.k),2] <- 2*plot.data[2:length(X.k),2] 
  
  plot(plot.data, t="h", lwd=2, main="", 
    xlab="Frequency", ylab="Strength", 
    xlim=xlimits, ylim=c(0,max(Mod(plot.data[,2]))))
}

plot.frequency.spectrum(as.numeric(f[3,2:length(f[1,])]), xlimits=c(0,length(f)/2))
plot.frequency.spectrum(as.numeric(f[3,2:length(f[1,])]), xlimits = c(0, 20))

