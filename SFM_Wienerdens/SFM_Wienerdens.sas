* ------------------------------------
* Quantlet:     SFM_wienerdens
* ---------------------------------------------------------------------
* Description:  Plots the conditional distribution of a Wiener process,
*				derived from the Markov property. 
-------------------------------------------
* Keywords:		Wiener process, simulation, stochastic process, Markov.
* ---------------------------------------------------------------------
* Inputs:       dt - delta t
*               c - constant
*               s - time moment
*               a - left limit
*               b - right limit
*               x0 - initial value of the process
* ---------------------------------------------------------------------
* Output:       Plot of Wiener process simulation and its conditional density.
* ---------------------------------------------------------------------
* Example:      An example is produced for the values: [dt, c, s]=
*               [0.01, 2, 150], [a, b, x0] = [90, 110, 50]
* ---------------------------------------------------------------------
* Author:       Daniel Traian Pele
* ---------------------------------------------------------------------;

goptions reset=all;

%let dt = 0.01;	*input Delta t;
%let c  = 2; 	*input Constant c;
%let s  = 150;	*input time moment s;
%let a  = 90;	*input left limit;
%let b  = 110;	*input right limit;
%let x0 = 50;	*input the initial value of the process;

*Main calculation;

proc iml;
dt = &dt;
c  = &c;
s  = &s;
a  = &a;
b  = &b;
x0 = &x0;

l = 200;
n = floor(l/dt);
t = do(0, n*dt, dt)`;
call randseed(0); 
z = j(n,1,0);  
call randgen(z, "Uniform");	*Create a matrix of uniform random variables on [0,1];
z = 2*(z>0.5)-1;
z = z*c*sqrt(dt);  			*to get finite and non-zero variance;
w = j(n,1,0);
w = x0+cusum(z);
w = (x0||w`)`;

* Computing the normal distribution;
max1   =  max(w);
min1   =  min(w);
sigma  =  sqrt(max(t)-s)*c;
mu     =  w[s/dt,1];
ndata  = do(min1-sigma**2,sigma**2*(max1-min1),0.2)`;
pi     = constant('pi');
f      =  750*1/sqrt(2*pi*sigma*sigma)*exp(-(ndata-mu)##2/(2*sigma**2) )+max(t);

fndata = (ndata)||(100*f);
maxf   = max(fndata[,2]);
maxt   = max(t)*100;
create fndata from fndata;append from fndata;
close fndata;
minmax = min1||max1||mu||sigma||maxf||maxt;
create minmax from minmax;append from minmax;
close minmax;
w = t||w;
create w from w; append from w;
close w;
quit;


data w;set w;
rename col1 = t col2 = W;
iterations = _n_;
data fndata;set fndata;
rename col1 = x  col2 = f;

run;

data minmax;set minmax;
rename col1 = min1 col2 = max1 col3 = mu col4 = sigma col5 = maxf col6 = maxt;

data minmax;set minmax;
low  = min1 - sigma;
upp  = max1 + sigma;
maxy = maxf+1000;
refS = 100*&S;
low1 = mu - sigma;
upp1 = mu +sigma;

data _null_;set minmax;
call symput('min1',min1);
call symput('max1',max1);
call symput('sigma',sigma);
call symput('maxf',maxf);
call symput('maxy',maxy);
call symput('low',low);
call symput('upp',upp);
call symput('maxt',maxt);
call symput('refS',refS);
call symput('low1',low1);
call symput('upp1',upp1);
call symput('mu',mu);

run;



data date; merge w fndata;
run;

data date;set date;
if &refS<=iterations<=&maxt then rline = &mu;

run;


*Plot the conditional distribution of a Wiener process;
ods graphics on;
title Wiener process simulation;

proc sgplot data = date noautolegend;

band y = x  lower = &maxt upper = f / fillattrs = (color = red); 
band x = f  lower = 0 upper = &low1 / fillattrs = (color = white); 
band x = f  lower = &upp1 upper = &maxy / fillattrs = (color = white); 

series x = iterations y=w /lineattrs   =   (color   =   blue THICKNESS   =   1.5 ) ;
series x = f y = x/lineattrs   =   (color   =  red THICKNESS   =   4 ) ;
series x=iterations y=rline / lineattrs = (color = black  pattern = dash THICKNESS   =   4);

yaxis min = &low max = &upp ;
xaxis min = 0 max = &maxy;
y2axis min = -200 max = 200;
refline &maxt / axis = x lineattrs = (color = black  THICKNESS   =   4);
refline &refS / axis = x lineattrs = (color = black  THICKNESS   =   4);

run;
quit;

ods graphics off;
