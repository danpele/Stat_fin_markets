[<img src="https://github.com/QuantLet/Styleguide-and-FAQ/blob/master/pictures/banner.png" width="888" alt="Visit QuantNet">](http://quantlet.de/)

## [<img src="https://github.com/QuantLet/Styleguide-and-FAQ/blob/master/pictures/qloqo.png" alt="Visit QuantNet">](http://quantlet.de/) **SFM_LogNormal** [<img src="https://github.com/QuantLet/Styleguide-and-FAQ/blob/master/pictures/QN2.png" width="60" alt="Visit QuantNet 2.0">](http://quantlet.de/)

```yaml

Name of QuantLet : SFM_LogNormal

Published in : Stat_fin_markets

Description : 'Plots the probability density function for Normal and LogNormal distribution.'

Keywords : normal, lognormal, density, simulation

Author: Daniel Traian Pele

Submitted : Fri, 22 March 2019

Output:   'Plots comparing normal and lognormal densities.'




```

![Picture1](SFM_LogNormal.png)

### SAS Code
```sas


* Quantlet:     SFM_lognormal
* -------------------------------------------------------------------------
* Description:  SFM_lognormal plots the normal and log normal 
*               distributions.
*--------------------------------------------------------------------------
* Usage:        -
*--------------------------------------------------------------------------
* Keywords:     normal, lognormal, density, simulation
* -------------------------------------------------------------------------
* Inputs:       none
*--------------------------------------------------------------------------
* Output:       Plots comparing normal and lognormal densities.          
* -------------------------------------------------------------------------
* Example:      
*--------------------------------------------------------------------------
* Author  :    Daniel Traian Pele
*--------------------------------------------------------------------------;


* Reset the working evironment;
goptions reset = all;
proc datasets lib = work nolist kill;
run;

* Create the data for plotting the two distributions;
data plot;
do t = -5 to 15 by 0.1;
normal = pdf('normal',t);
output; end;

do i =  0.01 to 15 by 0.1;
lognormal = pdf('lognormal',i);
output;end;
run;

*Plot the densities;

title Normal and Log Normal Distribution;

proc sgplot data   =   plot;
series x   =   t  y   =   normal/ lineattrs   =   (color   =   blue THICKNESS   =   2 );
series x = i y = lognormal/lineattrs   =   (color   =   red THICKNESS   =   2 pattern = dash) ;
yaxis label   =  'Density';
xaxis label   =  'Value';
run;
quit;


```

automatically created on 2019-03-29