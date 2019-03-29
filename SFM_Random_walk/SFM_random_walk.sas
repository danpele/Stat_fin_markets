***************************
Name: SFM_random_walk

Description : 'Simulates the path of a random walk over 1000 time points. Epsilon terms/innovations
are normally distributed - N(0,1).'

Keywords : 'normal-distribution, plot, random, random-number-generation, random-walk, simulation,
standard-normal, stochastic-process, time-series'

See also : ar1_process, randomwalk_ar1

Author : Daniel Traian Pele





*************************************************;
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

