function polarPcolor(theta, r, Z)
    % Ensure Z dimensions are compatible with theta and r
    if size(Z, 1) ~= length(r) || size(Z, 2) ~= length(theta)
        error('Matrix dimensions of Z must match the lengths of r and theta.');
    end
    
    % Convert polar to Cartesian coordinates
    [TH, R] = meshgrid(theta, r);
    X = R .* cos(TH);
    Y = R .* sin(TH);
    
    % Shift Z matrix to avoid pcolor's edge-cropping issue
    Z_shifted = Z(1:end-1, 1:end-1);
    
    % Plot using 'pcolor' in Cartesian coordinates
    pcolor(X, Y, Z_shifted);  
    shading interp;    % Smooth shading
    axis equal tight;  % Ensure circular aspect ratio
end