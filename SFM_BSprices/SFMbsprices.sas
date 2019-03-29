
* Quantlet:     SFMbsprices
* ----------------------------------------------------------------------
* Description:  SFMbsprice plots BS price as a function of S, K, r, tau,
*               sigma

* Keywords:		Black Scholes, call, option, put, volatility, process, 
				maturity, strike							
* ----------------------------------------------------------------------
* Inputs:       S 		=	 the stock price;
*				K 		=	 the strike price;
*				r 		=	 the risk free interest rate;
*				tau 	= 	 the time to maturity (blue line);
*				tauu	= 	 the time to maturity (red dotted line);
*				sig 	= 	 the volatility of the first plot;
*				sigg 	= 	 the volatility of the second plot.
*-----------------------------------------------------------------------
* Output:       Plot of the Call Black-Scholes price as a function of
*               S, K, r, tau, sigma.      
* ----------------------------------------------------------------------
* Example:      The plot is generated for the following parameter values:
*               S=100, K=100, r=0.1, with the cases tau=0.6 and 
*               tauu=0.003 respectively, and sig=0.15 and sigg=0.3 
*               respectively.
*------------------------------------------------------------------------
* Author  :     Daniel Traian Pele
*------------------------------------------------------------------------;

* Reset the working evironment;
goptions reset = all;
proc datasets lib = work nolist kill;
run;

*************************************************************************;
****Please input the parameters for the Black-Scholes call price*********
*************************************************************************;

%let S 		=	100;	*Input the stock price;
%let K 		=	100;	*Input the strike price;
%let r 		=	0.1;	*Input the risk free interest rate;
%let tau 	= 	0.6;	*Input the time to maturity (blue line);
%let tauu	= 	0.003;	*Input the time to maturity (red dotted line);
%let sig 	= 	0.15;	*Input the volatility of the first plot;
%let sigg 	= 	0.3;	*Input the volatility of the second plot;



proc iml;

* Black-Scholes formula for European call price with b  =  r
(costs of carry  =  risk free interest rate -> the underlying pays no continuous dividend);

start blsprice(S,K,r,sigma,tau);

	if tau = 0 then t = 1;
	else t = 0;

	y  =  (log(S/K)+(r-sigma**2/2)*tau)/(sigma*sqrt(tau)+t);
	cdfn  =  cdf('Normal',y+sigma*sqrt(tau));

	if t = 0 then t_l  =  1;
	else t_l  =  0;
	    Call  =  S*(cdfn*t_l+t)-K*exp(-r*tau)*cdf('Normal',y)*t_l+t;
	    Put  =  K*exp(-r*tau)*(cdf('Normal',-y))*t_l+t-S*(cdf('Normal',-y-sigma*sqrt(tau))*t_l+t);
		Call_Put = j(1,2,0);
		Call_Put[1,1] = Call;
		Call_Put[1,2] = Put;
	return(Call_Put);

finish;

* Set parameters;
S  = &S;
K  = &K;
r  = &r;
tau  =  &tau;
tauu  =  &tauu;
sig  =  &sig;
sigg  =  &sigg;

* Main computation;
vS = (10:159)`;
vK = (10:159)`;
vtau = 0.01*(1:100)`;
vr = 0.01*(0:9)`*(0.5)+0.01;
vsig = 0.01*(0.01:0.6)`;
Call_Put1 = j(nrow(vS),2,0);
Call_Put2 = j(nrow(vS),2,0);
Call_Put3 = j(nrow(vS),2,0);
Call_Put4 = j(nrow(vS),2,0);

*Calculate Black Scholes prices as a function of S with two different volatilities and time to maturity;

do i = 1 to nrow(vS);
Call_Put1[i,] =  blsprice(vS[i,1], K, r, sig, tau);
end;

do i = 1 to nrow(vS);
Call_Put2[i,] =  blsprice(vS[i,1], K, r, sig, tauu);
end;

do i = 1 to nrow(vS);
Call_Put3[i,] =  blsprice(vS[i,1], K, r, sigg, tau);
end;

do i = 1 to nrow(vS);
Call_Put4[i,] =  blsprice(vS[i,1], K, r, sigg, tauu);
end;

call_put = vs||Call_Put1||Call_Put2||Call_Put3||Call_Put4;

create call_put from call_put;append from call_put;
close call_put;
quit;


data call_put;set call_put;
rename col1 = S col2 = Call1 col3 = Put1 col4 = Call2 col5 = Put2
col6 = Call3 col7 = Put3 col8 = Call4 col9 = Put4;


*Plot the Black Scholes call price (blue line) with volatility sig and time to maturity tau;
*Plot the Black Scholes call price (red dotted line) with volatility sig and time to maturity tauu;

title Call Black-Scholes price as a function of S, K=&K, 'r='&r, tau1=&tau, tau2=&tauu, sigma=&sig;

proc sgplot data  =  call_put ;
series x  =  S y  =  Call1/lineattrs  =  (color  =  blue THICKNESS  =  2)  ;

series x  =  S y  =  Call2/lineattrs  =  (color  =  red THICKNESS  =  2 pattern=dash);

yaxis label  =  'C(s,tau)';
xaxis label='S' ;
run;
quit;

*Plot the Black Scholes call price (blue line) with volatility sigg and time to maturity tau;
*Plot the Black Scholes call price (red dotted line) with volatility sigg and time to maturity tauu;


title Call Black-Scholes price as a function of S, K=&K, 'r='&r, tau1=&tau, tau2=&tauu, sigma=&sigg;

proc sgplot data  =  call_put ;
series x  =  S y  =  Call3/lineattrs  =  (color  =  blue THICKNESS  =  2);
series x  =  S y  =  Call4/lineattrs  =  (color  =  red THICKNESS  =  2 pattern=dash);

yaxis label  =  'C(s,tau)';
xaxis label='S' ;

run;
quit;

