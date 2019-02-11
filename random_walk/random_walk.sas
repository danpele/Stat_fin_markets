data rw;
pt=1;
do i=1 to 1000;
wn=0.001+rannorm(0);
pt+wn;
output;
end;
run;

proc sgplot data=rw;
series x=i y=pt;

run;

proc sgplot data=rw;
series x=i y=wn;

run;

proc arima data=rw;
identify var=pt;
identify var=wn;
run;
 
 data rw;set rw;
 rt=pt-lag(pt);
 run;
 
 
proc sgplot data=rw;
series x=i y=rt;
run;

proc arima data=rw;
identify var=rt;
run;

