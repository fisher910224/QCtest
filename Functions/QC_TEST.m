function [flags, flags_total] = QC_TEST(input_time, input_item, samplingrate, QC_settings, Options)
%{
==== INPUTS ===============================================================
VARIABLE        TYPE                DESCRIPTION
---------------------------------------------------------------------------
input_time      datetime            Time series.
                double(datenum)     時間序列。

input_item      double              Data series(N*1).
                                    資料序列。

samplingrate    double              If a numerical value is provided, the 
                duration            unit is hours (e.g., for 10-minute data
                                    , you may enter 1/6 or 10/60).
                                    資料的預期採樣時間間隔。若為數值，單位為
                                    小時 (Hours)（例如 10 分鐘資料可輸入 1/6 
                                    或 minutes(10)）。

QC_settings     struct              A structure containing the settings for
                                    various test thresholds and parameters 
                                    (see details below).
                                    包含各項測試門檻與參數的設定結構體
                                    （詳見下方說明）。

Options         Name-Value          Used to individually turn "on" or "off"
                                    Test1 ~ Test11.
                                    用於個別開啟 ("on") 或關閉 ("off") 
                                    Test1 ~ Test11。

==== OUTPUTS ==============================================================
VARIABLE        TYPE                DESCRIPTION
---------------------------------------------------------------------------
flags           double(N*11)        Each column corresponds to an 
                                    individual test flag for tests 
                                    Test1 ~ Test11. If a given test is set 
                                    to "off," the value in the 
                                    corresponding column is 0.
                                    每一欄分別對應 Test1 至 Test11 的個別檢測
                                    旗標。若該項測試設為 "off"，對應欄位數值
                                    為 0。

flags_total     double(N*1)         Final quality control flag after all 
                                    tests have been executed.
                                    綜合所有已執行測試後的最終品管旗標。
===========================================================================
============================= Tide settings ===============================
% Timing (允許 1 分鐘誤差)
TD_QCsettings.t1_suspect = 1/60; 
TD_QCsettings.t1_fail = 5/60;

% Gross Range (假設佈放點水深 17m，潮差 +/- 5m)
TD_QCsettings.t4_sensor_range = [0 25]; 
TD_QCsettings.t4_user_range = [0 25]; % 放寬一點，避免潮汐觸發
TD_QCsettings.t5_sensor_range = repmat(TD_QCsettings.t4_sensor_range, 12, 1); 
TD_QCsettings.t5_user_range = repmat(TD_QCsettings.t4_user_range, 12, 1); % 放寬一點，避免潮汐觸發

% Spike Test (10分鐘變1米算可疑)
TD_QCsettings.t6_threshold_low = 0.5;
TD_QCsettings.t6_threshold_high = 1;
TD_QCsettings.t7_n_dev = 5;
TD_QCsettings.t7_tim_dev_hours = 12;


% Flat Line (最關鍵的修正)
TD_QCsettings.t8_rep_suspect = 3;
TD_QCsettings.t8_rep_fail = 5; % 一小時不動
TD_QCsettings.t8_esp_val = 0.001; % 容許度降到 0.5cm，否則潮汐會被誤判為平線

% Attenuated Signal
TD_QCsettings.t10_min_var_warn = 0.05; % 2小時內變動不到 10cm 算可疑
TD_QCsettings.t10_min_var_fail = 0.01; % 幾乎沒動算失敗
TD_QCsettings.t10_n_tst = 24;
% save C:\Users\adm\Desktop\INTERTIDAL\代婷與的PDF們\NMMBA\Functions\TD_QCsettings.mat TD_QCsettings

% ============================ Current settings ===========================
% Timing (允許 1 分鐘誤差)
CU_QCsettings.t1_suspect = 1/60; 
CU_QCsettings.t1_fail = 5/60;

% Gross Range (流速通常 0-2 m/s 為合理範圍)
CU_QCsettings.t4_sensor_range = [-15 15]; % Python: CS_sensor_span
CU_QCsettings.t4_user_range = [0 2];      % Python: CS_user_span
% Climatology Test (月統計範圍)
% Python: CS_monthly_clim 轉換為 12x2 矩陣
CU_QCsettings.t5_sensor_range = repmat(CU_QCsettings.t4_sensor_range, 12, 1);
CU_QCsettings.t5_user_range = [
    0 1.1; 0 1.1; 0 1.1; 0 1.1; 0 1.1; 0 1.2; ... % 1-6月
    0 1.2; 0 1.2; 0 1.2; 0 1.2; 0 1.2; 0 1.1      % 7-12月
];

% Spike Test (流速跳動門檻)
CU_QCsettings.t6_threshold_low = 0.6;  % Python: CS_span (suspect)
CU_QCsettings.t6_threshold_high = 1.0; % Python: CS_span (fail)

% Rate of Change
CU_QCsettings.t7_n_dev = 3; % Python: Rate_of_Change_Thresh_Val
CU_QCsettings.t7_tim_dev_hours = 8;                 % Python: Rate_of_Change_Pre_Step

% Flat Line
CU_QCsettings.t8_rep_suspect = 3;     % Python: CS_Flat_span
CU_QCsettings.t8_rep_fail = 5;        % Python: CS_Flat_span
CU_QCsettings.t8_esp_val = 0.001;     % Python: CS_Flat_span (change_rate)


% Attenuated Signal
CU_QCsettings.t10_min_var_warn = 0.045; % Python: min_var_warn
CU_QCsettings.t10_min_var_fail = 0.005; % Python: min_var_fail
CU_QCsettings.t10_n_tst = 12;          % Python: time_range


% ========================= Current Dir. settings =========================
CD_QCsettings.t1_suspect = 1/60; 
CD_QCsettings.t1_fail = 5/60;

% Gross Range (流速通常 0-2 m/s 為合理範圍)
CD_QCsettings.t4_sensor_range = [0 360]; % Python: CS_sensor_span
CD_QCsettings.t4_user_range = [0 360];      % Python: CS_user_span
% Climatology Test (月統計範圍)
% Python: CS_monthly_clim 轉換為 12x2 矩陣
CD_QCsettings.t5_sensor_range = repmat(CD_QCsettings.t4_sensor_range, 12, 1);
CD_QCsettings.t5_user_range = repmat(CD_QCsettings.t4_sensor_range, 12, 1);

% Spike Test (流速跳動門檻)
CD_QCsettings.t6_threshold_low = 0.6;  % Python: CS_span (suspect)
CD_QCsettings.t6_threshold_high = 1.0; % Python: CS_span (fail)

% Rate of Change
CD_QCsettings.t7_n_dev = 3; % Python: Rate_of_Change_Thresh_Val
CD_QCsettings.t7_tim_dev_hours = 8;                 % Python: Rate_of_Change_Pre_Step

% Flat Line
CD_QCsettings.t8_rep_suspect = 3;     % Python: CS_Flat_span
CD_QCsettings.t8_rep_fail = 5;        % Python: CS_Flat_span
CD_QCsettings.t8_esp_val = 0.01;     % Python: CS_Flat_span (change_rate)


% Attenuated Signal
CD_QCsettings.t10_min_var_warn = 0.045; % Python: min_var_warn
CD_QCsettings.t10_min_var_fail = 0.005; % Python: min_var_fail
CD_QCsettings.t10_n_tst = 12;          % Python: time_range


% save('C:\Users\adm\Desktop\INTERTIDAL\代婷與的PDF們\NMMBA\Functions\CU_QCsettings.mat', 'CU_QCsettings', 'CD_QCsettings')


% ============================= Wave settings (HS) ========================
% 基於 Python 設定檔轉換

% Test 1: Timing (延用您的慣例：允許 1 分鐘與 5 分鐘誤差)
WV_QCsettings.t1_suspect = 1/60; 
WV_QCsettings.t1_fail = 5/60;

% Test 4: Gross Range (Python: HS_sensor_span, HS_user_span)
WV_QCsettings.t4_sensor_range = [0 40];  % Python: HS_sensor_span
WV_QCsettings.t4_user_range = [0 10];    % Python: HS_user_span

% Test 5: Climatology Test (Python: HS_monthly_clim)
% 1-2月: 5m, 3-5月: 4.5m, 6-12月: 5m
WV_QCsettings.t5_sensor_range = repmat(WV_QCsettings.t4_sensor_range, 12, 1);
WV_QCsettings.t5_user_range = repmat(WV_QCsettings.t4_user_range, 12, 1);
% WV_QCsettings.t5_user_range = [
%     0 5.0; 0 5.0; ...             % 1, 2月
%     0 4.5; 0 4.5; 0 4.5; ...      % 3, 4, 5月
%     0 5.0; 0 5.0; 0 5.0; 0 5.0; 0 5.0; 0 5.0; 0 5.0  % 6-12月
% ];

% Test 6: Spike Test (Python: HS_span)
WV_QCsettings.t6_threshold_low = 1.0;   % Python: HS_span[0] (suspect)
WV_QCsettings.t6_threshold_high = 2.0;  % Python: HS_span[1] (fail)

% Test 7: Rate of Change (Python: Rate_of_Change_Thresh_Val / Pre_Step)
WV_QCsettings.t7_n_dev = 5;             % Python: Rate_of_Change_Thresh_Val
WV_QCsettings.t7_tim_dev_hours = 8;     % Python: Rate_of_Change_Pre_Step

% Test 8: Flat Line (Python: HS_Flat_span)
WV_QCsettings.t8_rep_suspect = 3;       % Python: HS_Flat_span[0]
WV_QCsettings.t8_rep_fail = 5;          % Python: HS_Flat_span[1]
WV_QCsettings.t8_esp_val = 0.01;        % Python: HS_Flat_span[2] (change_rate)

% Test 10: Attenuated Signal (Python: min_var_warn / fail / time_range)
WV_QCsettings.t10_min_var_warn = 0.01;  % Python: min_var_warn (0.1)
WV_QCsettings.t10_min_var_fail = 0.005;  % Python: min_var_fail (0.05)
WV_QCsettings.t10_n_tst = 12;           % Python: time_range


% ============================= Wave settings (Tp) ========================
% 基於 Python 設定檔轉換

% Test 1: Timing (延用您的慣例：允許 1 分鐘與 5 分鐘誤差)
TP_QCsettings.t1_suspect = 1/60; 
TP_QCsettings.t1_fail = 5/60;

% Test 4: Gross Range (Python: HS_sensor_span, HS_user_span)
TP_QCsettings.t4_sensor_range = [0 30];  % Python: HS_sensor_span
TP_QCsettings.t4_user_range = [0 20];    % Python: HS_user_span

% Test 5: Climatology Test (Python: HS_monthly_clim)
% 1-2月: 5m, 3-5月: 4.5m, 6-12月: 5m
TP_QCsettings.t5_sensor_range = repmat(TP_QCsettings.t4_sensor_range, 12, 1);
TP_QCsettings.t5_user_range = repmat(TP_QCsettings.t4_user_range, 12, 1);
% TP_QCsettings.t5_user_range = [
%     0 5.0; 0 5.0; ...             % 1, 2月
%     0 4.5; 0 4.5; 0 4.5; ...      % 3, 4, 5月
%     0 5.0; 0 5.0; 0 5.0; 0 5.0; 0 5.0; 0 5.0; 0 5.0  % 6-12月
% ];

% Test 6: Spike Test (Python: HS_span)
TP_QCsettings.t6_threshold_low = 1.0;   % Python: HS_span[0] (suspect)
TP_QCsettings.t6_threshold_high = 2.0;  % Python: HS_span[1] (fail)

% Test 7: Rate of Change (Python: Rate_of_Change_Thresh_Val / Pre_Step)
TP_QCsettings.t7_n_dev = 5;             % Python: Rate_of_Change_Thresh_Val
TP_QCsettings.t7_tim_dev_hours = 8;     % Python: Rate_of_Change_Pre_Step

% Test 8: Flat Line (Python: HS_Flat_span)
TP_QCsettings.t8_rep_suspect = 3;       % Python: HS_Flat_span[0]
TP_QCsettings.t8_rep_fail = 5;          % Python: HS_Flat_span[1]
TP_QCsettings.t8_esp_val = 0.01;        % Python: HS_Flat_span[2] (change_rate)

% Test 10: Attenuated Signal (Python: min_var_warn / fail / time_range)
TP_QCsettings.t10_min_var_warn = 1/10;  % Python: min_var_warn (0.1)
TP_QCsettings.t10_min_var_fail = 1/20;  % Python: min_var_fail (0.05)
TP_QCsettings.t10_n_tst = 12;           % Python: time_range



 ============================= Wave settings (Dir) =======================


% Test 1: Timing 
WVD_QCsettings.t1_suspect = 1/60; 
WVD_QCsettings.t1_fail = 5/60;

% Test 4: Gross Range (Python: HS_sensor_span, HS_user_span)
WVD_QCsettings.t4_sensor_range = [0 360];  % Python: HS_sensor_span
WVD_QCsettings.t4_user_range = [0 360];    % Python: HS_user_span

% Test 5: Climatology Test (Python: HS_monthly_clim)
% 1-2月: 5m, 3-5月: 4.5m, 6-12月: 5m
WVD_QCsettings.t5_sensor_range = repmat(WVD_QCsettings.t4_sensor_range, 12, 1);
WVD_QCsettings.t5_user_range = repmat(WVD_QCsettings.t4_sensor_range, 12, 1);
% WVD_QCsettings.t5_user_range = [
%     0 5.0; 0 5.0; ...             % 1, 2月
%     0 4.5; 0 4.5; 0 4.5; ...      % 3, 4, 5月
%     0 5.0; 0 5.0; 0 5.0; 0 5.0; 0 5.0; 0 5.0; 0 5.0  % 6-12月
% ];

% Test 6: Spike Test (Python: HS_span)
WVD_QCsettings.t6_threshold_low = 1.0;   % Python: HS_span[0] (suspect)
WVD_QCsettings.t6_threshold_high = 2.0;  % Python: HS_span[1] (fail)

% Test 7: Rate of Change (Python: Rate_of_Change_Thresh_Val / Pre_Step)
WVD_QCsettings.t7_n_dev = 5;             % Python: Rate_of_Change_Thresh_Val
WVD_QCsettings.t7_tim_dev_hours = 8;     % Python: Rate_of_Change_Pre_Step

% Test 8: Flat Line (Python: HS_Flat_span)
WVD_QCsettings.t8_rep_suspect = 3;       % Python: HS_Flat_span[0]
WVD_QCsettings.t8_rep_fail = 5;          % Python: HS_Flat_span[1]
WVD_QCsettings.t8_esp_val = 0.01;        % Python: HS_Flat_span[2] (change_rate)

% Test 10: Attenuated Signal (Python: min_var_warn / fail / time_range)
WVD_QCsettings.t10_min_var_warn = 1/10;  % Python: min_var_warn (0.1)
WVD_QCsettings.t10_min_var_fail = 1/20;  % Python: min_var_fail (0.05)
WVD_QCsettings.t10_n_tst = 12;           % Python: time_range
%}
arguments
    input_time
    input_item
    samplingrate % Hours
    QC_settings struct

    Options.Test1 {mustBeMember(Options.Test1, ["on", "off"])} = "off"
    Options.Test2 {mustBeMember(Options.Test2, ["on", "off"])} = "off"
    Options.Test3 {mustBeMember(Options.Test3, ["on", "off"])} = "off"
    Options.Test4 {mustBeMember(Options.Test4, ["on", "off"])} = "off"
    Options.Test5 {mustBeMember(Options.Test5, ["on", "off"])} = "off"
    Options.Test6 {mustBeMember(Options.Test6, ["on", "off"])} = "off"
    Options.Test7 {mustBeMember(Options.Test7, ["on", "off"])} = "off"
    Options.Test8 {mustBeMember(Options.Test8, ["on", "off"])} = "off"
    Options.Test9 {mustBeMember(Options.Test9, ["on", "off"])} = "off"
    Options.Test10 {mustBeMember(Options.Test10, ["on", "off"])} = "off"
    Options.Test11 {mustBeMember(Options.Test11, ["on", "off"])} = "off"
end

%{

%}

if isduration(samplingrate)
    samplingrate = hours(samplingrate);
end

if Options.Test1 == "on"
    f1 = Test1(input_time, samplingrate, QC_settings.t1_suspect, QC_settings.t1_fail);
    fprintf("Test1 complete! Passing rate: %.2f%%\n", sum(f1 <= 2)/length(input_item)*100)
else
    f1 = zeros(size(input_item));
    fprintf("Jumped Test1.\n");
end

if Options.Test2 == "on"
    f2 = Test2(input_item);% not write yet
    fprintf("Test2 complete! Passing rate: %.2f%%\n", sum(f2 <= 2)/length(input_item)*100)
else
    f2 = zeros(size(input_item));
    fprintf("Jumped Test2.\n");
end

if Options.Test3 == "on"
    f3 = Test3(input_item);% not write yet
    fprintf("Test3 complete! Passing rate: %.2f%%\n", sum(f3 <= 2)/length(input_item)*100)
else
    f3 = zeros(size(input_item));
    fprintf("Jumped Test3.\n");
end

if Options.Test4 == "on"
    f4 = Test4(input_item, QC_settings.t4_sensor_range, QC_settings.t4_user_range);
    fprintf("Test4 complete! Passing rate: %.2f%%\n", sum(f4 <= 2)/length(input_item)*100)
else
    f4 = zeros(size(input_item));
    fprintf("Jumped Test4.\n");
end

if Options.Test5 == "on"
    f5 = Test5(input_time, input_item, QC_settings.t5_sensor_range, QC_settings.t5_user_range);
    fprintf("Test5 complete! Passing rate: %.2f%%\n", sum(f5 <= 2)/length(input_item)*100)
else
    f5 = zeros(size(input_item));
    fprintf("Jumped Test5.\n");
end

if Options.Test6 == "on"
    f6 = Test6(input_item, QC_settings.t6_threshold_low, QC_settings.t6_threshold_high);
    fprintf("Test6 complete! Passing rate: %.2f%%\n", sum(f6 <= 2)/length(input_item)*100)
else
    f6 = zeros(size(input_item));
    fprintf("Jumped Test6.\n");
end

if Options.Test7 == "on"
    f7 = Test7(input_time, input_item, QC_settings.t7_n_dev, QC_settings.t7_tim_dev_hours, samplingrate);
    fprintf("Test7 complete! Passing rate: %.2f%%\n", sum(f7 <= 2)/length(input_item)*100)
else
    f7 = zeros(size(input_item));
    fprintf("Jumped Test7.\n");
end

if Options.Test8 == "on"
    f8 = Test8(input_item, QC_settings.t8_rep_suspect, QC_settings.t8_rep_fail, QC_settings.t8_esp_val);
    fprintf("Test8 complete! Passing rate: %.2f%%\n", sum(f8 <= 2)/length(input_item)*100)
else
    f8 = zeros(size(input_item));
    fprintf("Jumped Test8.\n");
end

if Options.Test9 == "on"
    f9 = Test9(input_item); % not write yet
    fprintf("Test9 complete! Passing rate: %.2f%%\n", sum(f9 <= 2)/length(input_item)*100)
else
    f9 = zeros(size(input_item));
    fprintf("Jumped Test9.\n");
end

if Options.Test10 == "on"
    f10 = Test10(input_item, QC_settings.t10_n_tst, QC_settings.t10_min_var_warn, QC_settings.t10_min_var_fail, samplingrate);
    fprintf("Test10 complete! Passing rate: %.2f%%\n", sum(f10 <= 2)/length(input_item)*100)
else
    f10 = zeros(size(input_item));
    fprintf("Jumped Test10.\n");
end

if Options.Test11 == "on"
    f11 = Test11(input_item); % not write yet
    fprintf("Test11 complete! Passing rate: %.2f%%\n", sum(f11 <= 2)/length(input_item)*100)
else
    f11 = zeros(size(input_item));
    fprintf("Jumped Test11.\n");
end



flags = [f1, f2, f3, f4, ... 
    f5, f6, f7, f8, f9, f10, f11];

% flags_total = max(flags, [], 2);
% 1. 預設全為 2 (Not Evaluated / 未評估)
flags_total = 2 * ones(size(flags, 1), 1);

% 2. 只要有任何一項測試通過 (1)，總旗標先設為 1 (Pass)
flags_total(any(flags == 1, 2)) = 1;

% 3. 只要有任何一項測試判定為可疑 (3)，覆蓋為 3 (Suspect)
flags_total(any(flags == 3, 2)) = 3;

% 4. 只要有任何一項測試判定為不良 (4)，覆蓋為 4 (Fail)
flags_total(any(flags == 4, 2)) = 4;

% 5. 若原始數據本身是缺失 (NaN) 或有測試標記為資料遺失 (9)，覆蓋為 9 (Missing)
flags_total(isnan(input_item) | any(flags == 9, 2)) = 9;


function [flags] = Test1(input_time, samplingrate, tol_suspect, tol_fail)
% ======================== TIME GAP TEST ===========================
% ============================================= WRITE BY DTY =======
% 
%       TESTING IF THE GAP OF INPUT TIME SERIES HAS FAULT
% 
% ==================================================================
% ---- INPUT -------------------------------------------------------
% 
% INPUT_TIME:               DATA'S TIME SERIES (DATETIME or DATENUM)
% 
% SAMPLINGRATE:             DATA'S SAMPLING RATE (HR)
% 
% TOL_SUSPECT:              (OPTIONAL)DEFAULT = 1 MINUTES
% 
% TOL_FAIL:                 (OPTIONAL)DEFAULT = 0.5 * SAMPLINGRATE
% 
% ---- OUTPUT ------------------------------------------------------
% 
% FLAGS:                    THE "PASS" AND "FAIL" DATA
%                               1: PASS
%                               3: SUSPECT
%                                   (e.g. [01:00, 02:00, 03:01], 
%                                   THEN FLAG WOULD BE: 
%                                   [1, 1, 3])
%                               9: FAIL (MARK ON THE NEXT DATA, 
%                                   e.g. [01:00, 02:00, 04:00] LACK
%                                   03:00, THEN FLAG WOULD BE: 
%                                   [1, 1, 4])
% 
% ==================================================================

% arguments
%         input_time
%         samplingrate
%         tol_suspect = minutes(1) 
%         tol_fail    = hours(samplingrate) * 0.5
% end


if isnumeric(input_time)
    it = datetime(input_time(:), 'ConvertFrom', 'datenum');
elseif isdatetime(input_time)
    it = input_time(:);
end

if isnumeric(tol_suspect)
    tol_suspect = hours(tol_suspect);
end

if isnumeric(tol_fail)
    tol_fail = hours(tol_fail);
end

if tol_suspect >= tol_fail
    error('Test1 Error: tol_suspect (%s) cannot equal or larger than tol_fail (%s).', ...
          char(tol_suspect), char(tol_fail));
end


time_gap = diff(it);

sr = hours(samplingrate);

flags = ones(size(it));
if length(it) < 2
    flags(isnat(it)) = 9;
    return;
end

deviation = abs(time_gap - sr);

% flags([1, end]) = 2;
flags([false; deviation > tol_suspect]) = 3;
flags([false; deviation > tol_fail]) = 4;
flags([false; time_gap <= seconds(0)]) = 4;
flags(isnat(it)) = 9;

end

function [flags] = Test2(input_item)
    flags = ones(size(input_item));
    idx = isnan(input_item);
    flags(idx) = 9;
end

function [flags] = Test3(input_item)
    flags = ones(size(input_item));
end

function [flags] = Test4(input_item, sensor_range, user_range)
% ====================== GROSS RANGE TEST ==========================
% ============================================= WRITE BY DTY =======
% 
%       CHECK WHETHER THE DATA EXCEEDS THE LIMITS OF THE 
%       INSTRUMENT OR THE PHYSICAL PHENOMENON.
% 
% ==================================================================
% ---- INPUT -------------------------------------------------------
% 
% INPUT_ITEM:               DATA
% 
% SENSOR_RANGE:             THE SENSOR LIMITING RANGE e.g.[0 5]...
% 
% USER_RANGE:               THE USER-SETTING RANGE e.g.[0.1 4.5]...
%                           (MUST BE IN THE LIMIT_RANGE)
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
% arguments
%         input_item
%         sensor_range (1, 2) double
%         user_range (1, 2) double = sensor_range
% end

if user_range(1) < sensor_range(1) || user_range(2) > sensor_range(2)
    error('Test4 Error: user_range needs to be in range of sensor_range.');
end

input_item = input_item(:);

flags = ones(size(input_item));

idx_suspect = (input_item < user_range(1)) | (input_item > user_range(2));
flags(idx_suspect) = 3;
idx_fail = (input_item < sensor_range(1)) | (input_item > sensor_range(2));
flags(idx_fail) = 4;

flags(isnan(input_item)) = 9; 


end


function [flags] = Test5(input_time, input_item, sensor_range, user_range)
% ================== MONTHLY GROSS RANGE TEST ======================
% ============================================= WRITE BY DTY =======
% 
%       CHECK WHETHER THE DATA EXCEEDS THE LIMITS OF THE 
%       INSTRUMENT OR THE PHYSICAL PHENOMENON.
% 
% ==================================================================
% ---- INPUT -------------------------------------------------------
% 
% INPUT_TIME:               DATA'S TIME SERIES (DATETIME or DATENUM)
% 
% INPUT_ITEM:               DATA
% 
% SENSOR_RANGE:             THE SENSOR LIMITING RANGE e.g.[0 5]...
% 
% USER_RANGE:               THE USER-SETTING RANGE e.g.[0.1 4.5]...
%                           (MUST BE IN THE LIMIT_RANGE)
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
% arguments
%         input_time
%         input_item
%         sensor_range (12, 2) double
%         user_range (12, 2) double
% end

if any(user_range(:, 1) < sensor_range(:, 1)) || any(user_range(:, 2) > sensor_range(:, 2))
    error("Test5 Error: At least one month's user_range is out of sensor_range.");
end

if ~isdatetime(input_time)
    it = datetime(input_time(:), 'ConvertFrom', 'datenum');
else
    it = input_time(:);
end

mm = month(it);
input_item = input_item(:);

flags = ones(size(input_item));


for m = 1:12
    % 找出屬於該月份的資料索引
    idx_m = (mm == m);
    
    if ~any(idx_m), continue; end % 如果這個月沒資料，跳過
    
    % 取得該月份對應的閾值
    s_min = sensor_range(m, 1);
    s_max = sensor_range(m, 2);
    u_min = user_range(m, 1);
    u_max = user_range(m, 2);
    
    % 該月份的數值
    current_vals = input_item(idx_m);
    current_flags = ones(size(current_vals));
    
    % 先判斷 Suspect (3)
    current_flags(current_vals < u_min | current_vals > u_max) = 3;
    
    % 再判斷 Fail (4)
    current_flags(current_vals < s_min | current_vals > s_max) = 4;
    
    % 放回總 Flag 矩陣中
    flags(idx_m) = current_flags;
end


flags(isnan(input_item)) = 9; 


end


function [flags] = Test6(input_item, threshold_low, threshold_high)
% ========================= SPIKE TEST =============================
% ============================================= WRITE BY DTY =======
% 
%       CHECK WHETHER THE DATA EXCEEDS A SELECTED THRESHOLD.
% 
% ==================================================================
% ---- INPUT -------------------------------------------------------
% 
% INPUT_ITEM:               DATA
% 
% THRESHOLD_LOW:            OPERATOR-SELECTED THRESHOLD e.g. 20...
% 
% THRESHOLD_HIGH:           OPERATOR-SELECTED THRESHOLD e.g. 40...
%                           (MUST BE LARGER THAN THE LIMIT_RANGE)
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
% arguments
%     input_item
%     threshold_low double
%     threshold_high double
% end

if threshold_low >= threshold_high
    error('Test6 Error: threshold_low must be smaller than threshold_high.');
end

if threshold_low < 0 || threshold_high < 0
    error('Test6 Error: Thresholds must be non-negative.');
end

input_item = input_item(:);
N = length(input_item);
if N < 3
    flags = repmat(2, size(input_item));
    flags(isnan(input_item)) = 9;
    return;
end


flags = ones(size(input_item));

x_target = input_item(2:end-1);
x_prev   = input_item(1:end-2);
x_next   = input_item(3:end);

SPK_REF = mean([x_prev, x_next], 2, 'omitnan');
diff_val = abs(x_target - SPK_REF);
has_nan_neighbor = isnan(x_prev) | isnan(x_next);

mask_suspect = [false; diff_val > threshold_low; false];
mask_fail    = [false; diff_val > threshold_high; false];

flags([1, end]) = 2;
flags([false; has_nan_neighbor; false] & flags ~= 9) = 2;

flags(mask_suspect) = 3;
flags(mask_fail) = 4;

flags(isnan(input_item)) = 9;

end


function [flags] = Test7(input_time, input_item, n_dev, tim_dev_hours, expected_interval)
% ===================== RATE OF CHANGE TEST ========================
% ============================================= WRITE BY DTY =======
% 
%       EXCESSIVE RIDE/FALL TEST
% 
% ==================================================================
% ---- INPUT -------------------------------------------------------
% 
% INPUT_ITEM:               DATA
% 
% N_DEV:                    OPERATOR-SELECTED THRESHOLD e.g. 20...
% 
% TIME_DEV:                 OPERATOR-SELECTED THRESHOLD e.g. 40...
%                           (MUST BE LARGER THAN THE LIMIT_RANGE)
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
% arguments
%     input_time
%     input_item
%     n_dev double = 3          % 手冊建議 3
%     tim_dev_hours double = 24 % 手冊範例 8，你原始碼用 24
%     expected_interval = hours(1)
% end

if ~isdatetime(input_time)
    it = datetime(input_time(:), 'ConvertFrom', 'datenum');
else
    it = input_time(:);
end

input_item = input_item(:);
flags = ones(size(input_item));

dv = diff(input_item);
dt = diff(it);

% pts_in_window = round(hours(tim_dev_hours) / expected_interval);
if isduration(expected_interval)
    % 如果都是 duration，相除會得到 double
    pts_in_window = round(hours(tim_dev_hours) / hours(expected_interval));
else
    % 如果 expected_interval 已經是數字
    pts_in_window = round(tim_dev_hours / expected_interval);
end
moving_sd = movstd(dv, [pts_in_window-1, 0], 'omitnan');
time_is_valid = dt <= (expected_interval * 1.5);

abs_change = abs(dv);
% threshold = n_dev * moving_sd;
min_allowable_sd = 0.05; % 保底標準差 5cm
threshold = n_dev * max(moving_sd, min_allowable_sd);

is_suspect = (abs_change > threshold) & time_is_valid;
target_idx = 2:length(input_item);
flags(target_idx(is_suspect)) = 3;

flags(1:pts_in_window) = 2;
flags(isnan(input_item)) = 9;


end


function [flags] = Test8(input_item, rep_cnt_suspect, rep_cnt_fail, esp_val)
% ======================= FLAT LINE TEST ===========================
% ============================================= WRITE BY DTY =======
% 
%       CHECK WHETHER THE SENSOR IS STUCK AT A CONSTANT VALUE.
%       BASED ON QARTOD TEST 8.
% 
% ==================================================================
% ---- INPUT -------------------------------------------------------
% 
% INPUT_ITEM:               DATA
% 
% REP_CNT_FAIL:             THRESHOLD FOR SUSPECT (e.g., 3)
% 
% REP_CNT_SUSPECT:          THRESHOLD FOR FAIL (e.g., 5)
% 
% ESP:                      TOLERANCE FOR NUMERICAL ROUND-OFF ERROR
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

% arguments
%     input_item
%     rep_cnt_suspect double = 3
%     rep_cnt_fail double = 5
%     esp_val double = 0.5
% end

input_item = input_item(:);

if rep_cnt_suspect >= rep_cnt_fail
    error('Test8 Error: rep_cnt_suspect needs to be less than rep_cnt_fail.');
end

flags = ones(size(input_item));
n = length(input_item);
flags(isnan(input_item)) = 9;
flags(1:rep_cnt_suspect-1) = 2;

for ii = 1:length(input_item)

    if flags(ii) == 9; continue; end

    if ii >= rep_cnt_fail
        window = input_item(ii - rep_cnt_fail +1 : ii);
        
            if ~any(isnan(window))    
                if all(abs(window - input_item(ii)) <= esp_val)
                    flags(ii) = 4;
                    continue
                end
            end

    end

    if ii >= rep_cnt_suspect
        window = input_item(ii - rep_cnt_suspect +1 : ii);

        if ~any(isnan(window))
            if all(abs(window - input_item(ii)) <= esp_val)
                flags(ii) = 3;
            end
        end
    end
end


end

function [flags] = Test9(input_item)
    flags = ones(size(input_item));
end


function [flags] = Test10(input_item, test_duration, min_var_warn, min_var_fail, sampling_rate)
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

% arguments
%     input_time
%     input_item
%     test_duration = hours(24) % QARTOD 常用視窗長度
%     min_var_warn double = 0.01
%     min_var_fail double = 0.005
%     sampling_rate = hours(1)
% end

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

flags(1:n_tst-1) = 2;
flags(idx_suspect) = 3;
flags(idx_fail) = 4;

% 最後補回原始 NaN 的標記
flags(isnan(input_item)) = 9;


end


function [flags] = Test11(input_item)
    flags = ones(size(input_item));
end


end


