%% QC of Xingda current
% edited 20261102
clear; close all; clc;

%% Path
main_folder = "C:\Users\adm\Desktop\Xingda\2026\0418_0606";

orig_data = readtable(fullfile(main_folder, "Data\S107884A005_NSYSU_SINDAA0_avgd-forCurrent.xlsx"), "ReadVariableNames", false);

Cur = struct();
orig_ddatetime = datetime(orig_data.Var1, "InputFormat", "MM/dd/uuuu HH:mm:ss");
orig_dday = datenum(orig_ddatetime);
SL = orig_data.Var2;
temp = orig_data.Var3;
u = table2array(orig_data(:, 4:2:end));
v = table2array(orig_data(:, 5:2:end));
cur = sqrt(u.^2 + v.^2);
cur_dir = atan2d(v, u);
theta_360 = mod(90 - cur_dir, 360);

Cur.SL = SL;
Cur.Cur = cur;
Cur.Dir = theta_360;
Cur.u = u;
Cur.v = v;
Cur.temp = temp;


%% QC settings
% ============================= Tide settings =============================
% Timing (允許 1 分鐘誤差)
TD_QCsettings = struct("t1_suspect", 1/60, "t1_fail", 5/60, ...
    "t4_sensor_range", [0 30], "t4_user_range", [15 25], ...
    "t5_sensor_range", repmat([0 25], 12, 1), "t5_user_range", repmat([15 25], 12, 1), ... 
    "t6_threshold_low", 0.5, "t6_threshold_high", 1.0, ...
    "t7_n_dev", 3, "t7_tim_dev_hours", 8, ...
    "t8_rep_suspect", 6, "t8_rep_fail", 12, "t8_esp_val", 0.001, ...
    "t10_min_var_warn", 0.05, "t10_min_var_fail", 0.01, "t10_n_tst", 24);

% ============================ Current settings ===========================
CU_QCsettings = struct("t1_suspect", 1/60, "t1_fail", 5/60, ...
    "t4_sensor_range", [0 5], "t4_user_range", [0 2], ...
    "t5_sensor_range", repmat([0 5], 12, 1), "t5_user_range", [0 1.1; 0 1.1; 0 1.1; 0 1.1; 0 1.1; 0 1.2; ... % 1-6月
                                                                  0 1.2; 0 1.2; 0 1.2; 0 1.2; 0 1.2; 0 1.1], ... % 7-12月
    "t6_threshold_low", 0.6, "t6_threshold_high", 1.0, ...
    "t7_n_dev", 3, "t7_tim_dev_hours", 8, ...
    "t8_rep_suspect", 3, "t8_rep_fail", 5, "t8_esp_val", 0.001, ...
    "t10_min_var_warn", 0.02, "t10_min_var_fail", 0.005, "t10_n_tst", 12);

% ========================= Current Dir. settings =========================
CD_QCsettings = struct("t1_suspect", 1/60, "t1_fail", 5/60, ...
    "t4_sensor_range", [0 360], "t4_user_range", [0 360], ...
    "t5_sensor_range", repmat([0 360], 12, 1), "t5_user_range", repmat([0 360], 12, 1));

%% QC
filename = sprintf("Cur_Flag_statistics.csv");
fid = fopen(fullfile(main_folder, filename), "w");
fprintf(fid, "QC statistics table (%%)\n");

layer_str = ["BottomLayer", "MiddleLayer", "TopLayer"];
for ii = 3:-1:1
    samplingrate = mode(diff(orig_ddatetime));
    [filled_time, with_nan_data, with_nan_time] = find_missing_data(orig_dday, cur(:, ii), samplingrate, 5/60);
    [~, dir_with_nan_data, dir_with_nan_time] = find_missing_data(orig_dday, theta_360(:, ii), samplingrate, 5/60);
    flags = [];
    flags_total = [];
    [flags, flags_total] = QC_TEST(with_nan_time, with_nan_data, samplingrate, CU_QCsettings, ...
        "Test1", "on", "Test2", "on", "Test3", "off", "Test4", "on", "Test5", "on", "Test6", "on", ...
        "Test7", "on", "Test8", "on", "Test9", "off", "Test10", "on", "Test11", "off");
    [dir_flags, dir_flags_total] = QC_TEST(dir_with_nan_time, dir_with_nan_data, samplingrate, CD_QCsettings, ...
        "Test1", "on", "Test2", "on", "Test3", "off", "Test4", "on", "Test5", "on", "Test6", "off", ...
        "Test7", "off", "Test8", "off", "Test9", "off", "Test10", "off", "Test11", "off");
    kk = max(flags, [], 2, "omitmissing");
    dirkk = max(dir_flags, [], 2, "omitmissing");
    
    Cur.((layer_str(ii) + "flags")) = flags;
    Cur.((layer_str(ii) + "flags_total")) = flags_total;
    Cur.((layer_str(ii) + "Dir_flags")) = dir_flags;
    Cur.((layer_str(ii) + "Dir_flags_total")) = dir_flags_total;
    % filename = sprintf("QC_%s_flags.csv", layer_str(ii));
    figure
    plot(filled_time, with_nan_data, 'r'); hold on
    QC_time = NaT(size(with_nan_data));
    QC_data = NaN(size(with_nan_data));
    dir_QC_data = NaN(size(with_nan_data));
    idx_flags = find(flags_total <= 3);
    dir_idx_flags = find(dir_flags_total <= 3);
    QC_time(idx_flags) = filled_time(idx_flags);
    QC_data(idx_flags) = with_nan_data(idx_flags);
    dir_QC_data(dir_idx_flags) = dir_with_nan_data(dir_idx_flags);
    plot(QC_time, QC_data, 'g')
    idx_flag3 = find(flags_total == 3);
    plot(filled_time(idx_flag3), with_nan_data(idx_flag3), '.', "Color", "#FFD306", "MarkerSize", 10);
    legend

    fprintf(fid, "\n%s %s\n", layer_str(ii), sprintf("%s~%s", datestr(filled_time(1), "yyyy/mm/dd"), datestr(filled_time(end), "mm/dd")));
    fprintf(fid, "Expected Points: %d\t", length(filled_time));
    fprintf(fid, "Actual Points: %d\n", length(orig_dday));
    fprintf(fid, ",Pass(1),Unknown(2),Suspect(3),Fail(4),Missing(9)\n");
    for jj = [1, 2, 4, 5, 6, 7, 8, 10]

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

    fprintf(fid, "\n%s Direction %s\n", layer_str(ii), sprintf("%s~%s", datestr(filled_time(1), "yyyy/mm/dd"), datestr(filled_time(end), "mm/dd")));
    fprintf(fid, "Expected Points: %d\t", length(filled_time));
    fprintf(fid, "Actual Points: %d\n", length(orig_dday));
    fprintf(fid, ",Pass(1),Unknown(2),Suspect(3),Fail(4),Missing(9)\n");
    for jj = [1, 2, 4, 5]

        if jj == 3 || jj == 9 || jj == 11
            fprintf(fid, "Test%d,N/A,N/A,N/A,N/A,N/A\n", jj);
        else
            fprintf(fid, "Test%d,%d,%d,%d,%d,%d\n", jj, sum(dir_flags(:, jj) == 1), ...
                sum(dir_flags(:, jj) == 2), ...
                sum(dir_flags(:, jj) == 3), ...
                sum(dir_flags(:, jj) == 4), ...
                sum(dir_flags(:, jj) == 9));
            fprintf(fid, ",%.2f%%,%.2f%%,%.2f%%,%.2f%%,%.2f%%\n", calculate_percentage(dir_flags(:, jj), 1), ...
                calculate_percentage(dir_flags(:, jj), 2), ...
                calculate_percentage(dir_flags(:, jj), 3), ...
                calculate_percentage(dir_flags(:, jj), 4), ...
                calculate_percentage(dir_flags(:, jj), 9));
        end
    end
    fprintf(fid, "Total,%d,%d,%d,%d,%d\n", sum(dirkk == 1), ...
                sum(dirkk == 2), ...
                sum(dirkk == 3), ...
                sum(dirkk == 4), ...
                sum(dirkk == 9));
    fprintf(fid, ",%.2f%%,%.2f%%,%.2f%%,%.2f%%,%.2f%%\n", calculate_percentage(dirkk, 1), ...
            calculate_percentage(dirkk, 2), ...
            calculate_percentage(dirkk, 3), ...
            calculate_percentage(dirkk, 4), ...
            calculate_percentage(dirkk, 9));

    Cur.with_nan_data.((layer_str{ii})) = with_nan_data;
    Cur.with_nan_data.((layer_str{ii}) + "_Dir") = dir_with_nan_data;
    Cur.QC.((layer_str{ii})) = QC_data;
    Cur.QC.((layer_str{ii} + "_Dir")) = dir_QC_data;
    % Cur.filled_time = filled_time;
    Cur.((layer_str{ii}+"_time")) = QC_time;
end

flags = [];
flags_total = [];
[filled_time, with_nan_data] = find_missing_data(orig_dday, SL);
[flags, flags_total] = QC_TEST(filled_time, with_nan_data, samplingrate, TD_QCsettings, ...
    "Test1", "on", "Test2", "on", "Test3", "off", "Test4", "on", "Test5", "on", "Test6", "on", ...
    "Test7", "on", "Test8", "on", "Test9", "off", "Test10", "on", "Test11", "off");
kk = max(flags, [], 2, "omitmissing");

Cur.(("SL" + "flags")) = flags;
Cur.(("SL" + "flags_total")) = flags_total;
%
figure
plot(filled_time, with_nan_data, 'r'); hold on
QC_time = NaT(size(with_nan_data));
QC_data = NaN(size(with_nan_data));
idx_flags = find(Cur.SLflags_total <= 3);
QC_time(idx_flags) = filled_time(idx_flags);
QC_data(idx_flags) = with_nan_data(idx_flags);
plot(QC_time, QC_data, 'g')
idx_flag3 = find(Cur.SLflags_total == 3);
plot(filled_time(idx_flag3), with_nan_data(idx_flag3), '.', "Color", "#FFD306", "MarkerSize", 10);

fprintf(fid, "SeaLevel\n");
fprintf(fid, ",Pass(1),Unknown(2),Suspect(3),Fail(4),Missing(9)\n");
for jj = [1, 2, 4, 5, 6, 7, 8, 10]

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

Cur.with_nan_data.(("SL")) = with_nan_data;
Cur.QC.(("SL")) = QC_data;
Cur.filled_time = filled_time;
Cur.(("SL"+"_time")) = QC_time;

fclose(fid);


% save("PROCESSED_DATA_WAVE.mat", "-struct", "Wave");
save("PROCESSED_DATA_CUR.mat", "Cur");

function pp = calculate_percentage(ipt, idx)
    n = length(ipt);
    ig = find(ipt == idx);
    pp = length(ig) / n * 100;
end





