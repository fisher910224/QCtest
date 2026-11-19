function xm=houravg(x,num,many)
% taking 60-min average of the time series of x
for c=1:fix(num/many)   
   m=(c-1)*many+1;
   xm(c)=mean(x(m:m+many-1));
   %xm(:,c)=(x(:,m)+x(:,m+1)+x(:,m+2)+x(:,m+3)+x(:,m+4)+x(:,m+5))/6.;   % 60 min-average
end
