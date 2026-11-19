function Wind_Beaufort_scale_stastics(Beaufort_scale, Dir, file_path)
    % 1. 定義級數與方向
    % Beaufort 從 0 到 12 (或 17，視資料而定)
    max_beaufort = 17;
    b_levels = 0:max_beaufort; 
    
    % 方向 16 方位
    directions_str = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", ...
                      "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];
    
    % 2. 方向角前處理 (處理北風跨越 0/360 度的問題)
    % N 的區間是 348.75~360 與 0~11.25
    % 將 > 348.75 的度數減去 360，使其落在 -11.25 ~ 11.25 之間
    Dir(Dir >= 348.75) = Dir(Dir >= 348.75) - 360;
    dir_edges = -11.25 : 22.5 : 348.75; % 17 個點構成 16 個區間
    
    % 3. 建立統計矩陣 (Rows: Beaufort 0~17 + Total, Cols: 16 Dir + Total)
    num_b = length(b_levels);
    num_d = length(directions_str);
    count_table = zeros(num_b + 1, num_d + 1);
    
    % 4. 開始統計 (建議使用邏輯索引，效率較高)
    for r = 1:num_b
        target_b = b_levels(r);
        for c = 1:num_d
            % 找出符合該級數且在該方向區間內的資料
            idx = (Beaufort_scale == target_b) & ...
                  (Dir > dir_edges(c)) & (Dir <= dir_edges(c+1));
            count_table(r, c) = sum(idx);
        end
    end
    
    % 5. 計算邊際總和 (Marginal Sums)
    count_table(1:num_b, end) = sum(count_table(1:num_b, 1:num_d), 2); % 每列總和
    count_table(end, 1:num_d) = sum(count_table(1:num_b, 1:num_d), 1); % 每行總和
    total_samples = sum(count_table(1:num_b, end));
    count_table(end, end) = total_samples;
    
    % 6. 轉為百分比 (%)
    if total_samples > 0
        percent_table = (count_table ./ total_samples) * 100;
    else
        percent_table = count_table;
    end
    
    % 7. 寫入檔案
    fid = fopen(file_path, "w");
    if fid == -1, error('無法開啟檔案'); end
    
    % 寫入標題 (補上一個空白對齊 Beaufort 欄位)
    fprintf(fid, "%-10s", "Bft/Dir");
    fprintf(fid, ", %5s", directions_str);
    fprintf(fid, ", %s\n", "Total(%)");
    
    % 寫入各級數資料
    for r = 1:num_b + 1
        if r <= num_b
            row_label = sprintf("Bft %d", b_levels(r));
        else
            row_label = "Total(%)";
        end
        
        fprintf(fid, "%-10s", row_label);
        % 寫入該列所有的百分比
        fprintf(fid, ", %5.1f", percent_table(r, :));
        fprintf(fid, "\n");
    end
    
    fclose(fid);
    fprintf("統計完成，存檔至: %s\n", file_path);
end