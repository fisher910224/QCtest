function [flags] = Test5(input_time, input_item, sensor_range, user_range)
% ================== MONTHLY GROSS RANGE TEST ======================
% ============================================= WRITE BY DTY =======
% 
%       CHECK WHETHER THE DATA EXCEEDS THE LIMITS OF THE 
%       INSTRUMENT OR THE PHYSICAL PHENOMENON.
% 
% ==================================================================
% ---- INPUT -------------------------------------------------------
% 
% INPUT_TIME:               DATA'S TIME SERIES (DATETIME or DATENUM)
% 
% INPUT_ITEM:               DATA
% 
% SENSOR_RANGE:             THE SENSOR LIMITING RANGE e.g.[0 5]...
% 
% USER_RANGE:               THE USER-SETTING RANGE e.g.[0.1 4.5]...
%                           (MUST BE IN THE LIMIT_RANGE)
% 
% ---- OUTPUT ------------------------------------------------------
% 
% FLAGS:                    THE "PASS" AND "FAIL" DATA
%                               1: PASS
%                               3: SUSPECT(OUT OF USER_RANGE)
%                               4: FAIL(OUT OF SENSOR RANGE)
%                               9: MISSING
% 
% ==================================================================
arguments
        input_time
        input_item
        sensor_range (12, 2) double
        user_range (12, 2) double
end

if any(user_range(:, 1) < sensor_range(:, 1)) || any(user_range(:, 2) > sensor_range(:, 2))
    error("Test5 Error: At least one month's user_range is out of sensor_range.");
end

if ~isdatetime(input_time)
    it = datetime(input_time(:), 'ConvertFrom', 'datenum');
else
    it = input_time(:);
end

mm = month(it);
input_item = input_item(:);

flags = ones(size(input_item));


for m = 1:12
    % 找出屬於該月份的資料索引
    idx_m = (mm == m);
    
    if ~any(idx_m), continue; end % 如果這個月沒資料，跳過
    
    % 取得該月份對應的閾值
    s_min = sensor_range(m, 1);
    s_max = sensor_range(m, 2);
    u_min = user_range(m, 1);
    u_max = user_range(m, 2);
    
    % 該月份的數值
    current_vals = input_item(idx_m);
    current_flags = ones(size(current_vals));
    
    % 先判斷 Suspect (3)
    current_flags(current_vals < u_min | current_vals > u_max) = 3;
    
    % 再判斷 Fail (4)
    current_flags(current_vals < s_min | current_vals > s_max) = 4;
    
    % 放回總 Flag 矩陣中
    flags(idx_m) = current_flags;
end


flags(isnan(input_item)) = 9; 


end




