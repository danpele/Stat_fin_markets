* ---------------------------------------------------------------------
* Quantlet:     variance_ratio_test
* ---------------------------------------------------------------------
* Description:  variance_ratio_test performs the Lo-MacKinley Variance Ratio test, 
				to the test the random walk behaviour of the stock market prices.
				The test is performed under the two variants: assuming homoskedasticity
				and heteroskedasticity of logreturns.
* ---------------------------------------------------------------------
* Usage:        SAS 9.2, SAS 9.3, SAS 9.4, SAS University Edition
* ---------------------------------------------------------------------
* See also:     LO, Andrew W., MACKINLAY, A. Craig (1988), 
				“Stock Market Prices do not Follow Random Walks: 
				Evidence from a Simple Specification Test”, 
				The Review of Financial Studies, Vol. 1, No. 1. 
				(Spring, 1988), pp. 41-66.
*----------------------------------------------------------------------
* Keywords:     Variance Ratio test
*----------------------------------------------------------------------
* Inputs:       - data- the input dataset
				- price - the variable containing the closing prices
				- q - the maximum number of sub-periods to perform the test (usually q=32)
				- alpha - the significance level (usually 0.05)
				- time - the variable containing the dates
* ---------------------------------------------------------------------
* Output:       The test statistics, decision and the graph of VR(q)
* ---------------------------------------------------------------------
* Usage:         use %include "path\variance_ratio_test.sas"  	
				 invoke the macro like this: %Variance_Ratio(data=, price=, q=, alpha=, time=) 
-----------------------------------------------------------------------
* Author:       Daniel Traian Pele    


	* ---------------------------------------------------------------------;

%macro Variance_Ratio(data=, price=, q=, alpha=, time=);
	%let confidence=%sysevalf((1-&alpha)*100);

	data date_VR;
		set &data;
		logprice=log(&price);
		logreturn=logprice-lag(logprice);
	run;

	proc sgplot data=date_VR;
		series x=&time y=logprice;
		title ' Logprice';
		label logprice='logprice';
		label &time='time';
	run;

	quit;

	proc sgplot data=date_VR;
		series x=&time y=logreturn;
		title ' Time series of logreturns';
		label logreturn='logreturn';
		label &time='time';
	run;

	title;

	data date_VR;
		set date_VR;

		%do i=2 %to &q ;
			%let j=&i;
			logreturn&j=logprice-lag&j(logprice);
			*one period log return;
		%end;
	run;

	proc means data=date_VR noprint;
		var logreturn;
		output out=muhat mean=muhat n=nq;

		%do l=2 %to &q;

		data date&l;
			if _n_=1 then
				set muhat;
			set date_VR;
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

		data varrat&l;
			set varrat&l;
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

		data data varrat&l;
			set varrat&l;
			length Decision $ 50;
			lower_homo=vr-z_critic*((2*(2*q-1)*(q-1)/(3*q))**(1/2))/sqrt(nq);
			upper_homo=vr+z_critic*((2*(2*q-1)*(q-1)/(3*q))**(1/2))/sqrt(nq);
			lower_hetero=vr-z_critic*sqrt(theta)/sqrt(nq);
			upper_hetero=vr+z_critic*sqrt(theta)/sqrt(nq);

			if ((z>z_critic) or (z<-z_critic)) and not
((z_star>z_critic) or (z_star<-z_critic)) then
				Decision="Reject Homoskedastic RW ";
			else if not ((z>z_critic) or (z<-z_critic)) and((z_star>z_critic) 
				or (z_star<-z_critic)) then
					Decision="Reject Heteroskedastic RW";
			else if ((z>z_critic) or (z<-z_critic)) and 
((z_star>z_critic) or (z_star<-z_critic)) then
				Decision="Reject Homoskedastic and Heteroskedastic RW";
			else if Decision=. then
				Decision="Cannot Reject RW";
			keep nq q VR lower_homo upper_homo lower_hetero upper_hetero z z_star 
				z_critic Decision;
			label nq='Number of observations' VR='VR' 
				lower_homo='Confidence interval '&confidence'%' 
				lower_hetero='Confidence interval '&confidence'%' z='Homoskedastic z' 
				z_star='Heteroskedastic z*' Decision='Decision';
			*proc print data= varrat&l label noobs;
		run;

	%end;

	data varrat;
		set varrat2;
	run;

	%do p=3 %to &q;

		proc append base=varrat data=varrat&p force;
		run;

	%end;

	proc print data=varrat (obs=&q);
	run;
	
	data varrat;set varrat;
	reference=1;
	run;
	
	proc sgplot data=varrat;
		series x=q y=VR/lineattrs=(color=red pattern=dash) name='Variance Ratio';
		series x=q y=lower_homo/lineattrs=(color=blue pattern=dash) 
			name='Confidence interval';
		series x=q y=upper_homo /lineattrs=(color=blue pattern=dash);
		series x=q y=reference/lineattrs=(color=green ) name='VR under RWH';
		title ' Variance Ratio under Homoskedasticity';
		label VR='Variance Ratio';
		label reference='VR under RWH' ;
		label q='q';
		keylegend "Confidence interval" "Variance Ratio"  "VR under RWH";

	proc sgplot data=varrat;
		series x=q y=VR/lineattrs=(color=red pattern=dash) name='Variance Ratio';
		series x=q y=lower_hetero/lineattrs=(color=blue pattern=dash) 
			name='Confidence interval';
		series x=q y=upper_hetero/lineattrs=(color=blue pattern=dash);
		series x=q y=reference/lineattrs=(color=green ) name='VR under RWH';
		title ' Variance Ratio under Heteroskedasticity';
		label VR='Variance Ratio';
		label q='q';
		label reference='VR under RWH';
		keylegend "Confidence interval" "Variance Ratio"  "VR under RWH";
	run;

	quit;
%mend;
