proc import datafile="/folders/myfolders/carte/djia.csv" out=date dbms=csv replace;

run;

data date;set date;
if year(Date)<=1987;
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

proc means data=date noprint;
output out=parms mean(logreturn)=mu std(logreturn)=sigma;
run;

data date; if _n_=1 then set parms;set date;
run;

data date;set date;
if logreturn<-0.03 then i1=1;
else i1=0;
if logreturn<-0.06 then i2=1;
else i2=0;
if logreturn<-0.09 then i3=1;
else i3=0;
run;

proc means data=date noprint;
output out=prob mean(i1)=p1 mean(i2)=p2 mean(i3)=p3;
run;


data parms;set parms;
p11=cdf('Normal',-0.03, mu,sigma);
p22=cdf('Normal',-0.06, mu,sigma);
p33=cdf('Normal',-0.09, mu,sigma);
run;

proc transpose data=prob out=empiric;
run;
data empiric(keep=Empiric);set empiric;
rename col1=Empiric;

if _n_<=2 then delete;

data empiric;set empiric;
T_c_empiric=1/(250*Empiric);
run;


proc transpose data=parms out=normal;
run;

data normal(keep=Normal );set normal;
rename col1=Normal;
if _n_>4;
T_c_normal=1/(250*Normal);
run;

data normal;set normal;
T_c_normal=1/(250*Normal);
run;

data c;

infile DATALINES dsd missover;
input c;
CARDS;
-0.03
-0.06
-0.09
;
run;

data results;merge c empiric normal;
run;

data results;set results;
label empiric='Prob(r<c) - empirical';
label normal='Prob(r<c) - Normal';
label T_c_empiric='Periodicity (years) - empirical';
label T_c_normal='Periodicity (years) - Normal';

title 'Probability of extreme events for DJIA returns';
proc print data=results label;
run;




