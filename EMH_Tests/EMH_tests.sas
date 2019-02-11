proc datasets lib=work nolist kill;
	run;
	*Se importa fisierul in format csv;
	FILENAME REFFILE '/folders/myfolders/master_stat_fin/BET.csv';

PROC IMPORT DATAFILE=REFFILE DBMS=CSV OUT=WORK.date;
	GETNAMES=YES;
RUN;

proc sort data=date;
	by date;
run;


data date;
	set date;
	logprice=log(close);
	lclose=lag(close);
	llogprice=lag(logprice);
	logreturn=logprice-lag(logprice);
run;


%include "/folders/myfolders/master_stat_fin/randomness_tests.sas";


%randomness_tests(data = date, var = logreturn, lags = 12);



%include "/folders/myfolders/master_stat_fin/variance_ratio_test.sas";
%include "/folders/myfolders/master_stat_fin/runs_test.sas";
%runs_test(data=date, x=logreturn);
%Variance_Ratio(data=date, price=close, q=32, alpha=0.01, time=date);


	