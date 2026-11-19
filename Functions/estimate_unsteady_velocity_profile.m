function [u_star_mean, z0, u_star_timeseries, R_squared] = ...
    estimate_unsteady_velocity_profile(z_measured, u_measured, time)
    % Estimate friction velocity and roughness from unsteady velocity profiles
    %
    % INPUTS:
    %   z_measured : heights above bed [m] (vector or matrix)
    %   u_measured : velocities [m/s] (matrix: rows=time, cols=heights)
    %                OR (vector if single time snapshot)
    %   time       : time vector [s] (optional, for time series analysis)
    %
    % OUTPUTS:
    %   u_star_mean      : time-averaged friction velocity [m/s]
    %   z0               : estimated roughness length [m]
    %   u_star_timeseries: friction velocity at each time step [m/s]
    %   R_squared        : goodness of fit for each time step
    
    kappa = 0.4;  % von Karman constant
    
    % Determine if input is time series or single snapshot
    if nargin < 3
        % Single snapshot case
        time = 0;
        if isvector(u_measured)
            u_measured = u_measured(:)';  % Make row vector
        end
    end
    
    % Ensure z_measured is a column vector
    z_measured = z_measured(:);
    
    % Get dimensions
    [n_times, n_heights] = size(u_measured);
    
    % Initialize output arrays
    u_star_timeseries = zeros(n_times, 1);
    z0_timeseries = zeros(n_times, 1);
    R_squared = zeros(n_times, 1);
    
    % Process each time step
    for t = 1:n_times
        u_t = u_measured(t, :)';
        
        % Remove invalid data points
        valid_idx = ~isnan(z_measured) & ~isnan(u_t) & ...
                    (z_measured > 0) & (u_t > 0);
        z = z_measured(valid_idx);
        u = u_t(valid_idx);
        
        if length(z) < 2
            u_star_timeseries(t) = NaN;
            z0_timeseries(t) = NaN;
            R_squared(t) = NaN;
            continue;
        end
        
        % Linear regression: u = a * ln(z) + b
        X = [log(z), ones(length(z), 1)];
        y = u;
        coeffs = X \ y;
        
        a = coeffs(1);  % u*/kappa
        b = coeffs(2);  % -(u*/kappa) * ln(z0)
        
        % Extract parameters
        u_star_timeseries(t) = a * kappa;
        z0_timeseries(t) = exp(-b / a);
        
        % Calculate R-squared
        u_predicted = X * coeffs;
        SS_res = sum((y - u_predicted).^2);
        SS_tot = sum((y - mean(y)).^2);
        R_squared(t) = 1 - SS_res / SS_tot;
    end
    
    % Average z0 across all time steps (should be relatively constant)
    z0 = nanmean(z0_timeseries);
    
    % Mean friction velocity
    u_star_mean = nanmean(u_star_timeseries);
    
    % Display results
    fprintf('\n=== Tidally Accelerating BBL Analysis ===\n');
    fprintf('Based on Wu et al. (2011) - Pearl River Estuary\n\n');
    fprintf('Time-averaged friction velocity: %.6f m/s\n', u_star_mean);
    fprintf('Estimated roughness length:      %.6f m (%.3e m)\n', z0, z0);
    if n_times > 1
        fprintf('Friction velocity range:         %.6f - %.6f m/s\n', ...
                min(u_star_timeseries), max(u_star_timeseries));
        fprintf('Mean R-squared:                  %.6f\n', nanmean(R_squared));
    else
        fprintf('R-squared:                       %.6f\n', R_squared);
    end
    fprintf('Number of time steps:            %d\n', n_times);
    fprintf('Number of measurement heights:   %d\n\n', n_heights);
end
