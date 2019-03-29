*Import data from a csv file;

proc import datafile="/folders/myfolders/carte/djia.csv" dbms=csv
out=date replace;
run;

*Compute log-returns;

proc sort data=date;by date;
data date;set date;
logprice=log (close);
logreturn=logprice-lag (logprice);
run;

*Descriptive statistics and histogram of log-returns;
proc univariate data=date;
var logreturn;
histogram;
run;
quit;

data date_negativ;set date;
if logreturn<0;
x=-logreturn;

proc univariate data=date_negativ;
var x;
histogram;
run;



proc means data=date noprint;
output out=medii p10(logreturn) =q10 n(logreturn) =n mean(logreturn)=mu std(logreturn)=std;
run;

data date; if _n_=1 then set medii;set date;
run;

*Empirical cumulative distribution function;
proc sort data=date;by logreturn;
data date;set date;
if logreturn ne . then p=1/n;
run;

data date;set date;
f_rep+p;
run;

*Plot ECDF;
proc sgplot data=date;
series y=f_rep x=logreturn;
run;
quit;

*Sample the left tail, 10%, and estimate the parameters of Pareto distribution;

data pareto;set date;
if logreturn<q10;


data pareto;set pareto;
x=abs(logreturn);
ln_x=log(x);
ff_rep=1-f_rep;
ln_f_rep=log(f_rep);
run;
proc reg data=pareto outest=parms;
model ln_f_rep=ln_x;
run;
quit;
*The dataset ‘parms’ contains the estimated values for alfa and C;

data parms (keep=c alpha);set parms;
alpha=-ln_x;
c=exp(intercept/alpha);
run;


data pareto; if _n_=1 then set parms; set pareto;
run;

data pareto;set pareto;
f_rep_pareto=(c/x)**alpha;
f_rep_normal=1-cdf('normal',x,mu,std);
run;

proc sgplot data=pareto;
series x=x y=f_rep;
series x=x y=f_rep_pareto;
series x=x y=f_rep_normal;
run;




