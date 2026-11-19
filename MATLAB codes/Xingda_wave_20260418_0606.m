%% Xingda Harbor
% 0418-0606
% 20260813 edited
% 20261104 edited
clear; close all; clc; 

%% Path
main_folder = 'C:\Users\adm\Desktop\Xingda\2026\0418_0606';
cd(main_folder)
pic_c = [main_folder, '\picture\current'];
pic_w = [main_folder, '\picture\wave'];
p_data = [main_folder, '\processed_data'];
if ~isfolder(pic_c)
    mkdir(pic_c)
end
if ~isfolder(pic_w)
    mkdir(pic_w)
end

%% Figure setting
figset_linefont = @(ax) set(ax, 'fontsize', 14, 'linewidth', 1.5, "TickLength", [0.005 0.02], 'TickDir', 'out'); % setting of font size, frame line size, tick length and size
figset_date = @(ax, wave_day) set(ax, 'XTick', floor(wave_day(1)):4:ceil(wave_day(end)), ...
    'Xticklabel', datestr(floor(wave_day(1)):4:ceil(wave_day(end)), 'mm/dd')); % Major ticks which means 4 days
figset_date_minorticks = @(ax, wave_day) set(ax.XAxis, 'Minortick', 'on', 'MinorTickValues', floor(wave_day(1)):1:ceil(wave_day(end))); % Minor ticks which means one day

%% Load data
% load([main_folder, '\PROCESSED_DATA.mat'])
load([main_folder, '\PROCESSED_DATA_WAVE.mat'])
plotdate_all = sprintf('%s~%s', datestr(Wave.filled_time(1), 'yyyy/mm/dd'), datestr(Wave.filled_time(end), 'mm/dd'));
filedate = sprintf('%s_%s', datestr(Wave.filled_time(1), 'yyyymmdd'), datestr(Wave.filled_time(end), 'mmdd'));
item_str = ["Hs", "Tmean", "Tp", "Dir"];

directions_str = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", ...
    "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];
Hs_interval = [0, .1, .2, .6, 1:7, 9, 11.5, 14:2:20, 25, 30, 40];
T_interval = [0, 3:10, 12, 16, 20, 40, 60];

Hs_interval_str = set_interval_str(Hs_interval, "m");
T_interval_str = set_interval_str(T_interval, "s");
T_interval_str = replace(string(T_interval_str), ".0", "");

Hs = Wave.QC.Hs;
Tmean = Wave.QC.Tmean;
Tp = Wave.QC.Tp;
Dir = Wave.QC.Dir;

Hs_QCyet = Wave.with_nan_data.Hs;
Tmean_QCyet = Wave.with_nan_data.Tmean;
Tp_QCyet = Wave.with_nan_data.Tp;
Dir_QCyet = Wave.with_nan_data.Dir;

output_folder = p_data;

for ii = 2:length(item_str)

    output_name = sprintf("%s_Hs_%s.csv", filedate, item_str{ii});

    if strcmpi(item_str{ii}, "Dir")
        percent_table = Vanalyis_Hsdir(Hs, Dir, Hs_interval);
        percent_table = percent_table';
        pct.((item_str{ii})) = percent_table;

        [Hs_max, Hs_max_idx] = max(Hs, [], "omitmissing");
        dir_max = Dir(Hs_max_idx);
        Hs_mean = mean(Hs, "omitmissing");
        dir_mean = mean(Dir, "omitmissing");
        dir_main = find_main_direction(Dir);
        
        num_cols = size(percent_table, 2);
        val_format = [repmat(',%.2f', 1, num_cols)];
    
        fid = fopen(fullfile(output_folder, output_name), "w", "n", "UTF-8");
        % fprintf(fid, ',%s,Total (%%)\n', strjoin(string(Hs_interval_str), ','));
        fprintf(fid, ',%s,Total (%%)\n', strjoin(string(directions_str), ','));
        % for jj = 1:length(directions_str)
        for jj = 1:length(Hs_interval_str)
            % fprintf(fid, ['%s', val_format], directions_str{jj}, percent_table(jj, :));
            fprintf(fid, ['%s', val_format], Hs_interval_str{jj}, percent_table(jj, :));
            fprintf(fid, "\n");
        end
        fprintf(fid, ['Total (%%)', val_format], percent_table(end, :));
    
        fprintf(fid, "\nTotal mean of Hs = %.2f m\n", Hs_mean);
        fprintf(fid, "Total mean of direction = %.2f degree\n", dir_mean);
        fprintf(fid, "Maximum value of Hs = %.2f m\n", Hs_max);
        fprintf(fid, "Direction of maximum value of Hs = %.2f m\n", dir_max);
    
        fclose(fid);
    else
        ipt2 = Wave.QC.((item_str{ii}));
        percent_table = Vanalyis_HsT(Hs, ipt2, Hs_interval, T_interval);
        percent_table = percent_table';
        pct.((item_str{ii})) = percent_table;

        [Hs_max, Hs_max_idx] = max(Hs, [], "omitmissing");
        ipt_max = ipt2(Hs_max_idx);
        Hs_mean = mean(Hs, "omitmissing");
        ipt_mean = mean(ipt2, "omitmissing");
                
        num_cols = size(percent_table, 2);
        val_format = [repmat(',%.2f', 1, num_cols)];
    
        fid = fopen(fullfile(output_folder, output_name), "w", "n", "UTF-8");
        % fprintf(fid, ',%s,Total (%%)\n', strjoin(string(Hs_interval_str), ','));
        fprintf(fid, ',%s,Total (%%)\n', strjoin(string(T_interval_str), ','));
        % for jj = 1:length(directions_str)
        for jj = 1:length(Hs_interval_str)
            % fprintf(fid, ['%s', val_format], directions_str{jj}, percent_table(jj, :));
            fprintf(fid, ['%s', val_format], Hs_interval_str{jj}, percent_table(jj, :));
            fprintf(fid, "\n");
        end
        fprintf(fid, ['Total (%%)', val_format], percent_table(end, :));
    
        fprintf(fid, "\nTotal mean of Hs = %.2f m\n", Hs_mean);
        fprintf(fid, "Total mean of %s = %.2f degree\n", item_str{ii}, ipt_mean);
        fprintf(fid, "Maximum value of Hs = %.2f m\n", Hs_max);
        fprintf(fid, "Direction of maximum value of %s = %.2f m\n", item_str{ii}, ipt_max);
    
        fclose(fid);
    end

end

output_name = sprintf("%s_Hs_statistics.csv", filedate);
[Hs_max, Hs_max_idx] = max(Hs, [], "omitmissing");
dir_max = Dir(Hs_max_idx);
dir_max_str = find_main_direction(dir_max);
Tp_max = Tp(Hs_max_idx);
dday_max = datestr(Wave.Hs_time(Hs_max_idx), "yyyy/mm/dd HH:MM:SS");

[Hs_sort, Hs_sort_idx] = sort(Hs, "descend", "MissingPlacement", "last");
Tp_sort = Tp(Hs_sort_idx);

idx1_3 = 1:round(length(Hs)/3);
Hs1_3 = mean(Hs_sort(idx1_3), "all", "omitmissing");
Tp1_3 = mean(Tp_sort(idx1_3), "all", "omitmissing");

idx1_10 = 1:round(length(Hs)/10);
Hs1_10 = mean(Hs_sort(idx1_10), "all", "omitmissing");
Tp1_10 = mean(Tp_sort(idx1_10), "all", "omitmissing");

Hs_mean = mean(Hs, "omitmissing");
Tp_mean = mean(Tp, "omitmissing");
dir_mean = mean(Dir, "omitmissing");
[dir_main, dir_perc] = find_main_direction(Dir);

fid = fopen(fullfile(output_folder, output_name), "w", "n", "UTF-8");
fprintf(fid, "statistics items,value\n");
fprintf(fid, "H 1/10,%.3f\n", Hs1_10);
fprintf(fid, "Tp 1/10,%.1f\n", Tp1_10);
fprintf(fid, "H 1/3,%.3f\n", Hs1_3);
fprintf(fid, "Tp 1/3,%.1f\n", Tp1_3);
fprintf(fid, "H mean,%.3f\n", Hs_mean);
fprintf(fid, "Tp mean,%.1f\n", Tp_mean);
fprintf(fid, "Dir main,%s\n", dir_main);
fprintf(fid, "Hs max,%.3f\n", Hs_max);
fprintf(fid, "Dir_Hsmax,%s\n", dir_max_str);
fprintf(fid, "Tp_Hsmax,%.1f\n", Tp_max);
fprintf(fid, "Time_Hsmax,%s\n", dday_max);
fclose(fid);


%% Bar 
% for ii = 2:length(item_str)
Hs_total_percentage = percent_table(1:end-1, end);
Tmean_total_percentage = pct.Tmean(end, 1:end-1);
Tp_total_percentage = pct.Tp(end, 1:end-1);
dir_total_percentage = pct.Dir(end, 1:end-1);
% dir_total_percentage = percent_table(end, 1:end-1);
fig = figure("OuterPosition", [1 1 1000 1080]);
tiledlayout(4, 1, "TileSpacing", "compact", "Padding", "tight");
ax = nexttile;
b = bar(directions_str, dir_total_percentage, 'FaceColor', [.5, .5, .5]);
ylabel("(%)")
% title(ax, "wave direction")
xlabel(ax, "wave direction")
figset_linefont(ax)
ylim([0 ceil(max(dir_total_percentage)/5)*5])
grid on


ax = nexttile;
bar(replace(string(Hs_interval_str), [".0", "m"], ""), Hs_total_percentage, 'FaceColor', [.5, .5, .5])
ylabel("(%)")
% title(ax, "wave height")
xlabel(ax, "Hs (m)")
figset_linefont(ax)
ylim([0 ceil(max(Hs_total_percentage)/5)*5])
grid on


ax = nexttile;
bar(replace(string(T_interval_str), [".0", "s"], ""), Tp_total_percentage, 'FaceColor', [.5, .5, .5])
ylabel("(%)")
% title(ax, "Tp (sec)")
xlabel(ax, "Tp (sec)")
figset_linefont(ax)
ylim([0 ceil(max(Tp_total_percentage)/5)*5])
grid on


ax = nexttile;
bar(replace(string(T_interval_str), [".0", "s"], ""), Tmean_total_percentage, 'FaceColor', [.5, .5, .5])
ylabel("(%)")
% title(ax, "Tmean (sec)")
xlabel(ax, "Tmean (sec)")
figset_linefont(ax)
ylim([0 ceil(max(Tmean_total_percentage)/5)*5])
grid on

saving_str = sprintf("%s_wave_statistics_bar.png", filedate);
exportgraphics(fig, fullfile(pic_w, saving_str))
% end


%% Joint probability
Hs_total_percentage = percent_table(1:end-1, end);
Tmean_total_percentage = pct.Tmean(end, 1:end-1);
Tp_total_percentage = pct.Tp(end, 1:end-1);
dir_total_percentage = pct.Dir(end, 1:end-1);

for ii = 2:length(item_str)
    switch ii
        case 4
            ipt_str = directions_str;
            ipt_tbl = pct.Dir;
            x_data = 1:length(dir_total_percentage);
            xlabel_str = "direction";
        case 2
            ipt_str = replace(string(T_interval_str), [".0", "s"], "");
            ipt_tbl = pct.Tmean;
            x_data = 1:length(Tmean_total_percentage);
            xlabel_str = "Tmean (sec)";
        case 3
            ipt_str = replace(string(T_interval_str), [".0", "s"], "");
            ipt_tbl = pct.Tp;
            x_data = 1:length(Tp_total_percentage);
            xlabel_str = "Tp (sec)";
    end
    fig = figure("OuterPosition", [1 1 900 600]);
    tiledlayout(1, 1, "TileSpacing", "compact", "Padding", "tight");
    ax = nexttile;
    contourf(x_data, 1:length(Hs_total_percentage), ipt_tbl(1:end-1, 1:end-1), 0:20,'LineStyle', 'none')
    shading interp
    colormap(flipud(gray(64)))
    set(ax, "Xtick", x_data, "Xticklabels", ipt_str)
    set(ax, "Ytick", 1:length(Hs_total_percentage), "Yticklabels", replace(string(Hs_interval_str), [".0", " m"], ""))
    clbr = colorbar;
    clbr.Label.String = "(%)";
    xlabel(ax, xlabel_str)
    ylabel(ax, "Hs (m)")
    figset_linefont(ax)
    
    saving_str = sprintf("%s_Hs_%s_statistics_joint_probability.png", filedate, item_str(ii));
    exportgraphics(fig, fullfile(pic_w, saving_str))
end

%% Plot
fig = figure("OuterPosition", [1 1 1920/2, 1080]);
tt = tiledlayout(4, 1, "TileSpacing", "compact", "Padding", "tight");
for ii = 1:length(item_str)-1
    ax = nexttile;
    dday = datenum(Wave.((item_str{ii} + "_time")));
    % dday = datenum(Wave.filled_time);
    ipt_QCyet = Wave.with_nan_data.((item_str{ii}));
    ipt_QC = Wave.QC.((item_str{ii}));
    % plot(dday, ipt_QCyet, "Color", "r", "LineWidth", 2, "DisplayName", "Fail"); hold on
    plot(dday, ipt_QC, "Color", "k", "LineWidth", 2, "DisplayName", "Pass");
    % idx_flag3 = find(Wave.((item_str{ii} + "flags_total")) == 3);
    % plot(dday(idx_flag3), ipt_QC(idx_flag3), '.', "Color", "#FFD306", "MarkerSize", 10, "DisplayName", "Suspect")
    if ii == 1
        % legend("Box", "on", "NumColumns", 3, "Location", "northeast");
        % lgd_pos = ax.Legend.Position;
        % lgd_pos(1) = lgd_pos(1) - 0.01; % 數值調大 = 往右移
        % lgd_pos(2) = lgd_pos(2) + 0.01; % 數值調小 = 往下移
        % ax.Legend.Position = lgd_pos;
        ylabel("(m)")
    else
        ylabel("(sec)")
    end
    grid on
    title(ax, sprintf("%s", item_str{ii}))
    figset_linefont(ax)
    figset_date(ax, dday)
    figset_date_minorticks(ax, dday)
end

ii = 4;
ax = nexttile;
dday = datenum(Wave.(("Dir" + "_time")));
% dday = datenum(Wave.filled_time);
ipt_QCyet = Wave.with_nan_data.((item_str{ii}));
ipt_QC = Wave.QC.((item_str{ii}));
% plot(dday, ipt_QCyet, ".", "Color", "r", "LineWidth", 2, "DisplayName", "Fail", "MarkerSize", 10); hold on
plot(dday, ipt_QC, ".", "Color", "k", "LineWidth", 2, "DisplayName", "Pass", "MarkerSize", 10);
% idx_flag3 = find(Wave.(("Dir" + "flags_total")) == 3 | Wave.(("Hs" + "flags_total")) == 3);
% plot(dday(idx_flag3), ipt_QC(idx_flag3), '.', "Color", "#FFD306", "MarkerSize", 10, "DisplayName", "Suspect")
ylabel("(degree)")
ylim([0 360])
set(ax, "YTick", 0:90:360)
grid on
title(ax, sprintf("%s", item_str{ii}))
figset_linefont(ax)
figset_date(ax, dday)
figset_date_minorticks(ax, dday)

saving_str = sprintf("%s_Hs.png", filedate);
exportgraphics(fig, fullfile(pic_w, saving_str))

%% 
% for ii = 2:length(item_str)
    fig = figure();
    tiledlayout(1, 1, "TileSpacing", "compact", "Padding", "tight");
    % title_str = sprintf("N %s (%.1f mab)", layer_str, ii+1.4);
    % title_str = sprintf("%s", replace(layer_str(ii), "Layer", " Layer"));
    title_str = sprintf("Hs & Dir");
    ax = nexttile;
    clear Options % 清除舊變數確保乾淨
    Options.nDirections     = 16;
    Options.AngleNorth      = 0;
    Options.AngleEast       = 90;
    Options.labels          = {'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'};
    Options.gridstyle       = ':';
    Options.radialgridstyle = ':';
    Options.gridcolor       = 'k';
    Options.gridwidth       = 1.2;
    Options.gridalpha       = 0.5;
    Options.nfreq           = 5;
    Options.FreqLabelAngle  = 45;
    Options.zeroAndNegative = true;
    Options.cMap            = flipud(gray(64)); 
    Options.vWinds          = 0:.25:1;
    Options.LabLegend       = 'Hs in m';
    Options.LegendVariable  = 'Hs';
    Options.scalefactor     = 0.9;
    Options.TitleString     = title_str;
    Options.axes            = ax;
    Options.figcolor        = 'w';
    
    valid_idx = ~isnan(Dir) & ~isnan(Hs);
    Rose_dir = Dir(valid_idx);
    Rose_WS = Hs(valid_idx);
    [~, Dir_stas] = find_main_direction(Rose_dir);
    Options.MaxFrequency    = ceil(max(Dir_stas)/numel(Rose_dir)*100/10)*10;
    % fprintf('原始資料筆數: %d, 過濾後剩餘筆數: %d %d\n', length(N.Cur.Dir), length(Rose_dir), length(Rose_WS));
    WindRose(Rose_dir, Rose_WS, Options);
    figset_linefont(ax)
    set(ax.Legend, 'Location', 'southeast', 'Box', 'off', 'fontsize', 8, 'ItemTokenSize', [12, 6])
    lgd_pos = ax.Legend.Position;
    lgd_pos(1) = lgd_pos(1) + 0.16; % 數值調大 = 往右移
    lgd_pos(2) = lgd_pos(2) - 0.03; % 數值調小 = 往下移
    ax.Legend.Position = lgd_pos;
    set(ax, 'TitleHorizontalAlignment', 'left')
    all_text = findall(ax, 'Type', 'text');
    for jj = 1:length(all_text)
        txt_str = all_text(jj).String;
        
        % 如果文字中包含 '%'，代表它是頻率標籤
        if contains(txt_str, '%')
            set(all_text(jj), ...
                'HorizontalAlignment', 'center', ...   % 水平對齊：left, center, right
                'VerticalAlignment', 'bottom', ...   % 垂直對齊：top, middle, bottom
                'FontSize', 10, ...                  % 字體大小
                'FontWeight', 'bold', ...            % 加粗
                'Color', [0.2 0.2 0.2], ...          % 深灰色
                'FontName', 'Helvetica');            % 字體名稱
                
            % 如果你想讓文字稍微「位移」一點點，不要貼在線上面：
            % pos = all_text(i).Position;
            % all_text(i).Position = pos + [0.5 0 0]; % 往右位移 0.5 單位
        end
    end

    saving_str = sprintf("%s_HsDirRose.png", filedate);
    exportgraphics(fig, fullfile(pic_w, saving_str))



    
% end




% station = 'Xingda';

% ww = readtable([main_folder, '\Data\11504-06-wave_current-forLiu.csv'], 'ReadVariableNames', false);
% W.T = ww.Var11;
% 
% % ============================= QC_Data ==============================
% waveday = nan(W.Test(1).all_data, 1); waveday(W.Test(1).pass) = W.waveday(W.Test(1).pass);
% ig = find(isnan(waveday));
% Hs = nan(W.Test(1).all_data, 1); Hs(W.Test(2).pass) = W.Hs(W.Test(2).pass);
% Hs_sus = nan(W.Test(1).all_data, 1); Hs_sus(W.Test(2).suspect) = W.Hs(W.Test(2).suspect);
% Tp = nan(W.Test(1).all_data, 1); Tp(W.Test(3).pass) = W.Tp(W.Test(3).pass);
% Tp_sus = nan(W.Test(1).all_data, 1); Tp_sus(W.Test(3).suspect) = W.Tp(W.Test(3).suspect);
% % Tmean = nan(W.Test(1).all_data, 1); Tmean(W.Test(2).pass) = W.T(W.Test(2).pass);
% MDir = nan(W.Test(1).all_data, 1); MDir(W.Test(4).pass) = W.MDir(W.Test(4).pass);
% MDir_sus = nan(W.Test(1).all_data, 1); MDir_sus(W.Test(4).suspect) = W.MDir(W.Test(4).suspect);
% 
% Hs(ig) = nan;
% Tp(ig) = nan;
% MDir(ig) = nan;
% 
% SL = nan(T.Test(1).all_data, 1); SL(T.Test(2).pass) = T.SL(T.Test(2).pass);
% 
% passing_percentage.waveday = length(W.Test(1).pass)/W.Test(1).all_data*100;
% passing_percentage.Hs = length(W.Test(2).pass)/W.Test(1).all_data*100;
% passing_percentage.Tp = length(W.Test(3).pass)/W.Test(1).all_data*100;
% passing_percentage.MDir = length(W.Test(4).pass)/W.Test(1).all_data*100;
% passing_percentage.SL = length(T.Test(2).pass)/T.Test(1).all_data*100;

%{
%% 
figure("OuterPosition", [1 1 1920 1080])
tt = tiledlayout(4, 1, "TileSpacing", "compact", "Padding", "tight");
ax = nexttile;
plot(C.dday, T.SL, 'r', 'LineWidth', 2); hold on
plot(C.dday, SL, 'b', 'LineWidth', 2)
grid on
ylabel('Sealevel (m)')
figset_linefont(ax)
figset_date(ax, C.dday)
figset_date_minorticks(ax, C.dday)
title_txt = sprintf('Sealevel, passing rate: %.2f%%', passing_percentage.SL);
title(ax, title_txt, 'FontSize', 20)

ax = nexttile;
plot(W.waveday, W.Hs, 'r', 'LineWidth', 2, 'DisplayName', 'Data_{Raw}'); hold on
plot(W.waveday, Hs, 'b', 'LineWidth', 2, 'DisplayName', 'Data_{QC}')
scatter(waveday, Hs_sus, 'g', 'filled', 'DisplayName', 'Data_{Sus}')
grid on
ylabel('Hs (m)')
legend('Box', 'off', 'Location', 'north', 'NumColumns', 3)
figset_linefont(ax)
figset_date(ax, W.waveday)
figset_date_minorticks(ax, W.waveday)
title_txt = sprintf('Wave height, passing rate: %.2f%%', passing_percentage.Hs);
title(ax, title_txt, 'FontSize', 20)


ax = nexttile;
plot(W.waveday, W.Tp, 'r', 'LineWidth', 2, 'DisplayName', 'Data_{Raw}'); hold on
plot(W.waveday, Tp, 'b', 'LineWidth', 2, 'DisplayName', 'Data_{QC}')
scatter(waveday, Tp_sus, 'g', 'filled', 'DisplayName', 'Data_{Sus}')
grid on
ylabel('Tp (s)')
legend('Box', 'off', 'Location', 'north', 'NumColumns', 3)
figset_linefont(ax)
figset_date(ax, W.waveday)
figset_date_minorticks(ax, W.waveday)
title_txt = sprintf('Tp, passing rate: %.2f%%', passing_percentage.Tp);
title(ax, title_txt, 'FontSize', 20)



ax = nexttile;
scatter(W.waveday, W.MDir, 'red','filled' ,'LineWidth', 2, 'DisplayName', 'Data_{Raw}'); hold on
scatter(W.waveday, MDir, 'b','filled', 'LineWidth', 2, 'DisplayName', 'Data_{QC}')
scatter(waveday, MDir_sus, 'g', 'filled', 'DisplayName', 'Data_{Sus}')
grid on
ylim([0 360])
set(ax, 'ytick', 0:90:360)
ylabel('Dir._{mean} (^\circ)')
% legend('Box', 'off', 'Location', 'north', 'NumColumns', 3)
figset_linefont(ax)
figset_date(ax, W.waveday)
figset_date_minorticks(ax, W.waveday)
title_txt = sprintf('Wave direction, passing rate: %.2f%%', passing_percentage.MDir);
title(ax, title_txt, 'FontSize', 20)

file_txt = sprintf('%s\\%s_%s_wave.png', pic_w, filedate, station);
exportgraphics(gcf, file_txt)


%% 
% cd(func)
file_txt = sprintf('%s_%s_Wave_height_Hs_Tp_Dir.txt', filedate, station);
[~,percentHsDir] = Vanalyis_wave_QM(Hs,Tp,MDir,waveday,file_txt,p_data);
edges=0:.10:3.5;
T_range=0:1:10;

%% 繪製長條圖 Histogram
%====================== N station
figure('outerposition',get(0,'screensize')); % 全螢幕 Full screen Picture
tt = tiledlayout(1,2,"TileSpacing","compact","Padding","tight");
ax1 = nexttile;
h = histogram(Hs,edges,'Normalization','probability','FaceColor','k');
text(2, .23, {'\bfHs (Mean)', [' = ',num2str(mean(Hs, 'omitmissing'), '%1.2f'),' m']}, 'FontSize',36)
text(2, .14, {'\bfHs (Max)', [' = ',num2str(max(Hs), '%1.2f'),' m']}, 'FontSize',36)
text(2, .05, {'\bfpassing rate:', [num2str(passing_percentage.Hs, '%.2f'), '%']}, 'FontSize',36)
% h.Values = h.Values*100;
axis([00 3.5 0 0.3]);
set(gca,'xtick',0:.5:3.5,'linewidth',3,'FontWeight','bold','fontsize',18, ...
    'ytick',0:0.02:0.3,'yticklabel',num2str((0:2:30)'), ...
    'TickDir', 'out')
ax1.YAxis.MinorTick = 'on';
ax1.YAxis.MinorTickValues = 0:0.01:.3;
ax1.XAxis.MinorTick = 'on';
ax1.XAxis.MinorTickValues = 0:0.1:3.5;
ylabel('\it\bfProbability (%)','FontName','Times new Roman', 'fontsize', 30);
xlabel('\it\bfH_{m0} (m)','FontName','Times new Roman', 'fontsize', 30);


ax2 = nexttile;
h = histogram(Tp,T_range,'Normalization','probability','FaceColor','k');
% text(6.5, .45, {'\bfT_{\itm02} (Mean)', [' = ',num2str(mean(Tp, 'omitmissing'), '%1.2f'),' sec']}, 'FontSize',36)
% text(6.5, .30, {'\bfT_{\itm02} (Max)', [' = ',num2str(max(Tp), '%1.2f'),' sec']}, 'FontSize',36)
text(1.5, .60, {'\bfTp (Mean)', [' = ',num2str(mean(Tp, 'omitmissing'), '%1.2f'),' sec']}, 'FontSize',36)
text(1.5, .45, {'\bfTp (Max)', [' = ',num2str(max(Tp), '%1.2f'),' sec']}, 'FontSize',36)
text(1.5, .30, {'\bfpassing rate:', [num2str(passing_percentage.Tp, '%.2f'), '%']}, 'FontSize',36)
% h.Values = h.Values*100;
axis([00 10 0 0.7]);
set(gca,'xtick',0:1:10,'linewidth',3,'FontWeight','bold','fontsize',18, ...
    'ytick',0:0.1:0.6,'yticklabel',num2str((0:10:60)'), ...
    'TickDir', 'out')
ax2.YAxis.MinorTick = 'on';
ax2.YAxis.MinorTickValues = 0:0.05:.7;
ax2.XAxis.MinorTick = 'on';
ax2.XAxis.MinorTickValues = 0:0.5:10;
ylabel('\it\bfProbability (%)','FontName','Times new Roman', 'fontsize', 30);
xlabel('\it\bfTp (s)','FontName','Times new Roman', 'fontsize', 30);

cd(pic_w)
exportgraphics(gcf,[filedate,'_', station, '_Hs_T_Histogram.png'])

%% Wave Rose
% cd(func)
figure("OuterPosition", [1 1 1920 1080])
tt = tiledlayout(1,1,"TileSpacing","compact","Padding","compact");
ax = nexttile;
[figure_handle] = WindRose(MDir, Hs, ...
    'nDirections', 16, ...
    'gridstyle', ':', ...
    'gridcolor', 'k', ...
    'gridwidth', 2, ...
    'gridalpha', 0.5, ...
    'labels', {'N','NNE','NE','ENE','E','ESE','SE','SSE','S','SSW','SW','WSW','W','WNW','NW','NNW'}, ...
    'cMap', 'invgray', ...
    'vWinds',[0:.5:2,3.5], ...
    'LabLegend', 'Hs in m', ...
    'LegendVariable', 'Hs' , ...
    'zeroAndNegative', true, ...
    'MaxFrequency', 80, ...
    'FreqLabelAngle', 'auto', ...
    'AngleNorth', 0, ...
    'AngleEast', 90, ...
    'axes', gca, ...
    'CirFontsize', 24, ...
    'FreqFontsize', 30, ...
    'titlestring', []);
[~,loc_maxHs] = max(Hs);
text(1, 1, ['最大波高：', num2str(max(Hs), '%.2f'), ' m'], ...
    'fontsize', 30, 'FontWeight','bold', 'FontName', '標楷體', 'Color', 'b')
text(1, .9, ['對應流向：', num2str(MDir(loc_maxHs), '%.1f'), '^\circ'], ...
    'fontsize', 30, 'FontWeight','bold', 'FontName', '標楷體', 'Color', 'b')
text(1, .8, ['對應尖峰週期：', num2str(Tp(loc_maxHs), '%.2f'), ' sec'], ...
    'fontsize', 30, 'FontWeight','bold', 'FontName', '標楷體', 'Color', 'b')
set(ax, 'fontsize', 20)
lgd = legend;
ax.Legend.Location = 'eastoutside';
cd(pic_w)
file_txt = sprintf('%s\\%s_%s_Wave_Rose.png', pic_w, filedate, station);
exportgraphics(gcf, file_txt)


%% Prob Diagram
load("redblue.mat")
Waveheight=0:.1:3.4;
Trange=0:2:20;
percentHsT = zeros(10, 17);

% ============= Hs X T ==============
for i=2:1:34
    for j=1:1:10
        g=find(Hs>=Waveheight(i-1) & Hs<Waveheight(i) & Tp>=Trange(j) & Tp<Trange(j+1));
        percentHsT(j,i-1)=length(g);     %bivariate statistics
    end
end

percentHsT = 100*percentHsT/length(Hs);
grayblack = gray;
[max_value, loc_maxProb_y] = max(percentHsT);
[~,loc_maxProb_x] = max(max_value);

figure("OuterPosition", [1 1 1920 1080])
tiledlayout(1,1,"TileSpacing","compact","Padding","tight")
ax1 = nexttile;
c1 = contourf(Waveheight(1:end-2), Trange(1:end-1), percentHsT, -5:.05:20, 'LineStyle','none'); hold on
colormap([1 1 1; flipud(grayblack(1:240, :))])
contour(Waveheight(1:end-2), Trange(1:end-1), percentHsT, [0, 0.05], ...
    'EdgeColor', '#C4E1FF', 'ShowText', 'on', 'LineWidth', 1.5, 'LabelColor','#C4E1FF'); hold on
contour(Waveheight(1:end-2), Trange(1:end-1), percentHsT, [1, 2, 3, 4, 5], ...
    'EdgeColor', 'b', 'ShowText', 'on', 'LineWidth', 1.5, 'LabelColor','b'); hold on
contour(Waveheight(1:end-2), Trange(1:end-1), percentHsT, 6:2:20, ...
    'EdgeColor', 'm', 'ShowText', 'on', 'LineWidth', 1.5, 'LabelColor','m'); hold on
text(.1, .9, '發生機率 (%)', 'FontSize', 30, 'FontName', '標楷體', 'Units', 'normalized')
text(.1, .7, ['Max Probability：',num2str(max(max_value), '%2.1f'), '%'], ...
    'fontsize', 30, 'Color', 'm', 'fontname', '標楷體', 'Units', 'normalized')
axis([0 3.4 0 18])
shading interp
ylabel({'週 ', '期 ', '(秒)'}, 'Rotation', 0, 'fontsize', 24)
xlabel('波 高 (m)')
set(ax1, 'TickDir', 'out', 'fontname', '標楷體', 'fontsize', 18, ...
    'xtick', 0:0.2:3.4, 'linewidth', 2, 'ticklength', [.005 .005], 'ytick', 0:2:20)

cd(pic_w)
exportgraphics(gcf, [filedate, station, '_Hs_T_jointprobability_distribution_table.png'])
%}