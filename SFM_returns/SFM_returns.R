# Get quantmod

rm(list = ls(all = TRUE))
if (!require("quantmod")) {
  install.packages("quantmod")
  library(quantmod)
}

start <- as.Date("2015-01-01")
end <- as.Date("2020-10-01")

# Let's get Apple stock data; Apple's ticker symbol is AAPL. We use the
# quantmod function getSymbols, and pass a string as a first argument to
# identify the desired ticker symbol, pass 'yahoo' to src for Yahoo!
# Finance, and from and to specify date ranges

# The default behavior for getSymbols is to load data directly into the
# global environment, with the object being named after the loaded ticker
# symbol. This feature may become deprecated in the future, but we exploit
# it now.
if (!require("tseries")) {
  install.packages("tseries")
  library(magrittr)
}

library(tseries)
ticker="AAPL"
df<-get.hist.quote(instrument=ticker, start = start, end = end)
df=as.data.frame(df)
# Let's see the first few rows
head(df)

plot(df[, "Close"], main = ticker,type='l')
# Get me my beloved pipe operator!
if (!require("magrittr")) {
  install.packages("magrittr")
  library(magrittr)
}

library(magrittr)
log_return= df$Close %>% log %>% diff

log_return<-log_return[!is.na(log_return)]
head(log_return)
plot(log_return, type="l")



hist(log_return,col="blue")



ret<-as.data.frame(log_return)
shapiro.test(ret$log_return)

# Kernel Density Estimation: https://en.wikipedia.org/wiki/Kernel_density_estimation
library("dplyr")
library("ggpubr")
ggdensity(ret$log_return, 
          main = "Density plot",
          xlab = "Log return")

summary(ret$log_return)

install.packages("e1071")
library(e1071)

skewness(ret$log_return)
kurtosis(ret$log_return)


mu=mean(ret$log_return)
std=sd(ret$log_return)

Normal<-rnorm(length(ret$log_return), mean = mu, sd = std)


hgA <- hist(ret$log_return,plot = FALSE) # Save first histogram data
hgB <- hist(Normal, plot = FALSE) # Save 2nd histogram data

plot(hgA,c="blue") # Plot 1st histogram using a transparent color
plot(hgB, c="red", add = TRUE) # Add 2nd histogram using different color
