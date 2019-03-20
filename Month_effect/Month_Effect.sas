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
