function [eigenFunction,eigenValues, e]=eoffang(data, Neff)
% compute the EOF
% given data, in colomn vector.
% row as temporal information, and column is for spatial information or
% different variables
% Data Must be in the same time duration
% for vector data like u and v, it can be like data=[u,v]; all in column
% vector.
% output: eigenfunction, and eigenvalue.
% eigenvalue has been normalized and can be regarded as variance explained
% error: error estimate based on North et al 1982. (Sampling Errors in the
% Estimation of Empirical Orthogonal Functions): e

%if nargin == 1;
%data=detrend(data);
data=detrend(data,'constant');


[eigenFunction,eigenValues]=eig(cov(data));
eigenValues=diag(eigenValues)/trace(eigenValues);
[eigenValues,evidx]=sort(eigenValues,'descend'); % sort the eigenvalue
eigenFunction=eigenFunction(:,evidx); % eigenmode
e95 = [];
%end;

% estimating error
if nargin > 1; 
    e = sqrt(2/Neff)*eigenValues;
end
    


