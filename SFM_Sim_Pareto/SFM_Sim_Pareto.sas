%macro sim_pareto(alpha=, n=);
	proc iml;
		y=j(&n, 1, 0);

		do i=1 to &n;
			call randgen(x, 'PARETO', &alpha);
			y[i]=x;
		end;
		create y from y;
		append from y;
		quit;

	data y;
		set y;
		rename col1=x;

	proc sort data=y;
		by x;

	data y;
		set y;
		pdf=PDF('Pareto', x, &alpha);
	run;

%mend;
%let alpha=3;
%sim_pareto(alpha=&alpha, n=100);

title "Probability density function of X, where X~Pareto (&alpha)";

proc sgplot data=y;
	series x=x y=pdf/lineattrs=(color=blue THICKNESS=2);
run;