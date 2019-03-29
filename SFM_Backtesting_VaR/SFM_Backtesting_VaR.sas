
option nonotes;
* Reset the working evironment;
goptions reset = all;
proc datasets lib = work nolist kill;
run;

proc import datafile="/home/danpele/Stat_fin_markets/VAR.csv" dbms=csv
		out=var replace;
run;



%macro Christoffersen(dataset=, v=,p=);
data test;set &dataset;
dv=abs(&v);

if logreturn<-dv then it=1; else it=0;
run;

*VaR Forecasting Tests (Christoffersen)
Christoffersen, P. Evaluating interval forecasts. Int. Econ. Rev. 1998, 39, 841–62.;

proc iml;
use test;
read all var {it} into ind;
T = nrow(ind);
alpha=&p;
p=sum(ind)/T;

if sum(ind)=0 then nr=sum(ind)+1;
else nr=sum(ind);
* Unconditional Coverage;
n1 = nr; 
n0 = T - n1;
pihat = n1 / (n0+n1);


LR_uc = -2*( n1*log(alpha) + n0*log(1-alpha) ) +  2*( n1*log(pihat) + n0*log(1-pihat) );
LR_uc_p=CDF('CHISQUARE',LR_uc,1);

* Independence Coverage;
n_00=0;
n01=0;
n10=0;
n_11=0;
a=T-1;
    do i = 1 to T-1;
        if ind[i] = 0 & ind[i+1]= 0  then   n_00 = n_00 + 1 ;  *0 followed by 0;
          
        else if ind[i] = 0 & ind[i+1] = 1 then n01 = n01 + 1;* 0 followed by 1;
           
        else if ind[i] = 1 & ind[i+1] = 0 then n10 = n10+1;  * 1 followed by 0;
         
        else if ind[i] = 1 & ind[i+1] = 1 then  n_11 = n_11+1;* 1 followed by 1;
        
    end; 

if n_11=0 then n11=1;else
n11=n_11;
if n_00=0 then n00=1;else
n00=n_00;
pihat01 = n01 / (n00 + n01);
pihat11 = n11 / (n10 + n11);
pihat2 = (n01 + n11) / (n00 + n01 + n10 + n11);
LR_i = -2*( (n00+n10)*log(1-pihat2) + (n01+n11)*log(pihat2) ) + 
2*( n00*log(1-pihat01) + n01*log(pihat01) + n10*log(1-pihat11) + n11*log(pihat11) );

   * Conditional Coverage   ; 
LR_CC = LR_UC + LR_I;

LR_CC_p=1-CDF('CHISQUARE',LR_cc,2);
LR_I_p=1-CDF('CHISQUARE',LR_I,1);
LR_UC_p=1-CDF('CHISQUARE',LR_UC,1);

result=j(1,8,0);

result[1,1]=p;
result[1,2]=LR_UC;

result[1,3]=LR_UC_p;
result[1,4]=LR_I;
result[1,5]=LR_I_p;

result[1,6]=LR_CC;
result[1,7]=LR_CC_p;
result[1,8]=&p;
create result from result;append from result;

quit;



data kupieck;set result;

label col1='Pr(Rt<-VaRt)';
label col2='LR_UC';
label col3='p-value LR_UC';
label col4='LR_I';
label col5='p-value LR_I';
label col6='LR_CC';
label col7='p-value LR_CC';
label col8='alpha';
run;


title 'Christoffersen test for '&v;
proc print data=kupieck label;
run;
title;

%mend;



%Christoffersen(dataset=var, v=var_empiric_01, p=0.01);
%Christoffersen(dataset=var, v=var_garch_t_01, p=0.01);


*The Diebold-Mariano test for VaR forecast comparisons (Diebold and Mariano)
Diebold, F.X. Mariano, R.S. Comparing predictive accuracy. J. Bus. Econ Stat. 1995, 13, 253–263.;


%macro Diebold_Mariano(dataset=,v1=,v2=,p=);
data test;set &dataset;
dv1=abs(&v1);

if logreturn<-dv1 then i1=1; 
else i1=0;
dv2=abs(&v2);

if logreturn<-dv2 then i2=1; else i2=0;
run;

proc means data=test noprint;
output out=index mean(i1)=i1 mean(i2)=i2;
run;

data test; if _n_=1 then set index;set test;
d1=(logreturn+abs(&v1))*(&p-i1);
d2=(logreturn+abs(&v2))*(&p-i2);
d=d1-d2;
run;

proc means data=test noprint;
output out=diebold mean(d)=d_mean std(d)=std n(d)=T;
run;

data diebold;set diebold;
z=d_mean/sqrt(std/T);
p_value=cdf('Normal',z);
run;

data test;set test;
label d1='Loss function for model 1';
label d2='Loss function for model 2';

proc sgplot data=test;
series x=date y=d1;
series x=date y=d2;
run;

title 'Diebold and Mariano test. 
Alternative hyporthesis: the model '&v1 ' performs better than the model '&v2;
proc print data=diebold;
run;
title;

%mend;



%Diebold_Mariano(dataset=var, v1=var_empiric_01, v2=var_garch_t_01, p=0.01);
