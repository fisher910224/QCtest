function [flags] = Test7(input_time, input_item, n_dev, tim_dev_hours, expected_interval)
% ===================== RATE OF CHANGE TEST ========================
% ============================================= WRITE BY DTY =======
% 
%       EXCESSIVE RIDE/FALL TEST
% 
% ==================================================================
% ---- INPUT -------------------------------------------------------
% 
% INPUT_ITEM:               DATA
% 
% N_DEV:                    OPERATOR-SELECTED THRESHOLD e.g. 20...
% 
% TIME_DEV:                 OPERATOR-SELECTED THRESHOLD e.g. 40...
%                           (MUST BE LARGER THAN THE LIMIT_RANGE)
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
    n_dev double = 3          % 手冊建議 3
    tim_dev_hours double = 24 % 手冊範例 8，你原始碼用 24
    expected_interval = hours(1)
end

if ~isdatetime(input_time)
    it = datetime(input_time(:), 'ConvertFrom', 'datenum');
else
    it = input_time(:);
end

input_item = input_item(:);
flags = ones(size(input_item));

dv = diff(input_item);
dt = diff(it);

% pts_in_window = round(hours(tim_dev_hours) / expected_interval);
if isduration(expected_interval)
    % 如果都是 duration，相除會得到 double
    pts_in_window = round(hours(tim_dev_hours) / hours(expected_interval));
else
    % 如果 expected_interval 已經是數字
    pts_in_window = round(tim_dev_hours / expected_interval);
end
moving_sd = movstd(dv, [pts_in_window-1, 0], 'omitnan');
time_is_valid = dt <= (expected_interval * 1.5);

abs_change = abs(dv);
threshold = n_dev * moving_sd;

is_suspect = (abs_change > threshold) & time_is_valid;
target_idx = 2:length(input_item);
flags(target_idx(is_suspect)) = 3;

flags(isnan(input_item)) = 9;


end



