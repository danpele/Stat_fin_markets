
proc import datafile="/folders/myfolders/new_data_paper_crypto.xlsx" dbms=xlsx out=date replace;
run;

proc sort data=date;by date;


data date;set date;
logprice=log(close);
logreturn=logprice-lag(logprice);

logmarketcap=log(market_cap);
logusers=log(unique_adresses);
lag_logusers=lag(logusers);
logwallets=log(wallets);
ch_users=logusers-lag(logusers);
run;


data date;set date;
if logprice=. then delete;

data date;set date;
if date>='24AUG2010'd;
run;


proc reg data=date;
model logmarketcap=logusers/dw;
model logprice=logusers/dw;
run;





%let winsize=60;

proc iml;
	start InvEx(A);
	errFlag=1;

	
	on_error="if errFlag then do;  AInv = .; resume; end;";
	call push(on_error);

	/* PUSH code that will be executed if an error occurs */
	AInv=inv(A);

	/* if error, AInv set to missing and function resumes */
	errFlag=0;

	/* remove flag for normal exit from module */
	return (AInv);
	finish;

start Regress (ret_est, rsquare,beta, x,y);                    /* begin module        */
	x0t=j(nrow(x), 1,1);

	/* x0t is a row vector of ones */
	x1=(x0t||x);
  xpxi = inv(x1`*x1);               /* inverse of X'X      */
  beta = xpxi * (x1`*y);           /* parameter estimate  */
  yhat = x1*beta;    /* predicted values    */
 

  resid = y-yhat;                 /* residuals           */

  sse = ssq(resid);               /* SSE                 */
  n = nrow(x1);                    /* sample size         */
  dfe = nrow(x)-ncol(x1);          /* error DF            */
  mse = sse/dfe;                  /* MSE                 */
  cssy = ssq(y-sum(y)/n);			/* corrected total SS  */
  cssyhat = ssq(yhat-sum(y)/n);
  rsquare = cssyhat/cssy;      /* RSQUARE             */
  results = sse || dfe || mse || rsquare;

  stdb = sqrt(vecdiag(xpxi)*mse); /* std of estimates    */
  t = beta/stdb;                  /* parameter t tests   */
  prob = 1-probf(t#t,1,dfe);      /* p-values            */
  paramest = beta || stdb || t || prob;
  ret_est=yhat-lag(yhat,1);


finish Regress;                   /* end module          */
	

	/* end module          */
	start rolling_reg (var, a, b);
	mrows=nrow(a)-&winsize+1;
	inc=&winsize-1;
	var=j(mrows,2,0);


	do r=1 to mrows;
		x=a[r:r+inc];
		y=b[r:r+inc];
	call Regress(ret_est, rsquare,beta, x, y);
		 ret=y-lag(y,1);


		var[r,1]=rsquare;
		var[r,2]=beta[2,1];
		end;
	
	
	finish;
	use date;
	read all var {logusers} into x;
	read all var {logmarketcap} into y;
	call rolling_reg(var, x, y);
	
	create var from var;
	append from  var;
	
	close date;
	


	quit;
	

data var;
	set var;

		rename col1=rsquare;
		rename col2=beta;
	t=_n_+&winsize;
run;

data date;
	set date;

t=_n_;
run;



data results;
	merge var (in=a) date(in=b);
	by t;

	if a and b;
run;


proc sgplot data=results;
	series x=date y=rsquare;

run;

proc sgplot data=results;
	series x=date y=beta;

run;

