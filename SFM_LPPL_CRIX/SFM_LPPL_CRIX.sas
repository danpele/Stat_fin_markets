
proc datasets lib=work nolist kill;
run;

proc import datafile=
"D:\PROIECTE\Metcalfe law and LPPL models for cryptos\crix.xlsx" out=date dbms=xlsx replace;
run;
data date;set date;
format date ddmmyy10.;


run;
proc sort data=date;by date;

run;

symbol  i=line v=none w=2 color=red interpol=join height=1;

proc gplot data=date;
plot close*date;
run;
quit;


data date;set date;
year=year(date);
month=MONTH(date);
    day=DAY(date) ;
week=week(date);
    week_day=WEEKDAY(date);
    quarter=QTR(date);
	ymw=year||month||week;
		logprice=log(close);
	abs=-abs(close-lag(close));
	logprice=log(close);
	logreturn=logprice-lag(logprice);
run;




* Se retin doar observatiile incepind cu anul 2001;
data date;set date;if year>=2016;


data date;set date;
tt=_n_;
abss=lag(abs);
run;

* Esantionul initial este 3.01.2001-29.06.2007;
data date1;set date;
if date<'15DEC2017'd;
run;


%macro regresie(window=);
%let dsid=%sysfunc(open(date1));
%let num=%sysfunc(attrn(&dsid,nlobs));
%let rc=%sysfunc(close(&dsid));




  %do k = 1 %to &window;
      %let numfin= %eval( &num+&k);

  %let firstobs=%eval(1);
    %let lastobs = %eval( &numfin);
data temp&k;set date(firstobs=&firstobs obs=&lastobs);

data t&k(keep=a b t tcc);set date;
if _n_=&lastobs+1;
a=logprice;
b=abs;
t=&lastobs+1;
tcc=tt;
run;

data _null_;
set t&k;
call symput('a', a);
call symput('b', b);
call symput('t', t);
call symput('tcc', tcc);

run;
ods output 'Nonlinear OLS Summary of Residual Errors'=gof&k;
ods output 'Nonlinear OLS Summary of Residual Errors (Estimates Not Converged)'=goff&k;

Proc model data=temp&k ;
parms a=&a b=&b  c=0 tc=%eval(&lastobs+1) beta=0.33 om=6.36 fi=3.14 ;
  *bounds a>0, b<0, -1<c<1, 0<beta<1, om>0, 0<fi<6.28 ,tc>&lastobs;
  
*bounds tc>&lastobs;
logprice=a+(b*(tc-tt)**(beta)*(1+c*cos(om*log(tc-tt)+fi))) ; 

 fit logprice/  outest=estim&k  prl=both  ; 
Run;
quit;
data estim&k;set estim&k;
tcc=&tcc;
k=&k;
run;
ods output close;
ods output close;

%end;


%do k=1 %to &window;
DATA _NULL_;
  CALL SYMPUT ('N_G', PUT (N, BEST12.)); 
  SET gof&k NOBS=N;
RUN;
%PUT N=&N_B;
DATA _NULL_;
  CALL SYMPUT ('N_B', PUT (N, BEST12.)); 
  SET goff&k NOBS=N;
RUN;
%PUT N=&N_G;
data estimat&k;merge estim&k gof&k;
if &N_G>0;
run;
data estimat&k;merge estim&k goff&k;
if &N_B>0;
run;
proc append base=estimates data=estimat&k force;
quit;
proc datasets lib=work nolist ;
delete temp&k;
proc datasets lib=work nolist ;
delete t&k;
proc datasets lib=work nolist ;
delete estim&k;
proc datasets lib=work nolist ;
delete gof&k;
proc datasets lib=work nolist ;
delete estimat&k;
%end;
quit;
%mend;

%regresie(window=20);

data est;set estimates;
if _status_='0 Converged';
run;

proc sort data=est;by rmse;
run;


data est;set est;
r=rmse/lag(rmse)-1;
proc sort data=est;by tc;

data est;set est;
*if int(tc)-tcc>k;
run;
data est;set est;
*if tc>tcc;
run;

proc sort data=est;by tc;
symbol   i=line v=none w=1 color=blue interpol=join height=0.1;

data estfin;set estimates;
if  _status_='0 Converged';

proc sort data=estfin;by tc;
proc gplot data=estfin;
plot rmse*tcc;
run;
quit;



proc sort data=estfin;by  rmse;
data crash;set estfin;
if _n_=1;
run;
data test;set date; if _n_=1 then set crash;
run;



data test;set test;
lppl=a+b*(tc-tt)**beta*(1+c*cos(om*log(tc-tt)+fi)); 
if lppl<0 then if lppl ne . then delete;
run;
symbol1 color=red  interpol=none w=1 value=star height=0.1;
symbol2   i=line v=none w=3 color=blue interpol=join height=0.1;



proc gplot data=test ;
plot logprice*date lppl*date/overlay;
run;
quit;



data estimates;set estimates;
tt=int(tc+1);
run;
proc sort data=estimates;by tt;
data est1;merge estimates(in=aa) date(in=bb);
by tt;
if aa and bb;
proc sort data=est1;by date;
symbol1 color=red  interpol=join w=1 value=star height=0.1;



proc gplot data=est1 ;
plot beta*date;
run;
quit;


data estttt;set est;
time=int(tc);
run;
proc sort data=estttt;by time;

data timp(keep=date time);set date;
time=tt;
run;

data est_graph;merge estttt(in=aa) timp(in=bb);
by time;
if aa and bb;
run;

symbol  i=line v=none w=1 color=blue interpol=join height=0.05;

proc sort data=est_graph;by _Data;
proc gplot data=est_graph ;
plot om*date;
run;
quit;

proc print data=crash;
run;

proc print data=estfin;
run;


