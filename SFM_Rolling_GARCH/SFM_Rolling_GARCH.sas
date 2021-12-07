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

* Reset the working evironment;
goptions reset=all;

option nonotes;

proc datasets lib=work nolist kill;
	run;

proc import datafile="/home/danpele/S&P500.xlsx" dbms=xlsx
		out=date replace;
run;
proc sort data=date;
	by date;
run;

data date;
	set date;
	year=year(date);
	logreturn=(log(close)-log(lag(close)));

	if logreturn=. then
		delete;
run;

data date;set date;
if year>=2006 and year<=2010;


proc sgplot data=date;
	series x=date y=close;
run;

proc sgplot data=date;
	series x=date y=logreturn;
run;

* Estimate GARCH(1,1) with Normal distributed residuals;

proc autoreg data=date;
	model logreturn=/ garch=(q=1, p=1) maxiter=1000;
	output out=garch_normal cev=variance_garch_n;
run;

proc sgplot data=garch_normal;
	series x=date y=variance_garch_n;
run;

*Estimate GARCH(1,1) with t-distributed residuals;

proc autoreg data=date;
	model logreturn=/  garch=(q=1,p=1) dist=t  maxiter=1000 ;
	output out=garch_student cev=variance_garch_t;
run;

proc sgplot data=garch_student;
	series x=date y=variance_garch_t;
run;



%let winsize=250;

proc iml;
	use date;
	read all var {logreturn} into x;
	close date;
	mrows=nrow(x)-&winsize+1;
	inc=&winsize-1;
	var_empiric=j(mrows, 1, 0);

	do r=1 to mrows;
		w=x[r:r+inc];
		p={0.01};
		call qntl(q, w, p);
		var_empiric[r, 1]=q[1];
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

	proc autoreg data=temp plots=none noprint outest=Parms_t;
	
model w=/ garch=(q=1, p=1) dist=t MAXITER=1000 initial=(0.000606	0.00001	0.1009	0.8942	0.1433);
		output out=garch_t cev=variance_garch_t ;
	
	run;

	proc autoreg data=temp plots=none noprint outest=Parms_n;
	
		model w=/ garch=(q=1, p=1) MAXITER=1000;
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

	data df (keep=_TDFI_);
		set parms_t;

	data df(keep=df);
		set df;
		df=1/_TDFI_;
	run;


	proc means data=temp noprint;
		output out=parms var(w)=variance_emp mean(w)=mu_emp;
	run;
	data garch_n;
			if _n_=1 then
			set parms;
			set garch_n;
	data garch_t;
			if _n_=1 then
			set parms;
			set garch_t;
	data garch_t;
			if _n_=1 then
			set df;
			set garch_t;

	data garch_t;
		set garch_t;
		var_garch_t_01=(quantile('T', 0.01, df)*sqrt(variance_garch_t)+mu_emp);
	run;

	data garch_n;
		set garch_n;
		var_garch_n_01=(quantile('NORMAL', 0.01)*sqrt(variance_garch_n)+mu_emp);
	run;

	data garch;
		merge garch_t garch_n;
	run;


	data garch;
		if _n_=1 then
			set parms;
		set garch;

	data garch;
		set garch;
		var_normal_01=(quantile('NORMAL', 0.01)*sqrt(variance_emp)+mu_emp);

	proc append base=var_garch data=garch force;
	run;

	endsubmit;
	end;
	create var_empiric from var_empiric;
	append from var_empiric;
	quit;

	data var_empiric;
		set var_empiric;
		rename col1=var_empiric_01;

	data var;
		merge var_garch var_empiric;
	run;

	data var;
		set var;
		t=&winsize+_n_;

	data date (keep=date logreturn t);
		set date;
		t=_n_;

	data var;
		merge date (in=a) var(in=b);
		by t;

		if a and b;
	run;

	proc sgplot data=var;
		series x=date y=logreturn/ lineattrs=(color=black THICKNESS=1.5);
		series x=date y=var_empiric_01/ lineattrs=(color=red THICKNESS=2 
			pattern=dash);
		series x=date y=var_garch_t_01/ lineattrs=(color=green THICKNESS=2 
			pattern=dot);
		series x=date y=var_garch_n_01/ lineattrs=(color=blue THICKNESS=2 
			pattern=solid);
		series x=date y=var_normal_01/ lineattrs=(color=brown THICKNESS=2 
			pattern=shortdash);
	run;

*Binomial test for VaR;

%macro binomial (var=, alpha=);
data var;set var;
if logreturn<-abs(&var) then it=1;
else it=0;

proc means data=var noprint;
output out=binom mean(it)=p n(it)=n sum(it)=s;
run;

data binom (drop=_freq_ _type_ obs);set binom;
z=(s-&alpha*n)/sqrt(n*&alpha*(1-&alpha));
p_value=1-CDF('NORMAL',z);
run;
title &var;

proc print data=binom;
%mend;

%binomial(var=var_normal_01,alpha=0.01);
%binomial(var=var_empiric_01,alpha=0.01);
%binomial(var=var_garch_n_01,alpha=0.01);
%binomial(var=var_garch_t_01,alpha=0.01);
