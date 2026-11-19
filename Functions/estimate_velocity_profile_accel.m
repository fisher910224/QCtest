function [u_star, z0, R_squared] = estimate_velocity_profile_accel(z_measured, u_t, u_prev, u_next, dt)
    % 基於 Soulsby & Dyer (1981) 的加速度修正流速剖面分析
    %
    % INPUTS:
    %   z_measured : 測站高度向量 [m]
    %   u_t        : 當前時間點的流速向量 [m/s]
    %   u_prev     : 前一時間點的流速向量 [m/s] (計算加速度用)
    %   u_next     : 後一時間點的流速向量 [m/s] (計算加速度用)
    %   dt         : 時間間隔 [s]
    z_measured = z_measured(:);
    u_t = u_t(:);
    u_prev = u_prev(:);
    u_next = u_next(:);
    
    kappa = 0.4;
    max_iter = 10; % 疊代次數，因為 u* 在修正項的分母
    tol = 1e-5;    % 收斂門檻
    
    % 1. 計算加速度 dudt (使用中央差分)
    % 我們取平均流速的加速度作為代表
    u_mean_t = mean(u_t);
    u_mean_prev = mean(u_prev);
    u_mean_next = mean(u_next);
    dudt = (u_mean_next - u_mean_prev) / (2 * dt);
    
    % 2. 數據預處理
    valid_idx = ~isnan(z_measured) & ~isnan(u_t) & (z_measured > 0);
    z = z_measured(valid_idx);
    u = u_t(valid_idx);
    
    % 3. 疊代求解 (Iterative Solution)
    % 因為修正項包含 u*，我們需要先用標準對數律得到初始值，再修正
    
    % 初始估計 (不考慮加速度)
    X = [log(z(:)), ones(length(z), 1)];
    coeffs = X \ u(:);
    u_star = coeffs(1) * kappa;
    
    for i = 1:max_iter
        u_star_old = u_star;
        
        % 計算修正項: (z / (kappa * u_star)) * dudt
        % 根據 Soulsby (1981) Eq. 17 變形
        u_correction = (z ./ (kappa * u_star)) .* dudt;
        
        % 修正原始流速：將觀測流速減去加速度影響項，使其回歸對數律
        u_corrected = u(:) - u_correction(:);
        
        % 重新進行線性回歸
        coeffs = X \ u_corrected;
        u_star = coeffs(1) * kappa;
        z0 = exp(-coeffs(2) / coeffs(1));
        
        % 檢查是否收斂
        if abs(u_star - u_star_old) < tol
            break;
        end
    end
    
    % 4. 計算 R-squared (針對修正後的剖面)
    u_predicted = X * coeffs + (z ./ (kappa * u_star)) .* dudt;
    SS_res = sum((u - u_predicted).^2);
    SS_tot = sum((u - mean(u)).^2);
    R_squared = 1 - SS_res / SS_tot;

    % 輸出結果
    fprintf('\n--- Soulsby & Dyer (1981) 加速度修正分析 ---\n');
    fprintf('加速度 (du/dt):    %.6e m/s^2\n', dudt);
    fprintf('修正後 u*:        %.6f m/s\n', u_star);
    fprintf('修正後 z0:        %.6f m\n', z0);
    fprintf('擬合度 R^2:       %.6f\n', R_squared);
    if i == max_iter, fprintf('警告：疊代未完全收斂\n'); end
end
