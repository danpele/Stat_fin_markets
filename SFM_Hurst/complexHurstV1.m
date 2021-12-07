% Following program is used to calculate Complex Hurst, Version 1.0
% Contributed to Matlab File Exchange Server, Jun Steed Huang on 2/23/2015
% According to http://icimsa.org/ paper id111802 by Qing/Yufan/Jun
% Jun Steed Huang email: steedhuang@163.com     
% Qing Zou email: roronoaz@163.com
% Yufan Hu email: yufanhu0918@163.com
% For more background about the Statistic Theory, check out:
% http://en.wikipedia.org/wiki/Benoit_Mandelbrot
% Calculate the Nasdaq Stock market Complex Hurst with minimum 700 inputs
% Clear the work space
  clear
% Input NASDAQ stock per day value, say eBay or any company you wanted
  ab=xlsread('EBAY.xls');
% Pick the interested column for this complex analysis
  a=ab(:,1);     % this is column for day, we don't use it here
  b=ab(:,2);     % this is stock value in US$, can change to other column
% Calculate the original length of data
  num_data=size(b);    % this is the number of days counted
% Calculate the Index of Dispersion for Count
  d=b; 
% F is the Fractional dimension F=1.5/2.0/2.5
% F=1.5 is the Fractional moment between Mean and Variance
% F=2.0 is the Normal Variance
% F=2.5 is the Fractional moment between Variance and Skewness
  figure(1)
for k=1:3
    F=1+k*0.5 
% The level of grouping, minimum data points is 700
    L=[1, 2, 5, 10, 20, 65, 130, 260];
% 1 is for 1 day, 2 is for 2 days, 5 is for a week, 10 is for biweekly,
% 20 is for monthly, 65 is for quarterly, 130 is half year, 260 is a year.
    m=length(L);   % number of dots on IDC curve
% Calculate each point of the graph one by one
  for r=1:m
      clear sum V E  num_batch  Y
      num_batch=fix(num_data/ L(r));
        % Add varaible within the group
        for i=1:num_batch
            Y(i)=0;
             for j=1:L(r)
                 Y(i)=Y(i)+ d((i-1)*L(r)+j);
             end
        end
        % Calculate the standard variance and normalize it
        n=length(Y);
        E=sum(Y)/n;
        sum=0;
        for j=1:n
            % This is where Complex Number started
             sum = sum + (Y(j)-E)^F;
        end
        % Normalize the Complex Number 
        V = sum/(n-1);
        % IDC of Complex Number
        I(r) = V/E;
  end 
  % Plot value part, ignore the sign
%  figure(1)
  loglog(L,abs(real(I)), '-ws','LineWidth',2,'MarkerSize',7,'MarkerFaceColor',[k/5,0.5,0.271]); 
  % to add on next imag curve
  hold on;
  if k~=2 % skip the normal variance
  loglog(L,abs(imag(I)), '-ws','LineWidth',2,'MarkerSize',7,'MarkerFaceColor',[0.3+k/5,0.5,0.618]);
  end
  % Use the last and first point to calculate the Complex Hurst
  slope=(log(I(m))-log(I(1)))/(log(L(m))-log(L(1)));
  Hurst=(1+slope)/2    % this is the number we looking for!
end
% Sync the title with the F value, legend
legend('F=1.5 Real','F=1.5 Imag','F=2.0','F=2.5 Real','F=2.5 Imag');
  title('IDC Plot for Complex Hurst');
  xlabel('From Day to Year');
  ylabel('Index of Dispersion for Count');
hold off;
% Note that Hurst may be >1, due to the ignoring of sign, for simplicity. 
% 3D calculation can be used if you insist to see traditional Hurst.

  
  