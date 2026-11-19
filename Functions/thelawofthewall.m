function [u_star, z_0, R_squared] = thelawofthewall(U_profile, depth, U_to_fit)
%{
U_profile = Cur(1, 1:12);
U_to_fit = 1:4;
%}
% kappa = 0.4;
depth = depth(:);
U_profile = U_profile(:);

z_fit = depth(U_to_fit); % Heights above bed for fitting

U_fit = U_profile(U_to_fit); % Corresponding velocities for fitting

% Also remove the potential outlier you had at ln(z) ~ 2.7 if it exists
% This is a more advanced step, for now we assume the time-averaging smoothed it out.

% Step 3: Prepare data for linear regression (y = mx + c)
x_data = log(z_fit); % x = ln(z). Transpose to make it a column vector.
y_data = U_fit;   % y = U(z). Transpose to make it a column vector.

% Step 4: Perform the linear regression using polyfit
% polyfit(x,y,1) fits a 1st degree polynomial (a line) to the data
p = polyfit(x_data, y_data, 1);
m = p(1); % The slope of the line
c = p(2); % The y-intercept of the line

% % To check the quality of the fit, calculate the R-squared value
y_fit = polyval(p, log(depth)); % Get the fitted y values
y_resid = U_profile(1:length(depth)) - y_fit; % Calculate the residuals
SS_resid = sum(y_resid.^2); % Sum of squared residuals
SS_total = (length(U_profile(:))-1) * var(U_profile(:)); % Total sum of squares
R_squared = 1 - SS_resid / SS_total;

kappa = 0.41; % von Karman constant
u_star = m * kappa;
z_0 = exp(-c / m);

end

%}



% z = depth(U_to_fit);
% U = U_profile(U_to_fit);
% 
% if length(z) < 2
%     error('Need at least 2 valid data points to fit velocity profile');
% end
% 
% % Linear regression: u = a * ln(z) + b
% % Create design matrix
% X = [log(z(:)), ones(length(z), 1)];
% y = U;
% 
% % Least squares solution
% coeffs = X \ y;
% a = coeffs(1);  % slope = u*/κ
% b = coeffs(2);  % intercept = -(u*/κ) * ln(z0)
% 
% % Extract parameters
% u_star = a * kappa;
% z_0 = exp(-b / a);
% 
% % Calculate R-squared for goodness of fit
% u_predicted = X * coeffs;
% SS_res = sum((y - u_predicted).^2);
% SS_tot = sum((y - mean(y)).^2);
% R_squared = 1 - SS_res / SS_tot;

% end
