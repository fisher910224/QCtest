%% Xingda Harbor
% 0418-0606
% 20260810 edited
clear; close all; clc;

%% path
main_folder = 'C:\Users\adm\Desktop\Xingda\2026\0418_0606';
cd(main_folder)
p_data = "C:\Users\adm\Desktop\Xingda\2026\0418_0606\processed_data";
if ~isfolder(p_data)
    mkdir(p_data)
end

%% data processing
% cd([main_folder, '\Data\'])
% dd = dir('*.xlsx');
cd([main_folder, '\QC\Meng'])
dd = dir('*.txt');
% ================================= Wave ==================================
wave_data = readtable(dd(3).name, "ReadVariableNames", false, "Delimiter", ',');
W.Test = QC_flag_stastics(wave_data, 'Xingda', p_data, 'TestingItem', 'Wave');

W.wave_datetime = datetime(wave_data.Var1, "InputFormat", "yyyy MM dd HH mm SS");
W.waveday = datenum(W.wave_datetime);
W.Hs = wave_data.Var3;
W.Tp = wave_data.Var5;
W.MDir = wave_data.Var7;
% W.Hs = wave_data.Var6;
% W.H_1_3 = wave_data.Var7;
% W.H_1_10 = wave_data.Var8;
% W.H_max = wave_data.Var9;
% W.H_mean = wave_data.Var10;
% W.T_mean = wave_data.Var11;
dfile = readtable('C:\Users\adm\Desktop\Xingda\2026\0418_0606\Data\11504-06-wave_current-forLiu.csv', 'ReadVariableNames', false);
W.Tmean = dfile.Var11(1:end-1);
% W.Tp = wave_data.Var12;
% W.T_1_3 = wave_data.Var13;
% W.T_1_10 = wave_data.Var14;
% W.T_max = wave_data.Var15;
% W.Dir_Tp = wave_data.Var16;
% W.Dir_mean = wave_data.Var17;
% W.Pressure = wave_data.Var18;
% W.speed = wave_data.Var19;
% W.Dir = wave_data.Var20;

% ================================ Current ================================
cur_data = readtable(dd(1).name, "ReadVariableNames", false, "Delimiter", ',');
C.Test = QC_flag_stastics(cur_data, 'Xingda', p_data, 'TestingItem', 'Current');

% dday_datetime = datetime(cur_data.Var1, 'InputFormat', 'MM/dd/uuuu HH:mm:ss');
% C.dday = datenum(dday_datetime);
% C.Pressure = cur_data.Var2;
% C.Temp = cur_data.Var3;
% C.u = table2array(cur_data(:, 4:2:end));
% C.v = table2array(cur_data(:, 5:2:end));
C.cur_datetime = datetime(cur_data.Var1, 'InputFormat', 'yyyy MM dd HH mm SS');
C.dday = datenum(C.cur_datetime);
C.Cur = table2array(cur_data(:, 3:4:end));
C.Dir = table2array(cur_data(:, 5:4:end));
C.u = C.Cur.*sind(C.Dir);
C.v = C.Cur.*cosd(C.Dir);


% =============================== Sea level ===============================
tide_data = readtable(dd(2).name, "ReadVariableNames", false, "Delimiter", ',');
T.Test = QC_flag_stastics(tide_data, 'Xingda', p_data, 'TestingItem', 'Sealevel');
T.tide_datetime = datetime(tide_data.Var1, 'InputFormat', 'yyyy MM dd HH mm SS');
T.SL = tide_data.Var3;

%% wind
% downloading data by webside "CODiS" (https://codis.cwa.gov.tw/Login?locale=zh-TW)
cd([main_folder,'\wind'])
winddata = readmatrix('lotsDataReports.txt'); % reading data as a matrix
[nicewind] = find(~isnan(winddata(:,1))); % sometimes the data has NaN values when your original data has ENGLISH and NUMBERS at the same time

% judging if the data has NaN value
if any(isnan(winddata(:,1)))
    WIND.wi = winddata;
else
    WIND.wi = winddata(nicewind,1:width(winddata));
end

wind_st = find(WIND.wi(:,2)==str2double(datestr(C.dday(1), 'yyyymmddHH'))); % start of wind data

% judging if the data has NaN value again
if any(isnan(WIND.wi(:,7)))
    WIND.wu=-WIND.wi(wind_st:length(C.dday(1:6:end))+wind_st-1,4).*sind(WIND.wi(wind_st:length(C.dday(1:6:end))+wind_st-1,5)); % U分量 風為來向加負號變去向
    WIND.wv=-WIND.wi(wind_st:length(C.dday(1:6:end))+wind_st-1,4).*cosd(WIND.wi(wind_st:length(C.dday(1:6:end))+wind_st-1,5)); % V分量 風為來向加負號變去向
    WIND.rain = WIND.wi(wind_st:length(C.dday(1:6:end))+wind_st-1,6); % rainfall of the weather station
    WIND.atm_st = WIND.wi(wind_st:length(C.dday(1:6:end))+wind_st-1,3); % atmospheric pressure of the station
    WIND.atm_sea = [];
else
    WIND.wu=-WIND.wi(wind_st:length(C.dday(1:6:end))+wind_st-1,5).*sind(WIND.wi(wind_st:length(C.dday(1:6:end))+wind_st-1,6)); % U分量 風為來向加負號變去向
    WIND.wv=-WIND.wi(wind_st:length(C.dday(1:6:end))+wind_st-1,5).*cosd(WIND.wi(wind_st:length(C.dday(1:6:end))+wind_st-1,6)); % V分量 風為來向加負號變去向
    WIND.rain = WIND.wi(wind_st:length(C.dday(1:6:end))+wind_st-1,7);
    WIND.atm_st = WIND.wi(wind_st:length(C.dday(1:6:end))+wind_st-1,3);
    WIND.atm_sea = WIND.wi(wind_st:length(C.dday(1:6:end))+wind_st-1,4); % atmospheric pressure of the nearest sea
end


%% Save data
save C:\Users\adm\Desktop\Xingda\2026\0418_0606\PROCESSED_DATA.mat C W T WIND






