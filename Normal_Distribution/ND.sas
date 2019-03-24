*Acest program genereaza o distributie normala standard (medie 0 si varianta 1);
options ls=78;
title "Distributia Normala Standard";

%let pi=3.1416;
data date;
  do x=-5 to 5 by 0.1;
      phi=exp(-(x*x/2))/sqrt(2*&pi);
      output;
  end;
run;

proc sgplot data=date;
series x=x y=phi/lineattrs=(thickness=3 color=red);
run;
