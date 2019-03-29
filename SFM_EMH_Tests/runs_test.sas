* ---------------------------------------------------------------------
* Quantlet:     runs_test
* ---------------------------------------------------------------------
* Description:  runs_test performs the The Wald-Wolfowitz test, 
				also known as the Runs test for randomness, 
				to test the hypothesis that a series of numbers is random.
* ---------------------------------------------------------------------
* Usage:        SAS 9.2, SAS 9.3, SAS 9.4, SAS University Edition
* ---------------------------------------------------------------------
* See also:     A run is a set of sequential values that are either all
				 above or below the mean.
 				To simplify computations, the data are first centered about 
 				their mean. 
 				To carry out the test, the total number of runs is computed 
 				along with the number of positive and negative values. 
 				A positive run is then a sequence of values greater than zero,
 				and a negative run is a sequence of values less than zero.
 				We can then test if the number of positive and negative runs 
 				are distributed equally in time.
				The test statistic is asymptotically normally distributed, 
				so this program computes Z, the large sample test statistic, as follows:
				
				Z = (R – E(R)) / sqrt(V(R))
				
				where R is number of runs. The expected value and variance of R are:
				
				E(R) = ( 2nm / (n + m) ) + 1
				V(R) = ( 2nm(2nm – n – m )) / ((n + m)2 (n + m – 1))
				
				where n is the number of positive values and m is the number of negative values. 
				Mendenhall, Scheaffer, and Wackerly (1986), Mathematical Statistics
				with Applications, 3rd Ed., Duxbury Press, CA.
				Wald, A. and Wolfowitz, J. (1940), "On a test whether two samples are from the
				same population," Ann. Math Statist. 11, 147-162. 
*----------------------------------------------------------------------
* Keywords:     Runs test, Wald-Wolfowitz test
*----------------------------------------------------------------------
* Inputs:       data - the input dataset
				x - the time series to be tested (e.g. logreturns)
* ---------------------------------------------------------------------
* Output:       The test statistics and p-value
* ---------------------------------------------------------------------
* Usage:         use %include "path\runs_test.sas"  	
				 invoke the macro like this: %runs_test(data=...., x=....) 
-----------------------------------------------------------------------
* Author:       Daniel Traian Pele    


	* ---------------------------------------------------------------------;

	%macro runs_test(data=, x=);
		*The MEAN=0 option in the PROC STANDARD step below centers the variable D about its mean. ;

	proc standard data=&data out=standard mean=0;
		var &x;
	run;

	*The following DATA step computes the total number of runs (RUNS), 
	the number of positive values (NUMPOS), and the number of negative values (NUMNEG). ;

	data runcount;
		set standard nobs=nobs;

		if &x=0 then
			delete;

		if &x>0 then
			n+1;

		if &x<0 then
			m+1;
		retain runs 0 numpos 0 numneg 0;
		previous=lag(&x);

		if _n_=1 then
			do;
				runs=1;
				prevpos=.;
				currpos=.;
				prevneg=.;
				currneg=.;
			end;
		else
			do;
				prevpos=(previous > 0);
				currpos=(&x > 0);
				prevneg=(previous < 0);
				currneg=(&x < 0);

				if _n_=2 and (currpos and prevpos) then
					numpos+1;
				else if _n_=2 and (currpos and prevneg) then
					numneg+1;
				else if _n_=2 and (currneg and prevpos) then
					numpos+1;
				else if _n_=2 and (currneg and prevneg) then
					numneg+1;

				if currpos and prevneg then
					do;
						runs+1;
						numpos+1;
					end;

				if currneg and prevpos then
					do;
						runs+1;
						numneg+1;
					end;
			end;
	run;

	data runcount;
		set runcount end=last;

		if last;
	run;

	*Finally, these steps compute and display the Wald-Wolfowitz (or Runs) 


				        test statistic and its p-value. ;

	data waldwolf;
		label z='Wald-Wolfowitz Z' pvalue='Pr > |Z|';
		set runcount;
		mu=((2*n*m) / (n + m) ) + 1;
		sigmasq=((2*n*m) * (2*n*m-(n+m)) ) / (((n+m)**2) * (n+m-1) );
		sigma=sqrt(sigmasq);
		drop sigmasq;

		if N GE 50 then
			Z=(Runs - mu) / sigma;
		else if Runs-mu LT 0 then
			Z=(Runs-mu+0.5)/sigma;
		else
			Z=(Runs-mu-0.5)/sigma;
		pvalue=2*(1-probnorm(abs(Z)));
	run;

	title 'Wald-Wolfowitz Test for Randomness';
	title2 'H0: The data are random';

	proc print data=waldwolf label noobs;
		var z pvalue;
		format pvalue pvalue.;
	run;

%mend;