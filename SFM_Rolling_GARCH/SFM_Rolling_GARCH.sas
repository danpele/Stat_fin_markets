***********************************************************************
Name of QuantLet : SFM_Rolling_GARCH

Published in : Stat_fin_markets

Description : 'SFM_Rolling GARCH estimates GARCH models for Bitcoin using a rolling window approach and estimates the Value at Risk.'

Keywords : GARCH, Value at Risk, VaR, Bitcoin, BTC

Author: Daniel Traian Pele

Submitted : Thuesday, 26 March 2019

Output:   'Volatility forecasts using a GARCH(1,1) model with Student residuals.'

Dataset: 'BTC_data.xlsx'
***********************************************************************;

option nonotes;
* Reset the working evironment;
goptions reset = all;
proc datasets lib = work nolist kill;
run;

proc import datafile="/home/danpele/Stat_fin_markets/BTC_data.xlsx" dbms=xlsx 
		out=date replace;
run;

proc sort data=date;
	by date;
run;

data date;
	set date;
	year=year(date);
	logreturn=log(close)-log(lag(close));

	if logreturn=. then
		delete;
run;

data date;
	set date;

	if year>=2017;
	y=logreturn;
	t=_n_;
run;

proc sgplot data=date;
	series x=date y=close;
run;

proc sgplot data=date;
	series x=date y=logreturn;
run;

data date;set date;
y=logreturn**2;
run;

proc arima data=date;
identify var=y;
run;



/* Estimate GARCH(1,1) with t-distributed residuals with AUTOREG*/
proc autoreg data=date;
	ods output ParameterEstimates=Parms_t;
	model logreturn=/  garch=(q=1, p=1) dist=t maxiter=1000;
	output out=garch_t cev=variance_garch_t;
run;




title 'Conditional variance GARCH(1,1) - t distribution';

proc sgplot data=garch_t;
	series x=date y=variance_garch_t;
run;

title;

data date;set date;
ar_1=lag(logreturn);


/* Estimate GARCH(1,1) with Normal-distributed residuals with AUTOREG*/
proc autoreg data=date;
	ods output ParameterEstimates=Parms_n;
	model logreturn= /  garch=(q=2, p=2) maxiter=1000;
	output out=garch_n cev=variance_garch_n;
run;

%let winsize=250;
proc iml;
	use date;
	read all var {logreturn} into x;
	close date;
	mrows=nrow(x)-&winsize+1;
	inc=&winsize-1;
	var_empiric=j(mrows, 3, 0);

	do r=1 to mrows;
		w=x[r:r+inc];
		p={0.01, 0.025, 0.05};
		call qntl(q, w, p);
		var_empiric[r, 1]=q[1];
		var_empiric[r, 2]=q[2];
		var_empiric[r, 3]=q[3];

		create temp var {"w"};
		append;
		close temp;
		
		submit;

	data temp;
		set temp end=eof;
		output;

		if eof then
			do;
				call missing (of _all_);
				output;
			end;
	run;

	proc autoreg data=temp plots=none noprint ;
		ods output ParameterEstimates=Parms_t;
		model w=/ garch=(q=1, p=1) dist=t MAXITER = 1000;
		output out=garch_t cev=variance_garch_t;
	run;
	
	
	proc autoreg data=temp plots=none noprint ;
		ods output ParameterEstimates=Parms_n;
		model w=/ garch=(q=1, p=1)  MAXITER = 1000;
		output out=garch_n cev=variance_garch_n;
	run;
	
	data garch_n;
		set garch_n;

		if _n_=&winsize+1;
	run;
	
	
	data garch_t;
		set garch_t;

		if _n_=&winsize+1;
	run;

	data df;
		set parms_t;

		if variable='TDFI';

	data df(keep=df);
		set df;
		df=1/estimate;
	run;

	data mu(keep=mu);
		set parms_t;

		if _n_=1;
		rename estimate=mu;
	run;

	data mu_n(keep=mu);
		set parms_n;

		if _n_=1;
		rename estimate=mu;
	run;

	data garch_n;
		merge garch_n mu_n;
	run;
	
	data garch_t;
		merge garch_t mu df;
	run;

	data garch_t;
		set garch_t;
		var_garch_t_05=(quantile('T', 0.05, df)*sqrt(variance_garch_t)+mu);
		var_garch_t_01=(quantile('T', 0.01, df)*sqrt(variance_garch_t)+mu);
		var_garch_t_025=(quantile('T', 0.025, df)*sqrt(variance_garch_t)+mu);
	run;

	data garch_n;
		set garch_n;
		var_garch_n_05=(quantile('NORMAL', 0.05)*sqrt(variance_garch_n)+mu);
		var_garch_n_01=(quantile('NORMAL', 0.01)*sqrt(variance_garch_n)+mu);
		var_garch_n_025=(quantile('NORMAL', 0.025)*sqrt(variance_garch_n)+mu);
	run;

	data garch_t;merge garch_t garch_n;
	run;
	
		proc append base=var_garch data=garch_t force;
		run;
		
		quit;
		endsubmit;
		end;
		create var_empiric from var_empiric;
		append from var_empiric;
		quit;
		
		data var_empiric;
		set var_empiric;
		rename col1=var_empiric_01;
		rename col2=var_empiric_025;
		rename col3=var_empiric_05;

	data var;
		merge var_garch var_empiric;
		run;
		
data var;set var;
t=&winsize+_n_;

data date (keep=date logreturn t);set date;
t=_n_;

data var; merge date (in=a) var(in=b);
by t;
if a and b;
run;


proc sgplot data=var;
series x=date y=logreturn/ lineattrs = (color = blue THICKNESS = 1.5);
series x=date y=var_empiric_05/ lineattrs = (color = red THICKNESS = 1.5 pattern=dash);
series x=date y=var_garch_t_05/ lineattrs = (color = green THICKNESS = 1.5 pattern=dash);
series x=date y=var_garch_n_05/ lineattrs = (color = black THICKNESS = 1.5 pattern=dash);
run;