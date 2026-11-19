function [hs,Tp,Tm02,Tm01]=cpfs(x,y)
% Purpose:
% Calculating the parameters of frequency spectrum
% Parameters :
%   x    : Frequencies axis of frequency spectrum
%   y   : Scale  Sectrum density of frequency spectrum
%   hs   : Scale  Significant wave height
%   Tp   : Scale  wave period of peak period
%   Tm02 : Scale  Mean period of 2nd moment.
%   Tm01 : Scale  Mean period of 1st moment.
f=x(:).';
sp=y(:).';
% f = x;
% sp = y;
m0 = abs(trapz(f,sp));
m1 = abs(trapz(f,f.*sp));
m2 = abs(trapz(f,f.^2.*sp));
% m0 = nansum(sp)*diff(f(1:2));
% m1 = nansum(f.*sp)*diff(f(1:2));
% m2 = nansum((f.^2).*sp)*diff(f(1:2));
hs = 4*sqrt(m0);
[~,ind]=max(sp);
fp=f(ind);
Tp=1/fp;
Tm02=sqrt(m0/m2);
Tm01=m0/m1;
% disp(m0)
end