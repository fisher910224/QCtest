%% QC of Xingda wave
% edited 20261103
clear; close all; clc;

%% Path
main_folder = "C:\Users\adm\Desktop\Xingda\2026\0418_0606";

dd = dir(fullfile(main_folder, "Data\*.xlsx"));
import_filename = fullfile(dd(1).folder, dd(1).name);
orig_data = readtable(import_filename, "ReadVariableNames", false);

Wave = struct();
dd_file = detectImportOptions(import_filename);
for ii = 1:length(dd_file.VariableNames)
    name_now = string(dd_file.VariableNames{ii});
    Wave.((name_now)) = table2array(orig_data(:, ii));
end
orig_ddatetime = datetime([Wave.year, Wave.month, Wave.day, Wave.hour, Wave.min, zeros(size(orig_data.Var1))]);
orig_dday = datenum(orig_ddatetime);
Wave.Dir = Wave.MeanDir;
Wave = rmfield(Wave, {'month', 'day', 'year', 'hour', 'min'});

% [filled_time, ~] = find_missing_data(orig_ddatetime);


%% QC settings
% ============================= Wave settings (HS) ========================
WV_QCsettings = struct("t1_suspect", 5/60, "t1_fail", 30/60, ...
    "t4_sensor_range", [0 30], "t4_user_range", [0 10], ...
    "t5_sensor_range", repmat([0 30], 12, 1), "t5_user_range", [repmat([0 3], 5, 1); repmat([0 5], 6, 1); 0 3], ...
    "t6_threshold_low", 0.6, "t6_threshold_high", 1, ...
    "t7_n_dev", 5, "t7_tim_dev_hours", 8, ...
    "t8_rep_suspect", 5, "t8_rep_fail", 12, "t8_esp_val", 0.001, ...
    "t10_min_var_warn", 0.005, "t10_min_var_fail", 0.001, "t10_n_tst", 12);
% ============================= Wave settings (Tp) ========================
TP_QCsettings = struct("t1_suspect", 5/60, "t1_fail", 30/60, ...
    "t4_sensor_range", [1 50], "t4_user_range", [1 20], ...
    "t5_sensor_range", repmat([1 50], 12, 1), "t5_user_range", [repmat([1 10], 5, 1); repmat([1 20], 6, 1); 1 10], ...
    "t6_threshold_low", 3, "t6_threshold_high", 5, ...
    "t7_n_dev", 5, "t7_tim_dev_hours", 8, ...
    "t8_rep_suspect", 5, "t8_rep_fail", 12, "t8_esp_val", 0.01, ...
    "t10_min_var_warn", 0.1, "t10_min_var_fail", 0.02, "t10_n_tst", 12);

% ============================= Wave settings (Dir) =======================
WVD_QCsettings = struct("t1_suspect", 1/60, "t1_fail", 5/60, ...
    "t4_sensor_range", [0 360], "t4_user_range", [0 360], ...
    "t5_sensor_range", repmat([0 360], 12, 1), "t5_user_range", repmat([0 360], 12, 1));

%% QC
filename = sprintf("Wave_Flag_statistics.csv");
fid = fopen(fullfile(main_folder, filename), "w");
fprintf(fid, "QC statistics table (%%)\n");

layer_str = ["Hs", "Tmean", "Tp", "Dir"];
for ii = 1:length(layer_str)
    % [filled_time, filled_data] = find_missing_data(orig_dday, cur(:, ii));
    samplingrate = mode(diff(orig_ddatetime));
    [filled_time, with_nan_data, with_nan_time] = find_missing_data(orig_dday, Wave.((layer_str{ii})), samplingrate, 30/60);
    if ii == 1
        [~, dir_with_nan_data, ~] = find_missing_data(orig_dday, Wave.MeanDir(:, ii), samplingrate, 30/60);
    end
    flags = [];
    flags_total = [];
    if strcmpi(layer_str{ii}, "Hs")
    [flags, flags_total] = QC_TEST(with_nan_time, with_nan_data, samplingrate, WV_QCsettings, ...
        "Test1", "on", "Test2", "on", "Test3", "off", "Test4", "on", "Test5", "on", "Test6", "on", ...
        "Test7", "on", "Test8", "on", "Test9", "off", "Test10", "on", "Test11", "off");
    elseif strcmpi(layer_str{ii}, "Dir")
    [flags, flags_total] = QC_TEST(with_nan_time, with_nan_data, samplingrate, WVD_QCsettings, ...
        "Test1", "on", "Test2", "on", "Test3", "off", "Test4", "on", "Test5", "on", "Test6", "off", ...
        "Test7", "off", "Test8", "off", "Test9", "off", "Test10", "off", "Test11", "off");
    else
    [flags, flags_total] = QC_TEST(with_nan_time, with_nan_data, samplingrate, TP_QCsettings, ...
        "Test1", "on", "Test2", "on", "Test3", "off", "Test4", "on", "Test5", "on", "Test6", "on", ...
        "Test7", "on", "Test8", "on", "Test9", "off", "Test10", "on", "Test11", "off");
    end
    kk = max(flags, [], 2, "omitmissing");
    
    Wave.((layer_str(ii) + "flags")) = flags;
    Wave.((layer_str(ii) + "flags_total")) = flags_total;
    % filename = sprintf("QC_%s_flags.csv", layer_str(ii));
    figure("OuterPosition", [1 1 900 600])
    plot(with_nan_time, with_nan_data, 'r', "DisplayName", "Flag 4"); hold on
    % [filled_time, filled_data, with_nan_time] = find_missing_data(orig_dday, Wave.((layer_str{ii})));
    QC_time = NaT(size(with_nan_data));
    QC_data = NaN(size(with_nan_data));
    dir_QC_data = NaN(size(with_nan_data));
    idx_flags = find(flags_total <= 3);
    QC_time(idx_flags) = filled_time(idx_flags);
    QC_data(idx_flags) = with_nan_data(idx_flags);
    dir_QC_data(idx_flags) = dir_with_nan_data(idx_flags);
    plot(QC_time, QC_data, 'g', "DisplayName", "Flag 1")
    idx_flag3 = find(flags_total == 3);
    plot(filled_time(idx_flag3), with_nan_data(idx_flag3), '.', "Color", "#FFD306", "MarkerSize", 10, "DisplayName", "Flag 3");
    legend

    fprintf(fid, "%s %s\n", layer_str(ii), sprintf("%s~%s", datestr(filled_time(1), "yyyy/mm/dd"), datestr(filled_time(end), "mm/dd")));
    fprintf(fid, "Expected Points: %d\t", length(filled_time));
    fprintf(fid, "Actual Points: %d\n", length(orig_dday));
    fprintf(fid, ",Pass(1),Unknown(2),Suspect(3),Fail(4),Missing(9)\n");
    if ~strcmpi(layer_str(ii), "Dir")
        tt = [1, 2, 4, 5, 6, 7, 8, 10];
    else
        tt = [1, 2, 4, 5];
    end
    for jj = tt

        if jj == 3 || jj == 9 || jj == 11
            fprintf(fid, "Test%d,N/A,N/A,N/A,N/A,N/A\n", jj);
        else
            fprintf(fid, "Test%d,%d,%d,%d,%d,%d\n", jj, sum(flags(:, jj) == 1), ...
                sum(flags(:, jj) == 2), ...
                sum(flags(:, jj) == 3), ...
                sum(flags(:, jj) == 4), ...
                sum(flags(:, jj) == 9));
            fprintf(fid, ",%.2f%%,%.2f%%,%.2f%%,%.2f%%,%.2f%%\n", calculate_percentage(flags(:, jj), 1), ...
                calculate_percentage(flags(:, jj), 2), ...
                calculate_percentage(flags(:, jj), 3), ...
                calculate_percentage(flags(:, jj), 4), ...
                calculate_percentage(flags(:, jj), 9));
        end
    end
    fprintf(fid, "Total,%d,%d,%d,%d,%d\n", sum(kk == 1), ...
                sum(kk == 2), ...
                sum(kk == 3), ...
                sum(kk == 4), ...
                sum(kk == 9));
    fprintf(fid, ",%.2f%%,%.2f%%,%.2f%%,%.2f%%,%.2f%%\n", calculate_percentage(kk, 1), ...
            calculate_percentage(kk, 2), ...
            calculate_percentage(kk, 3), ...
            calculate_percentage(kk, 4), ...
            calculate_percentage(kk, 9));

    Wave.with_nan_data.((layer_str{ii})) = with_nan_data;
    Wave.QC.((layer_str{ii})) = QC_data;
    Wave.filled_time = filled_time;
    Wave.((layer_str{ii}+"_time")) = with_nan_time;
    % if ii == 1
    %     Wave.with_nan_data.Dir = dir_with_nan_data;
    %     Wave.QC.Dir = dir_QC_data;
    % end
end

fclose(fid);

ig = find(isnan(Wave.QC.Hs));
Wave.QC.Dir(ig) = NaN;

% save("PROCESSED_DATA_WAVE.mat", "-struct", "Wave");
save("PROCESSED_DATA_WAVE.mat", "Wave");

function pp = calculate_percentage(ipt, idx)
    n = length(ipt);
    ig = find(ipt == idx);
    pp = length(ig) / n * 100;
end





