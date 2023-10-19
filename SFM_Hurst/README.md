[<img src="https://github.com/QuantLet/Styleguide-and-FAQ/blob/master/pictures/banner.png" width="888" alt="Visit QuantNet">](http://quantlet.de/)

## [<img src="https://github.com/QuantLet/Styleguide-and-FAQ/blob/master/pictures/qloqo.png" alt="Visit QuantNet">](http://quantlet.de/) **SFM_Hurst** [<img src="https://github.com/QuantLet/Styleguide-and-FAQ/blob/master/pictures/QN2.png" width="60" alt="Visit QuantNet 2.0">](http://quantlet.de/)

```yaml

Name of QuantLet : SFM_Hurst

Published in : Stat_fin_markets

Description : 'SFM_Hurst estimates the Hurst exponent of a fractional Brownian motion using R/S analysis.'

Keywords : 'Hurst, fractal, brownian motion, R/S analysis'

Author: Daniel Traian Pele

Submitted : Fri, 22 March 2019

Input: 'data- the dataset, var - the variable'

Output:   'The Hurst exponent and the 95% confidence limit.'

Dataset: 'bet.csv'

Example: 'Hurst exponent for the BET index.'

Usage: '%fractal_hurst(data=date,var=logreturn);'


```

### SAS Code
```sas

 
* ---------------------------------------------------------------------
* Quantlet:    SFM_Hurst
* ---------------------------------------------------------------------
* Description:  SFM_Hurst estimates the Hurst exponent using R/S analysis.
* ---------------------------------------------------------------------

* Keywords:     fractal, Hurst exponent
*----------------------------------------------------------------------
* Input:       data- SAS dataset containing the data
*				var - time series for estimating the Hurst exponent.
* ---------------------------------------------------------------------
* Output:      hurst- SAS dataset containing the value of Hurst exponent.
* ---------------------------------------------------------------------
* Example:      An example is generated for a simulated gaussian white noise
*				for which H=0.5.
* ---------------------------------------------------------------------
* Author:       Daniel Traian Pele    
* ---------------------------------------------------------------------;
proc printto;
run;
 proc import datafile=
"/folders/myfolders/carte/BET.csv" out=date dbms=csv replace;

run;

data date;set date;

t=_n_;
year=year(data);
	logreturn=log(close)-log(lag(close));
	if logreturn= . then delete;
run;
                                                                                                                                   

%macro fractal_hurst(data=,var=);
data &data;set &data;
if &var=. then delete;
run;
proc iml;                                                                                                                               
use &data; 
READ all var {&var} into y;    
n=nrow(y);  
p=int(log2(n/16));
pp=2**p;
		
rsp=j(pp,p,0);
nm=j(p,1,0);

do q=0 to p;
		k=2**q; 
		delta=int(n/k);
		xt=j(delta,1,0); 
		st= j(delta,1,0);
		gt=j(delta,1,0);
		do i=1 to k;
				do j=1 to delta;                                                                                                                            

				xt[j]=y[(i-1)*delta+j];                                                                                                          
				end;                                                                                                                                    
				    mean = mean(xt);

				     std = sqrt(var(xt));


				st=xt-mean;
				gt[1]=st[1];
				do l=2 to delta;                                                                                                                            
				gt[l]=gt[l-1]+st[l];                                                                                                          
				end;                                                                                                                                    
				gmax=max(gt);
				gmin=min(gt);
				rrs=(gmax-gmin)/std;
				rsp[i,q+1]=rrs;
				nm[q+1,1]=delta;

		end;

end;

nonzero=j(pp,p,0);


do i=1 to pp;
 do j=1 to p;
 if rsp[i,j]>0 then nonzero[i,j]=1;
 end;
 end;

s=j(p,1,0);
nr=j(p,1,0);
rs=j(p,1,0);
do i=1 to p;
s[i]=sum(rsp[,i]);
nr[i]=sum(nonzero[,i]);
rs[i]=s[i]/nr[i];
end;


y=log(rs);
x=log(nm);
hurst=x||y;

	create hurst from hurst;append from hurst;
quit;

data hurst;set hurst;
rename col1=x;
rename col2=y;
run;

<<<<<<< HEAD:SFM_Hurst/SFM_Hurst.sas
*The slope of this regression model is the Hurst exponent;
=======
>>>>>>> 182e6c308c8f2495bc8a935b90fcfeb21934823e:Hurst_exponent/fractal_hurst.sas

proc reg data=hurst plots=none;
model y=x/ ss1 ss2 stb clb covb corrb;
run;

<<<<<<< HEAD:SFM_Hurst/SFM_Hurst.sas

%mend;
%fractal_hurst(data=date,var=logreturn);
=======
%mend;
%fractal_hurst(data=date,var=logreturn);

>>>>>>> 182e6c308c8f2495bc8a935b90fcfeb21934823e:Hurst_exponent/fractal_hurst.sas

```

automatically created on 2019-03-29