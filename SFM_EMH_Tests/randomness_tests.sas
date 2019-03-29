* ---------------------------------------------------------------------
* Quantlet:     Randomness_tests
* ---------------------------------------------------------------------
* Description:  Randomness_tests performs the following tests for the Random
				Walk Hypothesis: The Durbin-Watson test, the Ljung-Box test,
				the Breusch-Godfrey test.
* ---------------------------------------------------------------------
* Usage:        SAS 9.2, SAS 9.3, SAS 9.4, SAS University Edition
* ---------------------------------------------------------------------
* See also:     https://statcompute.wordpress.com

*----------------------------------------------------------------------
* Keywords:     Durbin-Watson test, Ljung-Box test,
				Breusch-Godfrey test.
*----------------------------------------------------------------------
* Inputs:       data - the input dataset
				x - the time series to be tested (e.g. logreturns)
* ---------------------------------------------------------------------
* Output:       The test statistics and p-value
* ---------------------------------------------------------------------
* Usage:         use %include "path\randomness_tests.sas"  	
				 invoke the macro like this: %randomness_tests(data=..., x=...) 
-----------------------------------------------------------------------
* Author:       Daniel Traian Pele    
* ---------------------------------------------------------------------;

%macro randomness_tests(data = , var = , lags =);
***********************************************************;
* SAS MACRO PERFORMING LJUNG-BOX TEST FOR INDEPENDENCE    *;
* ======================================================= *;
* INPUT PAREMETERS:                                       *;
*  DATA : INPUT SAS DATA TABLE                            *;
*  VAR  : THE TIME SERIES TO TEST FOR INDEPENDENCE        *;
*  LAGS : THE NUMBER OF LAGS BEING TESTED                 *;
* ======================================================= *;
* AUTHOR: WENSUI.LIU@53.COM                               *;
***********************************************************;
 
%local nlag; 
 
data _1 (keep = &var);
  set &data end = eof;
  if eof then do;
    call execute('%let nlag = '||put(_n_ - 1, 8.)||';');
  end;
run;
 
proc arima data = _last_;
  identify var = &var nlag = &nlag outcov = _2 noprint;
run;
quit;
 
%do i = 1 %to &lags;
  data _3;
    set _2;
    where lag > 0 and lag <= &i;
  run;
 
  proc sql noprint;
    create table
      _4 as
    select
      sum(corr * corr / n) * (&nlag + 1) * (&nlag + 3) as _chisq,
      1 - probchi(calculated _chisq, &i.)              as _p_chisq,
      &i                                               as _df
    from
      _last_;
  quit;
 
  %if &i = 1 %then %do;
  data _5;
    set _4;
  run;
  %end;
  %else %do;
  data _5;
    set _5 _4;
  run;
  %end;
%end;
 
title;
proc report data = _5 spacing = 1 headline nowindows split = "*";
  column(" * Ljung-Box test for white noise *
           * H0: Logreturns are uncorrelated upto lag &lags * "
          _chisq _df _p_chisq);
  define _chisq   / "Chi-Square" width = 20 format = 15.3;
  define _df      / "df"         width = 10 order;
  define _p_chisq / "P-Value"    width = 20 format = 15.3;
run;
 

********************************************************************;
* SAS MACRO PERFORMING BREUSCH-GODFREY TEST FOR SERIAL CORRELATION *;
* BY FOLLOWING THE LOGIC OF BGTEST() IN R LMTEST PACKAGE           *;
* ================================================================ *;
* INPUT PAREMETERS:                                                *;
*  DATA  : INPUT SAS DATA TABLE                                    *;               
*  X     : INDEPENDENT VARIABLES IN THE ORIGINAL REGRESSION MODEL  *;
*  ORDER : THE ORDER OF SERIAL CORRELATION                         *;
* ================================================================ *;
* AUTHOR: WENSUI.LIU@53.COM                                        *;
********************************************************************;
data &data;set &data;
x1=lag(&var);
run;

 proc reg data=&data noprint plots=none;
 model &var=x1;
 output out=results_reg residual=r;
 run;
 
 
data _1 (drop = _i);
  set results_reg (keep = r &var);
  %do i = 1 %to &lags;
    _lag&i._r = lag&i.(r);
  %end;
  _i + 1;
  _index = _i - &lags;
  if _index > 0 then output;
run;
 

proc reg data = _last_ noprint plots=none;
  model r = &var _lag:;
  output out = _2 p = yhat;
run;
 

proc sql noprint;
create table
  _result as
select
  (select count(*) from _2) * sum(yhat ** 2) / sum(r ** 2)   as _chisq,
  1 - probchi(calculated _chisq, &lags.)                     as _p_chisq,
  &lags                                                      as _df
from
  _2;
quit;
 
title;
proc report data = _last_ spacing = 1 headline nowindows split = "*";
  column(" * Breusch-Godfrey test for serial correlation
           * H0: there is no serial correlation of any order up to &lags * "
          _chisq _df _p_chisq);
  define _chisq   / "Chi-Square" width = 20 format = 15.3;
  define _df      / "df"         width = 10;
  define _p_chisq / "P-value"    width = 20 format = 15.3;
run;
 

proc rank data=&data out=rank_data ;
 var &var;
run;
 
* Calculate the square of the differences;
data numerator;
 set rank_data;
 d=dif(&var)**2;
run;

* Calculate the sum of the squared differences;
proc means data=numerator sum noprint;
 var d;
 output out=numerator2 sum=numerator;
run;

* Calculate the empirical variance of the values;
proc means data=rank_data var noprint; 
 var &var;
 output out=denumerator var=variance;
run;

* Calculate test statistic and p-values;
data neumann;
 merge numerator2 denumerator;

 format p_value_A p_value_B p_value_C pvalue8.;

 n=_FREQ_;
 rvn=numerator/((n-1)*variance);
 z=(rvn-2)/sqrt(4/n);

 p_value_A=2*probnorm(-abs(z));
 p_value_B=1-probnorm(z);
 p_value_C=probnorm(z);
run;
 

* Output results;
proc print split='*' noobs;
 var rvn z p_value_A p_value_B p_value_C;
 label rvn='von Neuman rank statistic*'
       z='Test statistic Z*'
       p_value_A='p-value A*'
	   p_value_B='p-value B*'
	   p_value_C='p-value C*';
 title 'von Neuman Rank Test';
run;
 
 
 %mend;


