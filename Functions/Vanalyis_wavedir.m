function Vanalyis_Hsdir(Hs, dir, height_range, filepath, filename)
% Hs: 波高向量, dir: 波向向量 (0-360)
% height_range: 波高區間邊界，例如 0:0.2:3.0

% 1. 方向處理 (將 348.75-360 映射到負數區間，方便與 0-11.25 合併為北向)
gg = find(dir >= 348.75 & dir <= 360);
dir(gg) = dir(gg) - 360;

% 定義方向中心點與邊界 (16個方位)
% ang 邊界為: -11.25, 11.25, 33.75 ... 348.75
ang = -11.25:22.5:348.75; 
n_dir = length(ang) - 1; % 應為 16
n_height = length(height_range); % 假設輸入 0:0.2:3.0，長度為 16

% 初始化矩陣 (行: 方向+合計, 列: 波高區間+合計)
% 區間數 = n_height (包含最後一個 "3.0~")
percentbot = zeros(n_dir + 1, n_height + 1); 

% 2. 統計核心邏輯
valid_idx = ~isnan(Hs) & ~isnan(dir);
total_count = sum(valid_idx);

for ii = 1:n_dir
    for jj = 1:n_height
        if jj < n_height
            % 一般區間 [h1, h2)
            mask = (Hs > height_range(jj) & Hs <= height_range(jj+1) & ...
                    dir >= ang(ii) & dir < ang(ii+1));
        else
            % 最後一個區間 [h_last, inf) -> 對應圖中的 "3.0~"
            mask = (Hs > height_range(jj) & ...
                    dir >= ang(ii) & dir < ang(ii+1));
        end
        percentbot(ii, jj) = sum(mask);
    end
end

% 3. 轉換為百分比 (%)
percentbot = (percentbot / total_count) * 100;

% 4. 計算合計 (Marginal Totals)
% 每行的合計 (右側：各方向的總和)
for i = 1:n_dir
    percentbot(i, n_height + 1) = sum(percentbot(i, 1:n_height));
end

% 每列的合計 (下方：各波高的總和)
for j = 1:n_height + 1
    percentbot(n_dir + 1, j) = sum(percentbot(1:n_dir, j));
end

% 5. 輸出檔案處理
if ~exist(filepath, 'dir'); mkdir(filepath); end
full_path = fullfile(filepath, filename);
fid3 = fopen(full_path, 'w');

% 寫入標題 (可選，增加閱讀性)
fprintf(fid3, 'Joint Probability Distribution - %s\n', filename);
% 建立格式字串，根據區間數量動態生成
fmt = [repmat('%8.2f ', 1, n_height + 1), '\n'];

for n = 1:n_dir + 1
    fprintf(fid3, fmt, percentbot(n, :));
end

% 6. 其他統計資訊
[maxHs, b] = max(Hs);
itsdirectionbot = dir(b);
if itsdirectionbot < 0; itsdirectionbot = itsdirectionbot + 360; end % 轉回正數

meanHs = mean(Hs, 'omitmissing');
meandirectionbot = mean(dir, 'omitmissing');

fprintf(fid3, '\nTotal mean of Hs = %8.2f m\n', meanHs);
fprintf(fid3, 'Total mean of direction = %8.2f degree\n', meandirectionbot);
fprintf(fid3, 'Maximum Hs = %8.2f m, Its direction = %8.2f degree\n', maxHs, itsdirectionbot);
fclose(fid3);

fprintf('統計表已存至: %s\n', full_path);
end