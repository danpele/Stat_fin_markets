library(devtools)
devtools::install_github(repo="stuartgordonreid/emh")

# Get quantmod
if (!require("quantmod")) {
    install.packages("quantmod")
    library(quantmod)
}

start <- as.Date("2014-01-01")
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

# What is AAPL?
class(AAPL)

# Let's see the first few rows
head(AAPL)


plot(AAPL[, "AAPL.Close"], main = "AAPL")
library(devtools)
devtools::install_github(repo="stuartgordonreid/emh")

# Get quantmod
if (!require("quantmod")) {
    install.packages("quantmod")
    library(quantmod)
}

start <- as.Date("2014-01-01")
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

# What is AAPL?
class(AAPL)

# Let's see the first few rows
head(AAPL)


plot(AAPL[, "AAPL.Close"], main = "AAPL")


suppressMessages(library(emh))
install.packages("Quandl")
library(Quandl)


results <- emh::is_random(AAPL)
emh::plot_results(results)
View(results)


plot_results(results)
