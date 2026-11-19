function [flags] = Test1(input_time, samplingrate, tol_suspect, tol_fail)
% ======================== TIME GAP TEST ===========================
% ============================================= WRITE BY DTY =======
% 
%       TESTING IF THE GAP OF INPUT TIME SERIES HAS FAULT
% 
% ==================================================================
% ---- INPUT -------------------------------------------------------
% 
% INPUT_TIME:               DATA'S TIME SERIES (DATETIME or DATENUM)
% 
% SAMPLINGRATE:             DATA'S SAMPLING RATE (HR)
% 
% TOL_SUSPECT:              (OPTIONAL)DEFAULT = 1 MINUTES
% 
% TOL_FAIL:                 (OPTIONAL)DEFAULT = 0.5 * SAMPLINGRATE
% 
% ---- OUTPUT ------------------------------------------------------
% 
% FLAGS:                    THE "PASS" AND "FAIL" DATA
%                               1: PASS
%                               3: SUSPECT
%                                   (e.g. [01:00, 02:00, 03:01], 
%                                   THEN FLAG WOULD BE: 
%                                   [1, 1, 3])
%                               9: FAIL (MARK ON THE NEXT DATA, 
%                                   e.g. [01:00, 02:00, 04:00] LACK
%                                   03:00, THEN FLAG WOULD BE: 
%                                   [1, 1, 4])
% 
% ==================================================================

arguments
        input_time
        samplingrate
        tol_suspect = minutes(1) 
        tol_fail    = hours(samplingrate) * 0.5
end


if isnumeric(input_time)
    it = datetime(input_time(:), 'ConvertFrom', 'datenum');
elseif isdatetime(input_time)
    it = input_time;
end

if isnumeric(tol_suspect)
    tol_suspect = hours(tol_suspect);
end

if isnumeric(tol_fail)
    tol_fail = hours(tol_fail);
end

if tol_suspect >= tol_fail
    error('Test1 Error: tol_suspect (%s) cannot equal or larger than tol_fail (%s).', ...
          char(tol_suspect), char(tol_fail));
end


time_gap = diff(it);

sr = hours(samplingrate);

flags = ones(size(it));

deviation = abs(time_gap - sr);

flags([false; deviation > tol_suspect]) = 3;
flags([false; deviation > tol_fail]) = 9;
flags([false; time_gap == seconds(0)]) = 4;

end





