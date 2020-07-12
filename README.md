# Tumblr User Prediction
Prediction of user base for Tumblr using time-series analysis. Used as input for valuation of Tumblr (not included in code). Time series forecast methods used: ETS (additive and multiplicative), TBATS, ARIMA. 

Key finding is that Yahoo most likely overpaid for Tumblr acquisition.

## Executive Summary
Yahoo acquired Tumblr for $1.1 billion on May 20, 2013. At that point, Tumblr had 136 million people visit worldwide and a slowing user growth trend. Since user base is one of the key drivers of valuation, we attempt to forecast this variable in this analysis using time series method.

TBATS was chosen as the best performing method, using last 12 month users as inputs. With this, number of people on Tumblr is predicted to peak at 180 million, which would give an estimate of $425 million valuation for Tumblr, using adjusted Facebook ARPU as a proxy. Yahoo paid a premium of ~$600 million above Tumblr fair value, and it remains to be seen if other potential synergies can improve user growth, ARPU or reduce cost of capital to account for this premium.

## Analysis
Visualising Tumblr growth, we see a high growth of ~5.5% using the entire time series, and ~1.5% in the last 12 months

![visual](/graphs/graph.png)

Decomposition using STL and plotting ACF/PACF shows:
* Tapering of trend in recent months
* High auto correlation
* Small seasonal impact

![STL](/graphs/decomposition.png)
![PACF](/graphs/PACF.png)

4 forecast models were compared: ETS (additive, damped), ETS (multiplicative, damped), TBATS, ARIMA
![Forecast](/graphs/forecast-plots.png)

## Validation
Model is cross validated using rolling horizon holdout, with past 12 months used for validation since trend has changed.
![Error](/graphs/error.png)

Error plot reveals no conclusion. MAPE is then calculated to determine model to be implemented.

MAPE | L12M | L24M | L36M
---- | ---- | ---- | ---- 
AAdz | 5.09% | 4.31% | 1.68%
MMdZ | 4.78% | 4.58% | 2.45%
TBATS | 4.64% | 5.04% | 2.42%

TBATS is chosen based on MAPE for the most recent data 

## Results
Using TBATS forecast, Tumblr is expected to peak over the next few years (after 2013) and flatten at around 180 million users. Using this inputs in our valuation, we arrive at a firm value of $425 million if Tumblr remains an independent entity. 

## Limitation
Roughly 3 years of data is used as forecast inputs, which may be insufficient to accurately predict long-term future trend