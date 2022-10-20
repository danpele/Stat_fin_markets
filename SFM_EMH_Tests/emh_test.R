#install.packages("devtools")


rm(list = ls(all = TRUE))
library(devtools)
devtools::install_github(repo="stuartgordonreid/emh")

# Get quantmod
if (!require("quantmod")) {
    install.packages("quantmod")
    library(quantmod)
}

start <- as.Date("2018-01-01")
end <- as.Date("2019-12-31")

# Let's get Apple stock data; Apple's ticker symbol is AAPL. We use the
# quantmod function getSymbols, and pass a string as a first argument to
# identify the desired ticker symbol, pass 'yahoo' to src for Yahoo!
# Finance, and from and to specify date ranges

# The default behavior for getSymbols is to load data directly into the
# global environment, with the object being named after the loaded ticker
# symbol. This feature may become deprecated in the future, but we exploit
# it now.

symbol<- c("AAPL")
start_date <- "2018-01-01"
end_date <- "2019-12-31"


df<- getSymbols(stock_index, verbose = TRUE, src = "yahoo", 
             from=start_date,to=end_date,auto.assign=FALSE)
 

names(df) = gsub(pattern = symbol, replacement = "", x = names(df))

names(df) <- gsub("\\.", "", names(df))
# Let's see the first few rows
head(df)


plot(df$AAPL.Close, main = "Closing Price", type="l")
library(emh)

results <- emh::is_random(df$Close)
emh::plot_results(results)
View(results)





