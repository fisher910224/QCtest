function [flags] = Test11(var_main, var_neighbor, n_dev_main, n_dev_neighbor, tim_dev)
% ======================== NEIGHBOR TEST ===========================
% ============================================= WRITE BY DTY =======
% 
%   COMPARE DATA FROM THE TARGET SENSOR TO A NEARBY SECOND SENSOR.
%   IF THE TARGET SHOWS A SPIKE BUT THE NEIGHBOR DOES NOT, 
%   THE TARGET IS FLAGGED AS SUSPECT.
%   BASED ON QARTOD TEST 11.
% 
% ==================================================================
% ---- INPUT -------------------------------------------------------
% 
% VAR_MAIN:         TARGET SENSOR DATA (WS1)
% VAR_NEIGHBOR:     NEARBY SENSOR DATA (WS2)
% N_DEV_MAIN:       THRESHOLD MULTIPLIER FOR TARGET (N_WS1_DEV)
% N_DEV_NEIGHBOR:   THRESHOLD MULTIPLIER FOR NEIGHBOR (N_WS2_DEV)
% TIM_DEV:          WINDOW FOR SD CALCULATION (e.g., 24 samples)
% 
% ---- OUTPUT ------------------------------------------------------
% 
% FLAGS:            QC FLAGS (1:PASS, 3:SUSPECT, 4:FAIL(N/A), 9:MISSING)
% 
% ==================================================================
arguments
    var_main
    var_neighbor
    n_dev_main     double = 2   % 測站1的變化率門檻
    n_dev_neighbor double = 2   % 測站2的變化率門檻
    tim_dev        double = 24  % 計算局部標準差的窗口筆數
end

% 1. 基本處理
var_main = var_main(:);
var_neighbor = var_neighbor(:);
if length(var_main) ~= length(var_neighbor)
    error('Test11 Error: 兩個測站的資料長度必須相同且時間對齊。');
end

n = length(var_main);
flags = ones(n, 1);

% 2. 計算變化量 (一階差分)
% 補一個 0 在前面，讓長度維持 n，並對齊原資料點
diff1 = abs([0; diff(var_main)]);
diff2 = abs([0; diff(var_neighbor)]);

% 3. 計算變化量的移動標準差 (反應環境背景波動)
% 注意：這裡計算的是「變化量」的標準差
sd1 = movstd(diff1, tim_dev, 'omitnan');
sd2 = movstd(diff2, tim_dev, 'omitnan');

% 4. 判定邏輯 (Codable Instructions)
% 條件：(測站1跳動太大) AND (鄰近測站跳動很小)
% 代表測站1的跳動缺乏空間相關性的支持
is_suspect = (diff1 > n_dev_main * sd1) & (diff2 < n_dev_neighbor * sd2);

% 5. 標記與缺失處理
flags(is_suspect) = 3;
flags(isnan(var_main) | isnan(var_neighbor)) = 9;

end