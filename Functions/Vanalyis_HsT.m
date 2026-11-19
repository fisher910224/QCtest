function percentbot = Vanalyis_HsT(Hs, T, height_range, period_range, opts)
arguments
    Hs
    T
    height_range
    period_range
    opts.SavingPath string = {};
end
% Hs: 波高向量 (m)
% T:  週期向量 (sec)
% height_range: 波高區間邊界，例如 0:0.2:3.0
% period_range: 週期區間邊界，例如 0:2:20

% 1. 基本參數設定
n_T = length(period_range);  % 週期區間數 (對應圖中的列數)
n_H = length(height_range);  % 波高區間數 (對應圖中的欄數)

% 初始化矩陣 (週期+合計 x 波高+合計)
percentbot = zeros(n_T + 1, n_H + 1); 

% 2. 篩選有效數據 (排除 Hs 或 T 其中之一為 NaN 的資料)
valid_idx = ~isnan(Hs) & ~isnan(T);
total_count = sum(valid_idx);
Hs = Hs(valid_idx);
T = T(valid_idx);

if total_count == 0
    error('沒有有效的數據可供統計。');
end

% 3. 統計核心邏輯
for ii = 1:n_T
    for jj = 1:n_H
        % --- 週期條件 (ii) ---
        if ii < n_T
            mask_T = (T >= period_range(ii) & T < period_range(ii+1));
        else
            % 最後一個週期區間 (例如 18s 以上)
            mask_T = (T >= period_range(ii));
        end
        
        % --- 波高條件 (jj) ---
        if jj < n_H
            mask_H = (Hs >= height_range(jj) & Hs < height_range(jj+1));
        else
            % 最後一個波高區間 (例如 3.0m 以上)
            mask_H = (Hs >= height_range(jj));
        end
        
        % 交集統計
        percentbot(ii, jj) = sum(mask_T & mask_H);
    end
end

% 4. 轉換為百分比 (%)
percentbot = (percentbot / total_count) * 100;

% 5. 計算合計 (Marginal Totals)
% 每行的合計 (右側：各週期區間的總和)
for i = 1:n_T
    percentbot(i, n_H + 1) = sum(percentbot(i, 1:n_H));
end

% 每列的合計 (下方：各波高區間的總和)
for j = 1:n_H + 1
    percentbot(n_T + 1, j) = sum(percentbot(1:n_T, j));
end

% 6. 輸出檔案處理
if ~isempty(opts.SavingPath)
if ~exist(filepath, 'dir')
    [status, msg] = mkdir(filepath);
    if ~status
        error('無法建立資料夾，錯誤訊息：%s', msg);
    end
end

% full_path = fullfile(filepath, filename);
full_path = string(opts.SavingPath);

% 嘗試開啟檔案
[fid, errmsg] = fopen(full_path, 'w');

if fid == -1
    % 如果開啟失敗，顯示具體原因
    error('無法開啟檔案！路徑：%s\n原因：%s\n(請檢查該檔案是否已被其他程式開啟，或路徑權限是否正確)', full_path, errmsg);
end

fprintf(fid, 'Joint Probability Distribution (Hs vs T) - %s\n', filename);

% 動態生成格式字串 (根據波高區間數 + 1個合計欄)
fmt = [repmat('%8.2f ', 1, n_H + 1), '\n'];

for n = 1:n_T + 1
    % 如果你想在每一行前面加上週期的標籤，可以在這裡處理
    % 例如：fprintf(fid, 'T_Range_%02d ', n);
    fprintf(fid, fmt, percentbot(n, :));
end

% 7. 其他統計資訊
meanHs = mean(Hs, 'omitmissing');
meanT  = mean(T, 'omitmissing');
[maxHs, idx] = max(Hs);
T_at_maxHs = T(idx);

fprintf(fid, '\nTotal mean of Hs = %8.2f m\n', meanHs);
fprintf(fid, 'Total mean of Period (T) = %8.2f s\n', meanT);
fprintf(fid, 'Maximum Hs = %8.2f m, Corresponding T = %8.2f s\n', maxHs, T_at_maxHs);
fclose(fid);

fprintf('Hs vs T 統計表已存至: %s\n', full_path);
end
end