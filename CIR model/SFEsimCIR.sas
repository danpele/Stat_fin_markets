* ---------------------------------------------------------------------
* Book:         SFE3
* ---------------------------------------------------------------------
* Quantlet:     SFEsimCIR
* ---------------------------------------------------------------------
* Description:  SFEsimCIR plots a simulated Cox/Ingersol/Ross process
* ---------------------------------------------------------------------
* Usage:        -
* ---------------------------------------------------------------------
* Keywords:     CIR, interest rate, process, stochastic, simulation
* ---------------------------------------------------------------------
* Inputs:       n - the number of observations
*               a - the rate at which the process mean reverts
*               sigma -  the volatility
*               b - the long run average interest rate
* ---------------------------------------------------------------------
* Output:       Plot of simulated CIR process dr{t}=a(b-r_{t})dt+sigma*sqrt{r_{t}}dW_{t}
* ---------------------------------------------------------------------
* Example:      User inputs the SFEsimCIR parameters 
*               [# of observations, a, sigma, b] like 
*               [1000, 0.1, 0.01, 0.03], plots a simulated Cox/Ingersol/Ross
*               process is given.
* ---------------------------------------------------------------------
* Author:       Daniel Traian Pele

	* ---------------------------------------------------------------------;



proc datasets lib=work nolist kill;
	run;
	* user inputs parameters;
	%let n		=	1000;
	*Input n - the number of observations;
	%let a		=	0.1;
	*Input a - the rate at which the process mean reverts;
	%let sigma	=	0.01;
	*Input sigma - the volatility;
	%let b		=	0.03;
	*Input b - the long run average interest rate;
	*Main calculation;

proc iml;
	n=&n;
	a=&a;
	sigma=&sigma;
	b=&b;
	* simulates a mean reverting square root process around b;
	delta=0.1;
	x=j(n, 1, 0);
	index=(1:n)`;
	x[1, 1]=b;
	x=x||index;

	do i=2 to nrow(x);
		x[i, 1]=x[i-1, 1]+a*(b - x[i-1, 1])*delta + sigma*sqrt(delta*abs(x[i-1, 
			1]))*rannor(0);
	end;
	create x from x;
	append from x;
	close x;
	quit;
	*Plot the graph of CIR process;

data x;
	set x;
	rename col1=x col2=i;
	title 'Simulated CIR process';

proc sgplot data=x;
	series x=i y=x/lineattrs=(color=blue);
	yaxis label='Values of the process';
run;

quit;