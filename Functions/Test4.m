function [flags] = Test4(input_item, sensor_range, user_range)
% ====================== GROSS RANGE TEST ==========================
% ============================================= WRITE BY DTY =======
% 
%       CHECK WHETHER THE DATA EXCEEDS THE LIMITS OF THE 
%       INSTRUMENT OR THE PHYSICAL PHENOMENON.
% 
% ==================================================================
% ---- INPUT -------------------------------------------------------
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
        input_item
        sensor_range (1, 2) double
        user_range (1, 2) double = sensor_range
end

if user_range(1) < sensor_range(1) || user_range(2) > sensor_range(2)
    Error('Test4 Error: user_range needs to be in range of sensor_range.');
end

input_item = input_item(:);

flags = ones(size(input_item));

idx_suspect = (input_item < user_range(1)) | (input_item > user_range(2));
flags(idx_suspect) = 3;
idx_fail = (input_item < sensor_range(1)) | (input_item > sensor_range(2));
flags(idx_fail) = 4;

flags(isnan(input_item)) = 9; 


end




