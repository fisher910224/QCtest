function Vanalyis_Curdir(Cur, dir, speed_range, filepath, filename)
% Cur: 流速向量 (例如 cm/s 或 m/s)
% dir: 流向向量 (0-360)
% speed_range: 流速區間邊界，例如 0:10:100 或 0:0.1:1.0

% 1. 方向處理 (將 348.75-360 映射到負數區間，方便與 0-11.25 合併為北向)
gg = find(dir >= 348.75 & dir < 360);
dir(gg) = dir(gg) - 360;

% 定義方向中心點與邊界 (16個方位)
ang = -11.25:22.5:348.75; 
n_dir = length(ang) - 1; % 應為 16
n_speed = length(speed_range); 

% 初始化矩陣 (行: 方向+合計, 列: 流速區間+合計)
percentbot = zeros(n_dir + 1, n_speed + 1); 

% 2. 統計核心邏輯
valid_idx = ~isnan(Cur) & ~isnan(dir);
total_count = sum(valid_idx);

if total_count == 0
    error('沒有有效的數據可供統計。');
end

for ii = 1:n_dir
    for jj = 1:n_speed
        if jj < n_speed
            % 一般區間 (s1, s2]
            mask = (Cur > speed_range(jj) & Cur <= speed_range(jj+1) & ...
                    dir >= ang(ii) & dir < ang(ii+1));
        else
            % 最後一個區間 (s_last, inf)
            mask = (Cur > speed_range(jj) & ...
                    dir >= ang(ii) & dir < ang(ii+1));
        end
        percentbot(ii, jj) = sum(mask & valid_idx);
    end
end

% 3. 轉換為百分比 (%)
percentbot = (percentbot / total_count) * 100;

% 4. 計算合計 (Marginal Totals)
for i = 1:n_dir
    percentbot(i, n_speed + 1) = sum(percentbot(i, 1:n_speed));
end
for j = 1:n_speed + 1
    percentbot(n_dir + 1, j) = sum(percentbot(1:n_dir, j));
end

% 5. 輸出檔案處理
if ~exist(filepath, 'dir'); mkdir(filepath); end
full_path = fullfile(filepath, filename);
[fid3, errmsg] = fopen(full_path, 'w');

if fid3 == -1
    error('無法開啟檔案！原因：%s', errmsg);
end

fprintf(fid3, 'Joint Probability Distribution (Current Speed vs Direction) - %s\n', filename);

% 動態生成格式字串
fmt = [repmat('%8.2f ', 1, n_speed + 1), '\n'];

for n = 1:n_dir + 1
    fprintf(fid3, fmt, percentbot(n, :));
end

% 6. 其他統計資訊 (更新為流速相關術語)
[maxCur, b] = max(Cur);
itsdirectionbot = dir(b);
if itsdirectionbot < 0; itsdirectionbot = itsdirectionbot + 360; end % 轉回正數 0-360

meanCur = mean(Cur, 'omitmissing');
meandirectionbot = mean(dir, 'omitmissing');
if meandirectionbot < 0; meandirectionbot = meandirectionbot + 360; end

fprintf(fid3, '\nTotal mean of Current Speed = %8.2f m/s\n', meanCur);
fprintf(fid3, 'Total mean of Direction = %8.2f degree\n', meandirectionbot);
fprintf(fid3, 'Maximum Current Speed = %8.2f m/s, Its direction = %8.2f degree\n', maxCur, itsdirectionbot);
fclose(fid3);

fprintf('海流統計表已存至: %s\n', full_path);
end