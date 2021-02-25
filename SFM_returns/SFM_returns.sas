proc import datafile="/folders/myfolders/carte/djia.csv" out=date dbms=csv replace;

run;

data date;set date;
return=close/lag(close)-1;
logprice=log(close);
logreturn=logprice-lag(logprice);
if logreturn=. then delete;
run;

Title 'Daily log-returns for DJIA';
proc sgplot data=date;
series x=date y=logreturn;
run;
quit;

Title 'Log-returns distribution for DJIA';
proc univariate data=date nextrobs=10 ;
var logreturn ;
id date;
histogram/normal;
qqplot;
run;
title;