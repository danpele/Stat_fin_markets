

proc datasets lib=work nolist kill;
run;

*Se importa fisierul in format csv;
FILENAME REFFILE '/folders/myfolders/master_stat_fin/BET.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.date;
	GETNAMES=YES;
RUN;


proc sort data=date;by date;

run;


*Se calculeaza randamentele logaritmice;
data date;set date;
logprice=log(close);
lclose=lag(close);
llogprice=lag(logprice);
logreturn=logprice-lag(logprice);
run;


proc arima data=date;
identify var=logreturn;
run;


/*Macro-ul VR calculeaza statisticile in cele doua variante ale Variance Ratio Test.
Parametrii de intrare:
 - data- setul de date;
 - logprice - variabila care contine preturile logaritmate;
 - alpha - nivelul de semnificatie(de regula 0.05);
 - date - variabila care contine data cronologica;*/

%macro VR(data=,logprice=,q=,alpha=,date=);
data date_VR;set &data;
logprice=&logprice;*log  priclogree;
logreturn=logprice-lag(logprice);
run;

proc sgplot data=date_VR;
series x=&date y=logprice;
title ' Log price';
label logprice='logprice';
label &date='time';
run;
quit;

proc sgplot data=date_VR;
series x=&date y=logreturn;
title ' LOGRETURN';
label logreturn='logreturn';
label &date='time';
run;


data date_VR;set date_VR;
%do i=2 %to &q;
%let j=&i;
logreturn&j=logprice-lag&j(logprice);*one period log return;
%end;
run;

proc means data=date_VR noprint;
var logreturn;
output out=muhat mean=muhat n=nq;


%do l=2 %to &q;
	data date&l;
	if _n_=1 then set muhat;set date_VR;
	sigatop=((logreturn-muhat)**2);
	sigatop1=lag(sigatop);
	deltop=sigatop*sigatop1;
	delbot=sigatop;
	sigctop=((logreturn&l-&l*muhat)**2);
run;

proc means data=date&l noprint;
var sigatop sigctop deltop delbot;
output out=varrat&l sum=sigatop sigctop deltop delbot;
run;

data varrat&l;set varrat&l;
q=&l;
nq=_freq_-1;
qm1=q-1;
j=1;
theta=0;
m=q*(nq-q+1)*(1-q/nq);
siga=sigatop/(nq-1);
sigc=sigctop/m;
VR=sigc/siga;
z=sqrt(nq)*(VR-1)*((2*(2*q-1)*(q-1)/(3*q))**(-1/2));

delta=nq*deltop/(delbot**2);
do until (j>qm1);
	theta=theta+((2*(q-j)/q)**2)*delta;
	j+1;
end;
z_star=sqrt(nq)*(VR-1)/sqrt(theta);
z_critic=probit(1-&alpha/2);

run;

data data varrat&l;set varrat&l;
length Decision $ 50;
lower_homo=vr-z_critic*((2*(2*q-1)*(q-1)/(3*q))**(1/2))/sqrt(nq);
upper_homo=vr+z_critic*((2*(2*q-1)*(q-1)/(3*q))**(1/2))/sqrt(nq);
lower_hetero=vr-z_critic*sqrt(theta)/sqrt(nq);
upper_hetero=vr+z_critic*sqrt(theta)/sqrt(nq);
if ((z>z_critic) or (z<-z_critic)) and not
((z_star>z_critic) or (z_star<-z_critic)) then Decision="Reject Homoskedastic RW ";
else
if not ((z>z_critic) or (z<-z_critic)) and((z_star>z_critic) or (z_star<-z_critic))
then Decision="Reject Heteroskedastic RW";
else
if ((z>z_critic) or (z<-z_critic)) and 
((z_star>z_critic) or (z_star<-z_critic)) then Decision="Reject Homoskedastic and Heteroskedastic RW";
else
if Decision=. then Decision="Cannot Reject RW";
keep nq q VR lower_homo upper_homo lower_hetero upper_hetero z z_star z_critic Decision;
label 
nq='Number of observations'
VR='VR'
lower_homo='Lower Limit under Homoskedasticity'
upper_homo='Upper Limit under Homoskedasticity'
lower_hetero='Lower Limit under Heteroskedasticity'
upper_hetero='Upper Limit under Heteroskedasticity'
z='Homoskedastic z' 
z_star='Heteroskedastic z'
*Decision='Decision';
*proc print data= varrat&l label noobs;
run;


%end;

data varrat;set varrat2;
run;

%do p=3 %to &q;

proc 
append base=varrat
data=varrat&p force;
run;
%end;
proc print data=varrat (obs=20);
run;

proc sgplot data=varrat;
series x=q y=VR;
series x=q y=lower_homo;
series x=q y=upper_homo;
title ' VARIANCE RATIO UNDER HOMOSKEDASTICITY ';
label VR='Variance ratio';
label q='q';


proc sgplot data=varrat;
series x=q y=VR;
series x=q y=lower_hetero;
series x=q y=upper_hetero;
title ' VARIANCE RATIO UNDER HETEROSKEDASTICITY ';
label VR='Variance ratio';
label q='q';

run;
quit;

%mend;


%vr(data=date,logprice=logprice,q=32,alpha=0.01,date=date);





