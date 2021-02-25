# Get quantmod
if (!require("quantmod")) {
  install.packages("quantmod")
  library(quantmod)
}

start <- as.Date("2015-01-01")
end <- as.Date("2016-10-01")

# Let's get Apple stock data; Apple's ticker symbol is AAPL. We use the
# quantmod function getSymbols, and pass a string as a first argument to
# identify the desired ticker symbol, pass 'yahoo' to src for Yahoo!
# Finance, and from and to specify date ranges

# The default behavior for getSymbols is to load data directly into the
# global environment, with the object being named after the loaded ticker
# symbol. This feature may become deprecated in the future, but we exploit
# it now.

getSymbols("AAPL", src = "yahoo", from = start, to = end)

# Let's see the first few rows
head(AAPL)

plot(AAPL[, "AAPL.Close"], main = "AAPL")
# Get me my beloved pipe operator!
if (!require("magrittr")) {
  install.packages("magrittr")
  library(magrittr)
}

library(magrittr)
log_return= AAPL$AAPL.Close %>% log %>% diff

log_return<-log_return[!is.na(log_return)]
head(log_return)
plot(log_return)



hist(log_return,col="blue")

library("dplyr")
library("ggpubr")
ggdensity(log_return, 
          main = "Density plot",
          xlab = "Log return")

shapiro.test(df$log_return)

summary(log_return)

#install.packages("e1071")
library(e1071)

skewness(log_return)
kurtosis(log_return)


mu=mean(log_return)
std=sd(log_return)

Normal<-rnorm(length(log_return), mean = mu, sd = std)


hgA <- hist(log_return,plot = FALSE) # Save first histogram data
hgB <- hist(Normal, plot = FALSE) # Save 2nd histogram data

plot(hgA,c="blue") # Plot 1st histogram using a transparent color
plot(hgB, c="red", add = TRUE) # Add 2nd histogram using different color