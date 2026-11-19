% Implementation of Soulsby and Dyer (1981) Equation 2
% "The form of the near-bed velocity profile in a tidally accelerating flow"
% Journal of Geophysical Research, vol. 86, pp. 8067-8074
%
% Logarithmic velocity profile: u(z) = (u_star / kappa) * ln(z / z0)
%
% This version ESTIMATES u_star and z0 from measured velocity data

function [u_star, z0, R_squared] = estimate_velocity_profile(z_measured, u_measured)
    % Estimate friction velocity and roughness length from velocity profile data
    %
    % INPUTS:
    %   z_measured : heights above bed where velocity was measured [m]
    %   u_measured : measured velocities at each height [m/s]
    %
    % OUTPUTS:
    %   u_star     : estimated friction velocity [m/s]
    %   z0         : estimated roughness length [m]
    %   R_squared  : coefficient of determination (goodness of fit)
    %
    % METHOD:
    %   Rearranging u = (u*/κ) * ln(z/z0) gives:
    %   u = (u*/κ) * ln(z) - (u*/κ) * ln(z0)
    %   This is linear: u = a * ln(z) + b
    %   where: a = u*/κ  and  b = -(u*/κ) * ln(z0)
    %   Therefore: u* = a * κ  and  z0 = exp(-b/a)
    
    % von Karman constant
    kappa = 0.4;
    
    % Remove any NaN or invalid data points
    valid_idx = ~isnan(z_measured) & ~isnan(u_measured) & (z_measured > 0) & (u_measured > 0);
    z = z_measured(valid_idx);
    u = u_measured(valid_idx);
    
    if length(z) < 2
        error('Need at least 2 valid data points to fit velocity profile');
    end
    
    % Linear regression: u = a * ln(z) + b
    % Create design matrix
    X = [log(z(:)), ones(length(z), 1)];
    y = u(:);
    
    % Least squares solution
    coeffs = X \ y;
    a = coeffs(1);  % slope = u*/κ
    b = coeffs(2);  % intercept = -(u*/κ) * ln(z0)
    
    % Extract parameters
    u_star = a * kappa;
    z0 = exp(-b / a);
    
    % Calculate R-squared for goodness of fit
    u_predicted = X * coeffs;
    SS_res = sum((y - u_predicted).^2);
    SS_tot = sum((y - mean(y)).^2);
    R_squared = 1 - SS_res / SS_tot;
    
    % Display results
    fprintf('\n=== Soulsby & Dyer (1981) Equation 2 - Parameter Estimation ===\n');
    fprintf('Estimated friction velocity (u*): %.6f m/s\n', u_star);
    fprintf('Estimated roughness length (z0):  %.6f m (%.3e m)\n', z0, z0);
    fprintf('R-squared (goodness of fit):      %.6f\n', R_squared);
    fprintf('Number of data points used:       %d\n\n', length(z));
end
