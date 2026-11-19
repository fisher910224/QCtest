function [wind_along_main_axis, wind_perpendicular] = wind_rotated(WU, WV, theta)

% 原始風場矩陣：每列為一個時間點，每行為一個方向分量
wind = [WU(:), WV(:)];

% 主軸角度（單位：度）
% theta = theta1;
% theta_rad = deg2rad(theta);

% 建立旋轉矩陣
R = [cosd(theta), sind(theta);
    -sind(theta), cosd(theta)];

% 對風場進行旋轉
wind_rotated = wind * R';

% 拆開主軸與垂直分量
wind_along_main_axis = wind_rotated(:, 1);  % 沿主軸方向的風
wind_perpendicular   = wind_rotated(:, 2);  % 垂直主軸方向的風



end

