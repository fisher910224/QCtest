function [yp,a]=harmonic(t,y,T)
%-------------------------------------------------
% fit of y(t) as a harmonic function of period T
% [yp,a]=harmonic(t,y,T)
% yp = a(1)+ a(2)*sin(2*pi*t/T)+ a(3)*cos(2*pi*t/T)
%--------------------------------------------------
nmax=length(t);
X = [ones(nmax,1), sin(2*pi*t/T(1)), cos(2*pi*t/T(1)),sin(2*pi*t/T(2)), cos(2*pi*t/T(2)),sin(2*pi*t/T(3)), cos(2*pi*t/T(3)),sin(2*pi*t/T(4)), cos(2*pi*t/T(4)),sin(2*pi*t/T(5)), cos(2*pi*t/T(5))];
a = X \ y;    
yp=X*a;
% SDATA.1

