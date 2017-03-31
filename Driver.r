# ref: https://hilaryparker.com/2014/04/29/writing-an-r-package-from-scratch/

# install.packages("devtools")
library("devtools")
devtools::install_github("klutometis/roxygen")
library(roxygen2)

setwd("/Users/weixiangxu/R/FourElements/")
create("impvolmx")
  

df = data.frame(
  #strike = c(50, 20, 40, 30), # the option strike in $
  type = c("C", "P", "C", "P"), # either “c” for call option or “p” for a put option
  optionPrice = c(1.62,0.01, 8.5, 0.1), # the option price in $
  futurePrice = c(48.03, 48.03, 48.03, 48.03), # the price of the underlying futures in $
  time_to_expiry = c(0.1423, 0.1423, 0.1423, 0.1423), # the option time to expiry in year
  r = c(rep(0.01, 4))
  ) 
setwd("/Users/weixiangxu/R/FourElements/impvolmx/data")
save(df, file = "Sample.rData")
# try reading it
setwd("/Users/weixiangxu/R/FourElements/impvolmx/data")
load("Sample.rData")
# setwd("/Users/weixiangxu/R/FourElements/")
# load("DOW.RData")

setwd("/Users/weixiangxu/R/FourElements/impvolmx")
document()

# install the package
setwd("/Users/weixiangxu/R/FourElements/")
install("impvolmx")

# build the package to create tar.gz
setwd("/Users/weixiangxu/R/FourElements/impvolmx")
build()

# install this
install()

# or use this to install
install.packages("/Users/weixiangxu/R/FourElements/impvolmx_0.0.0.9000.tar.gz", 
                 repos = NULL, type="source")
