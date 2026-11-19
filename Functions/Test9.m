function [flags] = Test9(var1, var2, n_dev1, n_dev2, tim_dev)
% ===================== MULTI-VARIATE TEST =========================
% ============================================= WRITE BY DTY =======
% 
%        COMPARE TWO RELATED VARIABLES. IF VAR1 SHOWS A SPIKE BUT 
%        VAR2 DOES NOT, VAR1 IS FLAGGED AS SUSPECT.
%        BASED ON QARTOD TEST 9.
% 
% ==================================================================
% ---- INPUT -------------------------------------------------------
% 
% VAR1:           PRIMARY DATA (e.g., Wind Speed)
% 
% VAR2:           SECONDARY DATA (e.g., Barometric Pressure)
% 
% N_DEV1:         THRESHOLD MULTIPLIER FOR VAR1 (N_WSMV_DEV)
% 
% N_DEV2:         THRESHOLD MULTIPLIER FOR VAR2 (N_BP_DEV)
% 
% TIM_DEV:        WINDOW FOR CALCULATING SD (e.g., 24 samples)
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
    var1
    var2
    n_dev1  double = 2   % 變數1的變化率門檻 (通常設得比 Test 7 嚴格)
    n_dev2  double = 2   % 變數2的變化率門檻
    tim_dev double = 24  % 計算局部標準差的窗口
end

var1 = var1(:);
var2 = var2(:);
if length(var1) ~= length(var2)
    error('Test9 Error: The two input variables must have the same length.');
end

n = length(var1);
flags = ones(n, 1);

diff1 = abs([0; diff(var1)]); % 補一個0在前面以對齊長度
diff2 = abs([0; diff(var2)]);

sd1 = movstd(diff(var1), tim_dev, 'omitnan');
sd2 = movstd(diff(var2), tim_dev, 'omitnan');

sd1 = [sd1(1); sd1(:)]; 
sd2 = [sd2(1); sd2(:)];

is_suspect = (diff1 > n_dev1 * sd1) & (diff2 < n_dev2 * sd2);

flags(is_suspect) = 3;

flags(isnan(var1) | isnan(var2)) = 9;

end





