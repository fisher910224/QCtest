function [flags] = Test6(input_item, threshold_low, threshold_high)
% ========================= SPIKE TEST =============================
% ============================================= WRITE BY DTY =======
% 
%       CHECK WHETHER THE DATA EXCEEDS A SELECTED THRESHOLD.
% 
% ==================================================================
% ---- INPUT -------------------------------------------------------
% 
% INPUT_ITEM:               DATA
% 
% THRESHOLD_LOW:            OPERATOR-SELECTED THRESHOLD e.g. 20...
% 
% THRESHOLD_HIGH:           OPERATOR-SELECTED THRESHOLD e.g. 40...
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
    input_item
    threshold_low double
    threshold_high double
end

if threshold_low >= threshold_high
    error('Test6 Error: threshold_low must be smaller than threshold_high.');
end

if threshold_low < 0 || threshold_high < 0
    error('Test6 Error: Thresholds must be non-negative.');
end

input_item = input_item(:);

flags = ones(size(input_item));

x_target = input_item(2:end-1);
x_prev   = input_item(1:end-2);
x_next   = input_item(3:end);

    
WS = x_target;
SPK_REF = (x_prev + x_next) / 2;

diff_val = abs(WS - SPK_REF);

mask_suspect = [false; diff_val > threshold_low; false];
mask_fail    = [false; diff_val > threshold_high; false];

flags(mask_suspect) = 3;
flags(mask_fail) = 4;

flags(isnan(input_item)) = 9;
end









