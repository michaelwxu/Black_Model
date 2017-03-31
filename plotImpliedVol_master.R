# ************************************************************
#
# Copyright 2016 Michael Xu (XU Weixiang)
# 
# This source code corresponds to Michael's solution to an practice given by 
# a trading firm in 2016.
#
# Date: 2016-12-03
#
# ************************************************************


plotImpliedVol <- function(df) {
  # Args:
  #   df - a data frame contains 5 columns with name "strike", "type", "optionPrice", 
  #        "futurePrice", "time_to_expiry
  # The function will plot the implied vol for call and put separately on a same chart
  # Return:
  #   df - same df as input, with an extra column named "impVol" as calculated
  #        implied volaility
  

  
  # vector to store implied vol calcualted:
  imp.vol <- rep(0, nrow(df))

  # Calculate implied vol
  for(i in 1 : nrow(df)){
    # Perform some checks on df
    if (!df$type[i] %in% c("C", "P")) {
      stop("Please check if option types are input correctly. Accepted values: C or P")
    }
    imp.vol[i] <- ImpVol(F = df$futurePrice[i], 
                         K = df$strike[i], 
                         T = df$time_to_expiry[i], 
                         r = 0, 
                         mkt.price = df$optionPrice[i], 
                         type = df$type[i])
  }
  
  df$impVol <- imp.vol
  # Separate the df for calls and puts, for plotting purpose
  df.c <- df[which(df$type == "C" & (!is.na(df$impVol))), ]
  df.p <- df[which(df$type == "P" & (!is.na(df$impVol))), ]
  
  # Now do the plotting
  plot.new()
  par(mfrow = c(1, 1))
  xrange <- range(df$strike[which(!is.na(df$impVol))])
  yrange <- range(df$impVol[which(!is.na(df$impVol))])
  plot(xrange, yrange, type = "n", main=c("Implied Volatility", "Calls vs Puts"), 
       cex.main = 0.8,
       xlab="Strike", 
       ylab="Implied Vol")
  # calls
  lines(x = df.c$strike, y = df.c$impVol, 
        type="b", 
        col = "blue", 
        pch = 21)  # circles
  # puts
  lines(x = df.p$strike, y = df.p$impVol, 
        type = "b", 
        col = "red", 
        pch = 22)  # squares
  legend("bottomleft", 
         cex = 0.8, 
         c("Call", "Put"), 
         lty = c(1, 1), 
         col = c("blue", "red"),
         pch = c(21, 22))
  return (df)
}

# Calculate the option price from Black-76 Model (Black Model)
Black76 <- function(F, K, T, r = 0, vol, type="C"){
  # Args:
  #   F - Futures price
  #   K - Strike price
  #   T - Time to maturity, in year
  #   r - Continuous compound rate
  #   vol - Volatility
  #   type - Option Type, C for Call, P for Put
  # Return: 
  #   Price calculated in Black's model
  # note: F and T aren't a reserved names in R so 
  # I presume it's OK to use them as a parameter names
    d1 <- (log(F / K) + (r + vol ^ 2 / 2) * T) / (vol * sqrt(T))
    d2 <- d1 - vol * sqrt(T)
    # Calculate the price of the options
    # ref: https://en.wikipedia.org/wiki/Black_model
    if(type=="C"){
      res <- exp(-r * T) * (F * pnorm(d1) - K * pnorm(d2))
    }
    if(type=="P"){
      res <- exp(-r * T) * (K * pnorm(-d2) - F * pnorm(-d1))
    }
    return(res)
}

# Calculate Implied Vol using Bisection Method
ImpVol <- function(F, K, T, r = 0, mkt.price, type){
  # Args:
  #   F - Futures price
  #   K - Strike price
  #   T - Time to maturity, in year
  #   r - Continuous compound rate
  #   mkt.price - Price observed in the market
  #   type - Option Type, C for Call, P for Put
  # Return: 
  #   Implied volatility, backed out by plugging in everything into Black model
  imp.vol <- 0.20
  imp.vol.up <- 1
  imp.vol.down <- 0.001
  count <- 0
  
  # The difference of 
  err <- Black76(F, K, T, r, imp.vol, type) - mkt.price 
  
  # Method: repeat until the difference is sufficiently small, or counter reaches 1000
  while(abs(err) > 1e-6 && count < 1000){
    if(err < 0){
      # price calculated by Black76 model < market observed price
      # adjust the imp.vol up
      imp.vol.down <- imp.vol
      imp.vol <- (imp.vol.up + imp.vol) / 2
    } else {
      # price calculated by Black76 model > market observed price
      # adjust the imp.vol down
      imp.vol.up <- imp.vol
      imp.vol <- (imp.vol.down + imp.vol) / 2
    }
    err <- Black76(F, K, T, r, imp.vol, type) - mkt.price 
    count <- count + 1
  }
  
  # Return NA if counter reaches 1000
  if(count == 1000){
    return(NA)
  } else {
    return (imp.vol)
  }
}