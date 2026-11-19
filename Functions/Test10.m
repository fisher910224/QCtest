function [flags] = Test10(input_time, input_item, test_duration, min_var_warn, min_var_fail, sampling_rate)
% ======================= FLAT LINE TEST ===========================
% ============================================= WRITE BY DTY =======
% 
%       A TEST FOR INADEQUATE VARIATION OF THE TIME SERIES.
%       BASED ON QARTOD TEST 10.
% 
% ==================================================================
% ---- INPUT -------------------------------------------------------
% 
% INPUT_ITEM:               DATA VECTOR
% 
% N_TST:                    NUMBER OF SAMPLES IN THE WINDOW (TST_TIM)
% 
% MIN_VAR_WARN:             MINIMUM SD THRESHOLD FOR SUSPECT (Flag 3)
% 
% MIN_VAR_FAIL:             MINIMUM SD THRESHOLD FOR FAIL (Flag 4)
%                           (MUST BE SMALLER THAN MIN_VAR_WARN)
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
    test_duration = hours(24) % QARTOD 常用視窗長度
    min_var_warn double = 0.01
    min_var_fail double = 0.005
    sampling_rate = hours(1)
end

input_item = input_item(:);

if min_var_warn <= min_var_fail
    error('Test10 Error: min_var_warn must be larger than min_var_fail.');
end

flags = ones(size(input_item));
flags(isnan(input_item)) = 9;
n = length(input_item);

% 1. 將時間長度轉換為點數
n_tst = round(test_duration / sampling_rate);

if n < n_tst
    return; % 資料太短，無法執行此測試
end

% 2. 計算移動標準差
% 使用 'omitnan'，但我們稍後會檢查有效點數
SD_vec = movstd(input_item, [n_tst-1, 0], 'omitnan');

% 3. 額外檢查：計算視窗內有效資料 (非 NaN) 的數量
valid_count = movsum(~isnan(input_item), [n_tst-1, 0]);

% 4. 判定邏輯
% 只有當視窗內有效資料超過 75% 時才進行判定，否則維持 1 (Pass)
% 這能防止因為斷訊導致 SD 異常變小而產生的誤判
evaluation_mask = (valid_count >= n_tst * 0.75);

idx_fail    = (SD_vec < min_var_fail) & evaluation_mask;
idx_suspect = (SD_vec < min_var_warn) & evaluation_mask;

% 確保從第 n_tst 個點開始標記 (前面點數不足的視窗不具代表性)
idx_fail(1:n_tst-1) = false;
idx_suspect(1:n_tst-1) = false;

flags(idx_suspect) = 3;
flags(idx_fail) = 4;

% 最後補回原始 NaN 的標記
flags(isnan(input_item)) = 9;


% SD_vec = movstd(input_item, [n_tst-1, 0], 'omitnan');
% eval_idx = n_tst:n;
% current_SD = SD_vec(eval_idx);
% 
% mask_suspect = current_SD < min_var_warn;
% mask_fail    = current_SD < min_var_fail;
% 
% flags(eval_idx(mask_suspect)) = 3;
% flags(eval_idx(mask_fail)) = 4; % 更嚴重的會覆蓋掉 3

end
