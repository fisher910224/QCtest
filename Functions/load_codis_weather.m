function weather = load_codis_weather(folder_path, output_as_table)
    % LOAD_CODIS_WEATHER 批次讀取並整併 CODIS 逐時天氣資料
    %
    % 用法:
    %   weather = load_codis_weather("C:\...\鳳鼻頭\");
    %   weather = load_codis_weather("C:\...\鳳鼻頭\", true); % 輸出為 table
    
    if nargin < 2
        output_as_table = false; % 預設輸出為含有純量向量的 struct
    end
    
    % 1. 遞迴搜尋目標資料夾下的所有 txt
    file_list = dir(fullfile(folder_path, "**", "*.txt"));
    file_list = file_list(~[file_list.isdir]); % 確保只抓檔案
    
    if isempty(file_list)
        error("在指定路徑下未找到任何 .txt 檔案: %s", folder_path);
    end
    
    num_files = length(file_list);
    monthly_tables = cell(num_files, 1);
    
    fprintf("正在讀取 %d 個月份的資料...\n", num_files);
    
    % 2. 逐檔讀取
    for ii = 1:num_files
        file_path = fullfile(file_list(ii).folder, file_list(ii).name);


        fid = fopen(file_path, 'r', 'native', 'UTF-8');
        header_line = "";
        line_idx = 0;
        
        while ~feof(fid)
            tline = fgetl(fid);
            line_idx = line_idx + 1;
            if startsWith(strtrim(tline), "# stno")
                header_line = strtrim(tline);
                header_line_num = line_idx;
                break;
            end
        end
        fclose(fid);


        if header_line == ""
            warning("檔案 %s 未找到表頭 (# stno)，跳過此檔案。", file_list(ii).name);
            continue;
        end


        raw_tokens = split(header_line);
        var_names = raw_tokens(~strcmp(raw_tokens, "#") & ~cellfun('isempty', raw_tokens));
        n_vars = length(var_names); % 這裡就是準確的欄位數（stno, yyyymmddhh, PS01...）
        
        % 自動偵測設定
        % opts_raw = detectImportOptions(file_path, 'VariableNamesLine', 79);
        % n_vars = length(opts_raw.VariableNames) - 1;
        
        % 設定 fixed-width 格式
        opts = delimitedTextImportOptions("NumVariables", n_vars);
        opts.Delimiter = " ";
        opts.ConsecutiveDelimitersRule = "join"; % 將連續多個空格視為單一分隔符
        opts.LeadingDelimitersRule = "ignore";   % 忽略行首空格
        opts.TrailingDelimitersRule = "ignore";  % 忽略行尾空格
        opts.VariableNames = var_names;
        opts.DataLines = [header_line_num + 1, Inf]; % 表頭的下一行就是資料開始
        opts.VariableTypes = ["string", "string", repmat("double", 1, n_vars - 2)];
        opts = setvaropts(opts, var_names(3:end), "TreatAsMissing", "None");
        % opts = fixedWidthImportOptions("NumVariables", n_vars);
        % opts.DataLines = opts_raw.DataLines;
        % opts.VariableTypes = ["string", "string", repmat("double", 1, n_vars - 2)];
        % opts.VariableWidths = [7, 11, repmat(9, 1, n_vars - 2)];
        % opts.VariableNames = opts_raw.VariableNames(2:end);
        
        df = readtable(file_path, opts);
        
        % 處理時間解析 (修復 CODIS 的 24 小時問題)
        time_str = df.yyyymmddhh;
        dt = datetime(time_str, "InputFormat", "yyyyMMddHH");
        
        % 若有 NaT，用 fillmissing 以前一筆遞補 + 1小時 (比 ig-1 更安全防呆)
        if any(isnat(dt))
            dt = fillmissing(dt, "linear"); 
            % 或保持你的補法，但加上防呆：
            % nat_idx = find(isnat(dt));
            % valid_idx = nat_idx(nat_idx > 1);
            % dt(valid_idx) = dt(valid_idx - 1) + hours(1);
        end
        
        % 將處理好的 datetime 放在第一欄，並移除原本多餘的前兩欄文字
        df.ddatetime = dt;
        df = removevars(df, opts.VariableNames(1:2)); % 移除原始代碼與 yyyymmddhh
        df = movevars(df, "ddatetime", "Before", 1);  % 將 ddatetime 移到最前面
        
        monthly_tables{ii} = df;
    end
    
    % 3. 一行垂直合併所有月份的 table
    all_table = vertcat(monthly_tables{:});
    
    % 4. 依照時間排序 (sortrows 自動處理所有欄位)
    all_table = sortrows(all_table, "ddatetime");

    % =================== [新增這段] ===================
    % 4.1 將所有氣象數值（第 2 欄到最後一欄）中小於 0 的缺測值轉為 NaN
    numeric_data = all_table{:, 2:end};        % 取出所有數值欄位為矩陣
    numeric_data(numeric_data < 0) = NaN;      % 將小於 0 的值全部替換為 NaN
    all_table{:, 2:end} = numeric_data;        % 放回表格中
    % ==================================================
    
    % 5. 根據需求輸出
    if output_as_table
        weather = all_table;
    else
        % 'ToScalar', true 會直接將 Table 的各欄轉為 struct 內的垂直行向量
        weather = table2struct(all_table, "ToScalar", true);
    end
    
    fprintf("資料處理完成，共合併 %d 筆逐時資料。\n", height(all_table));
end