[<img src="https://github.com/QuantLet/Styleguide-and-FAQ/blob/master/pictures/banner.png" width="888" alt="Visit QuantNet">](http://quantlet.de/)

## [<img src="https://github.com/QuantLet/Styleguide-and-FAQ/blob/master/pictures/qloqo.png" alt="Visit QuantNet">](http://quantlet.de/) **SFM_Month_Effect** [<img src="https://github.com/QuantLet/Styleguide-and-FAQ/blob/master/pictures/QN2.png" width="60" alt="Visit QuantNet 2.0">](http://quantlet.de/)

```yaml

Name of QuantLet : SFM_Month_Effect

Published in : Stat_fin_markets

Description : 'Tests the callendar effect on the stock market.'
Keywords : Month Effect, EMH, anomaly

Author: Denisa Mihalache

Submitted : Wed, 20 March 2019

Output:   'ANOVA and Regression model for the Calendar Effect on DJIA.'
Dataset: 'djia.csv'



```

### SAS Code
```sas

************************************************************
CALENDAR ANOMALIES IN THE STOCK MARKET
THE MONTH OF THE YEAR EFFECT
***********************************************************
Author: DENISA MIHALACHE
Date: 20 March 2019
************************************************************;
proc import datafile="/home/denisamhlc0/Stat fin/djia.csv" dbms=csv
out=date replace;
run;

*Logreturns;

proc sort data=date;by date;
data date;set date;
logprice=log (close);
logreturn=logprice-lag (logprice);
run;

data date;set date;
month=month(date);
run;

proc sort data=date;by month;
run;

*Means by month;
proc means data=date;
by month;
var logreturn;
run;

*ANOVA;
proc anova data=date;
class month;
model logreturn=month;
means month/tukey;
run;


data date;set date;
if month=9 then September=1;
else September=0;
run;

*Regression with dummy variable for September;
proc reg data=date;
model logreturn=September;
run;

```

automatically created on 2019-03-29