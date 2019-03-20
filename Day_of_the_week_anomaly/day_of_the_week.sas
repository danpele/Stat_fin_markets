proc import datafile="/folders/myfolders/carte/djia.csv" dbms=csv
out=date replace;
run;

*Calculăm randamentele în forma logaritmică;

proc sort data=date;by date;
data date;set date;
logprice=log (close);
logreturn=logprice-lag (logprice);
run;

data date;set date;
weekday=weekday(date);
run;

proc sort data=date;by weekday;
run;

proc means data=date;
by weekday;
var logreturn;
run;


proc anova data=date;
class weekday;
model logreturn=weekday;
means weekday/tukey;
run;


data date;set date;
if weekday=2 then Monday=1;
else Monday=0;
run;

proc reg data=date;
model logreturn=Monday;
run;
