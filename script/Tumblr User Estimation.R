### Time series prediction for tumblr user

library(forecast)

# CSV version of Exhibit 1
tumblrUsers.data<-read.csv(file.choose(), header=TRUE, sep=",") #load the data into the dataframe

### EXPLORING THE LOADED DATA ###
str(tumblrUsers.data) #show the structure of (data types in) the dataframe
head(tumblrUsers.data, 4) #show the first 4 rows in the dataframe
tail(tumblrUsers.data,4) #show the last 4 rows in the dataframe

### DEFINING A TIMESERIES ###
UsersTS <- ts(tumblrUsers.data$People, start=c(2010,4), frequency = 12)

### EXPLORING THE TIMESERIES ###
str(UsersTS) #show the structure of (data types in) the dataframe
head(UsersTS, 4) #show the first 4 rows in the dataframe
tail(UsersTS,4) #show the last 4 rows in the dataframe

par(mfrow=c(1,1))
plot(UsersTS, xlab="Year",
     ylab="Tumblr Worldwide Users")
abline(v=2012.5)

# Comments: Increase seems to have tapered off starting from 2012. Yahoo may be in deep trouble. 

##################################################################################

# last 37 months growth = 5.47%
PredLinearHigh_G <- ((UsersTS[38]/UsersTS[1])^(1/(38-1)) -1)
# last 12 months growth = 1.52%
PredLinearLow_G <- ((UsersTS[38]/UsersTS[38-12])^(1/(38-(38-12))) -1)

# Creating projections
Users_May13 <- UsersTS[38]
PredLinearHigh_Vector <- Users_May13 * (1+PredLinearHigh_G)^(1:115)
PredLinearLow_Vector <- Users_May13 * (1+PredLinearLow_G)^(1:115)

PredLinearHighTS <- ts(PredLinearHigh_Vector, start=c(2013,6), frequency = 12)
PredLinearLowTS <- ts(PredLinearLow_Vector, start=c(2013,6), frequency = 12)

  #Exploring linear predictions
  tail(PredLinearHighTS,4) #show the last 4 rows in the dataframe
  tail(PredLinearLowTS,4) #show the last 4 rows in the dataframe
  
  plot(UsersTS, ylab='Tumblr Worldwide Users', col="black", xlim=(c(2010, 2023)),ylim=c(0,max(PredLinearHigh_Vector)))
  lines(PredLinearHighTS, col="green")
  lines(PredLinearLowTS, col="red")
  
  plot(UsersTS, ylab='Tumblr Worldwide Users', col="black", xlim=(c(2010, 2023)),ylim=c(0,max(PredLinearLow_Vector)))
  lines(PredLinearLowTS, col="red")

write.csv(PredLinearHighTS, file = "A1A1 DSB Tumblr Linear High.csv")
write.csv(PredLinearLowTS, file = "A1A1 DSB Tumblr Linear Low.csv")

# Comments: Using historical 37-month growth, Tumblr is valued at 63.736 billion, but the worldwide user estimated is unrealistic as it is more than world population and hence too high. Using historical 12-month growth, Tumblr is valued at 1.23 billion. 37-month historical growth has been steep, like a hockey stick, and we cannot expect it to continue at the same rate.

##################################################################################


#plot various decompositions into error/noise, trend and seasonality
MnUsersTS <- UsersTS/1000000 # convert to million users

fit <- stl(MnUsersTS, t.window=12, s.window="periodic") #decompose using STL (Season and trend using Loess)
plot(fit)

par(mfrow=c(1,2))
Acf(MnUsersTS,12) # auto-correlation function
Pacf(MnUsersTS,12) # partial auto-correlation function

# Comments: There may be a seasonality component, and a decreasing trend post 2012. Error seems to be autocorrelated. Pacf confirms an autocorrelation with lag 1 (almost a random walk?)

PredAAdZ_Model <- ets(MnUsersTS, model="AAZ", damped=TRUE) 
PredMMdZ_Model <- ets(MnUsersTS, model="MMZ", damped=TRUE)
Predtbats_Model <- tbats(MnUsersTS)
PredARIMA_Model <- auto.arima(MnUsersTS,seasonal=TRUE)

PredAAdZ <- forecast(PredAAdZ_Model, h=115, level=c(0.8, 0.95))
PredMMdZ <- forecast(PredMMdZ_Model, h=115, level=c(0.8, 0.95))
Predtbats <-forecast(Predtbats_Model, h=115, level=c(0.8, 0.95))
PredARIMA <-forecast(PredARIMA_Model, h=115, level=c(0.8, 0.95))

# Compare the prediction "cones" visually
par(mfrow=c(1,4)) 
plot(PredAAdZ, xlab="Year", ylab="Predicted Tumblr Worldwide Users", ylim=c(15,500))
plot(PredMMdZ, xlab="Year", ylab="Predicted Tumblr Worldwide Users", ylim=c(15,500))
plot(Predtbats, xlab="Year", ylab="Predicted Tumblr Worldwide Users", ylim=c(15,500))
plot(PredARIMA, xlab="Year", ylab="Predicted Tumblr Worldwide Users", ylim=c(15,500))

  # Exploring damped vs not damped
  PredAAZ_Model <- ets(MnUsersTS, model="AAZ") 
  PredMMZ_Model <- ets(MnUsersTS, model="MMZ")
  
  PredAAZ <- forecast(PredAAZ_Model, h=115, level=c(0.8, 0.95))
  PredMMZ <- forecast(PredMMZ_Model, h=115, level=c(0.8, 0.95))
  
  plot(PredAAdZ, xlab="Year", ylab="Predicted Tumblr Worldwide Users", ylim=c(15,500))
  plot(PredMMdZ, xlab="Year", ylab="Predicted Tumblr Worldwide Users", ylim=c(15,500))
  plot(PredAAZ, xlab="Year", ylab="Predicted Tumblr Worldwide Users", ylim=c(15,500))
  plot(PredMMZ, xlab="Year", ylab="Predicted Tumblr Worldwide Users", ylim=c(15,500))
  
# Discard ARIMA since it is a Random Walk with drift

### Comparing models -- Time series Cross Validation (Rolling Horizon Holdout)

f_AAdZ  <- function(y, h) forecast(ets(y, model="AAZ", damped=TRUE), h = h)
errors_AAdZ <- tsCV(MnUsersTS, f_AAdZ, h=1, window=12) # Uses past 12 months for validation, since growth slowed

f_MMdZ  <- function(y, h) forecast(ets(y, model="MMZ", damped=TRUE), h = h)
errors_MMdZ <- tsCV(MnUsersTS, f_MMdZ, h=1, window=12)

f_TBATS  <- function(y, h) forecast(tbats(y), h = h)
errors_TBATS <- tsCV(MnUsersTS, f_TBATS, h=1, window=12)

par(mfrow=c(1,1))
plot(errors_AAdZ, ylab='tsCV errors', col="green")
abline(0,0)
lines(errors_MMdZ, col="blue")
lines(errors_TBATS, col="red")
legend("left", legend=c("CV_error_AAdZ", "CV_error_MMdZ","CV_error_TBATS"), col=c("green", "blue", "gray"), lty=1:4)

# Caclulate MAPE
mean(abs(errors_AAdZ/MnUsersTS), na.rm=TRUE)*100 # = 5.09
mean(abs(errors_MMdZ/MnUsersTS), na.rm=TRUE)*100 # = 4.78
mean(abs(errors_TBATS/MnUsersTS), na.rm=TRUE)*100 # = 4.64

  # If using past 24 months
  errors24_AAdZ <- tsCV(MnUsersTS, f_AAdZ, h=1, window=24)
  errors24_MMdZ <- tsCV(MnUsersTS, f_MMdZ, h=1, window=24)
  errors24_TBATS <- tsCV(MnUsersTS, f_TBATS, h=1, window=24)
  
  mean(abs(errors24_AAdZ/MnUsersTS), na.rm=TRUE)*100 # = 4.305
  mean(abs(errors24_MMdZ/MnUsersTS), na.rm=TRUE)*100 # = 4.58
  mean(abs(errors24_TBATS/MnUsersTS), na.rm=TRUE)*100 # = 5.04
  
  # If using past 36 months
  errors36_AAdZ <- tsCV(MnUsersTS, f_AAdZ, h=1, window=36)
  errors36_MMdZ <- tsCV(MnUsersTS, f_MMdZ, h=1, window=36)
  errors36_TBATS <- tsCV(MnUsersTS, f_TBATS, h=1, window=36)
  
  mean(abs(errors36_AAdZ/MnUsersTS), na.rm=TRUE)*100 # = 1.68
  mean(abs(errors36_MMdZ/MnUsersTS), na.rm=TRUE)*100 # = 2.45
  mean(abs(errors36_TBATS/MnUsersTS), na.rm=TRUE)*100 # = 2.42

# Comment: We choose to use TBATs because we think the the most recent data points are most relevant in predicting future forecast
  
# Write CSV
write.csv(PredAAdZ, file = "A1A1 DSB Tumblr AAdZ.csv")
write.csv(PredMMdZ, file = "A1A1 DSB Tumblr MMdZ.csv")
write.csv(Predtbats, file = "A1A1 DSB Tumblr TBATs.csv")

# 495 Mn predicted using AAdZ; 622 on Hi80; 689 on Hi95;
# 425 Mn predicted using TBATs; 500 on Hi80; 543 on Hi95;
# FB is now at 2.5bn MAU while Tumblr has 452mn blogs and 371mn monthly visits (MAU unknown)

### ARPU EXPLORATION
# Comments: Key finding from analysis below is that assumed ARPU is too aggressive given current number of users (hypothesis is that ARPU is also correlated to number of users due to network effect)
  #forecast revenue per user in based on Facebook at Global
  FacebookGlobalARPU <- read.csv(file.choose(), header=TRUE, sep=",") #import data
  str(FacebookGlobalARPU)
  
  fit.ARPU.Global <- lm(ARPU~MAU,data = FacebookGlobalARPU) #run regression
  summary(fit.ARPU.Global)
  predict.ARPU.Global.testing <- predict(fit.ARPU.Global,FacebookGlobalARPU$MAU)
  percent.errors.Global.ARPU <- abs((predict.ARPU.Global.testing)/FacebookGlobalARPU$ARPU)*100 #calculate absolute percentage errors
  mean(percent.errors.Global.ARPU, na.rm = TRUE) #display Mean Absolute Percentage Error (MAPE)
  
  plot(fit.ARPU.Global)
  TumblrUniqueGlobal_tbats_pred
  
  Global.MAU.Predict <- read.csv(file.choose(), header=TRUE, sep=",") #import data
  Global.MAU.Predict <- rename(Global.MAU.Predict, c(Point.Forecast = "MAU"))
  predict.ARPU.Global <- predict(fit.ARPU.Global, Global.MAU.Predict)
  
  write.csv(predict.ARPU.Global,"predict.ARPU.Global.csv")
  
  #forecast revenue per user in based on Facebook at US level
  FacebookUSARPU <- read.csv(file.choose(), header=TRUE, sep=",") #import data
  str(FacebookUSARPU)
  
  fit.ARPU.US <- lm(ARPU~MAU,data = FacebookUSARPU) #run regression
  summary(fit.ARPU.US)
  
  predict.ARPU.US.testing <- predict(fit.ARPU.US,FacebookUSARPU)
  percent.errors.US.ARPU <- abs((predict.ARPU.US.testing)/FacebookUSARPU$ARPU)*100 #calculate absolute percentage errors
  mean(percent.errors.US.ARPU, na.rm = TRUE) #display Mean Absolute Percentage Error (MAPE)
  
  plot(fit.ARPU.US)
  
  US.MAU.Predict <- read.csv(file.choose(), header=TRUE, sep=",") #import data
  US.MAU.Predict <- rename(US.MAU.Predict, c(Point.Forecast = "MAU"))
  predict.ARPU.US <- predict(fit.ARPU.US, US.MAU.Predict)
  write.csv(predict.ARPU.US,"predict.ARPU.US.csv")


