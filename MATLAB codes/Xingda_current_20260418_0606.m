%% Xingda Harbor
% 0418-0606
% 20260811 edited
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
figset_linefont = @(ax) set(ax, 'fontsize', 12, 'linewidth', 1.5, "TickLength", [0.005 0.02], 'TickDir', 'out'); % setting of font size, frame line size, tick length and size
figset_date = @(ax, wave_day) set(ax, 'XTick', floor(wave_day(1)):4:ceil(wave_day(end)), ...
    'Xticklabel', datestr(floor(wave_day(1)):4:ceil(wave_day(end)), 'mm/dd')); % Major ticks which means 4 days
figset_date_minorticks = @(ax, wave_day) set(ax.XAxis, 'Minortick', 'on', 'MinorTickValues', floor(wave_day(1)):1:ceil(wave_day(end))); % Minor ticks which means one day

%% Load data
% load([main_folder, '\PROCESSED_DATA.mat'])
% plotdate_all = sprintf('%s~%s', datestr(C.dday(1), 'yyyy/mm/dd'), datestr(C.dday(end), 'mm/dd'));
% filedate = sprintf('%s_%s', datestr(C.dday(1), 'yyyymmdd'), datestr(C.dday(end), 'mmdd'));
load([main_folder, '\PROCESSED_DATA_CUR.mat'])
filled_time = Cur.filled_time;
plotdate_all = sprintf('%s~%s', datestr(filled_time(1), 'yyyy/mm/dd'), datestr(filled_time(end), 'mm/dd'));
filedate = sprintf('%s_%s', datestr(filled_time(1), 'yyyymmdd'), datestr(filled_time(end), 'mmdd'));

layer_str = ["BottomLayer", "MiddleLayer", "TopLayer"];

output_folder = p_data;

cur_interval = [0:5:50, 60:10:100, 120, 150];
Cur_interval_str = set_interval_str(cur_interval, "cm/s");
Cur_interval_str = replace(string(Cur_interval_str), ".0", "");
directions_str = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", ...
                                    "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];

for ii = 1:length(layer_str)

    output_name = sprintf("%s_%s_Cur_Dir.csv", filedate, layer_str{ii});
    Cur_speed = Cur.QC.((layer_str{ii}))*100;
    Cur_dir = Cur.QC.((layer_str{ii} + "_Dir"));
    % u = Cur.u(:, ii)*100;
    % v = Cur.v(:, ii)*100;
    u = Cur_speed.*sind(Cur_dir);
    v = Cur_speed.*cosd(Cur_dir);
    percent_table = Vanalyis_Hsdir(Cur_speed, Cur_dir, cur_interval);
    percent_table = percent_table';
    
    [cur_max, cur_max_idx] = max(Cur_speed, [], "omitmissing");
    dir_max = Cur_dir(cur_max_idx);
    cur_mean = mean(Cur_speed, "omitmissing");
    dir_mean = mean(Cur_dir, "omitmissing");
    dir_main = find_main_direction(Cur_dir);
    u_mean = mean(u, "omitmissing");
    v_mean = mean(v, "omitmissing");
    u_max = max(u, [], "omitmissing");
    v_max = max(v, [], "omitmissing");
    u_std = std(u, "omitmissing");
    v_std = std(v, "omitmissing");
    
    num_cols = size(percent_table, 2);
    val_format = [repmat(',%.2f', 1, num_cols)];

    fid = fopen(fullfile(output_folder, output_name), "w", "n", "UTF-8");
    % fprintf(fid, ',%s,Total (%%)\n', strjoin(string(Cur_interval_str), ','));
    fprintf(fid, ',%s,Total (%%)\n', strjoin(string(directions_str), ','));
    % for jj = 1:length(directions_str)
    for jj = 1:length(Cur_interval_str)
        % fprintf(fid, ['%s', val_format], directions_str{jj}, percent_table(jj, :));
        fprintf(fid, ['%s', val_format], Cur_interval_str{jj}, percent_table(jj, :));
        fprintf(fid, "\n");
    end
    fprintf(fid, ['Total (%%)', val_format], percent_table(end, :));

    fprintf(fid, "\nTotal mean of speed = %.2f cm/s\n", cur_mean);
    fprintf(fid, "Total mean of direction = %.2f degree\n", dir_mean);
    fprintf(fid, "Maximum value of speed = %.2f cm/s\n", cur_max);
    fprintf(fid, "Direction of maximum value of speed = %.2f cm/s\n", dir_max);
    fprintf(fid, "Mean U = %.2f cm/s\t\tMean V = %.2f cm/s\n", u_mean, v_mean);
    fprintf(fid, "Maximum U = %.2f cm/s\t\tMaximum V = %.2f cm/s\n", u_max, v_max);
    fprintf(fid, "Standard deviation of U = %.2f cm/s\n", u_std);
    fprintf(fid, "Standard deviation of V = %.2f cm/s\n", v_std);
    fclose(fid);

    cur_total_percentage = percent_table(1:end-1, end);
    dir_total_percentage = percent_table(end, 1:end-1);
    fig = figure("OuterPosition", [1 1 900 600]);
    tiledlayout(2, 1, "TileSpacing", "compact", "Padding", "tight");
    ax = nexttile;
    b = bar(directions_str, dir_total_percentage, 'FaceColor', [.5, .5, .5]);
    ylabel("(%)")
    % title(ax, "current direction")
    xlabel(ax, "current direction")
    title(ax, replace(layer_str{ii}, "Layer", " Layer"))
    figset_linefont(ax)
    ylim([0 ceil(max(dir_total_percentage)/5)*5])
    grid on
    
    
    ax = nexttile;
    bar(replace(string(Cur_interval_str), [".0", " cm/s"], ""), cur_total_percentage, 'FaceColor', [.5, .5, .5])
    ylabel("(%)")
    xlabel(ax, sprintf("current speed (cm s^{-1})"))
    
    figset_linefont(ax)
    ylim([0 ceil(max(cur_total_percentage)/5)*5])
    grid on
    
    saving_str = sprintf("%s_%s_current_statistics_bar.png", filedate, layer_str{ii});
    exportgraphics(fig, fullfile(pic_c, saving_str))


    fig = figure("OuterPosition", [1 1 800 600]);
    tiledlayout(1, 1, "TileSpacing", "compact", "Padding", "tight");
    ax = nexttile;
    contourf(1:length(dir_total_percentage), 1:length(cur_total_percentage), percent_table(1:end-1, 1:end-1), 0:.1:2,'LineStyle', 'none')
    shading interp
    colormap(flipud(gray(64)))
    set(ax, "Xtick", 1:length(dir_total_percentage), "Xticklabels", directions_str)
    set(ax, "Ytick", 1:length(cur_total_percentage), "Yticklabels", replace(string(Cur_interval_str), [".0", " cm/s"], ""))
    clbr = colorbar;
    clbr.Label.String = "(%)";
    xlabel(ax, "direction")
    ylabel(ax, "current speed (cm s^{-1})")
    title(ax, replace(layer_str{ii}, "Layer", " Layer"))
    figset_linefont(ax)
    
    saving_str = sprintf("%s_%s_current_statistics_joint_probability.png", filedate, layer_str{ii});
    exportgraphics(fig, fullfile(pic_c, saving_str))
end


% %% Bar 
% cur_total_percentage = percent_table(1:end-1, end);
% dir_total_percentage = percent_table(end, 1:end-1);
% fig = figure("OuterPosition", [1 1 900 600]);
% tiledlayout(2, 1, "TileSpacing", "compact", "Padding", "tight");
% ax = nexttile;
% b = bar(directions_str, dir_total_percentage, 'FaceColor', [.5, .5, .5]);
% ylabel("(%)")
% title(ax, "current direction")
% figset_linefont(ax)
% ylim([0 ceil(max(dir_total_percentage)/5)*5])
% grid on
% 
% 
% ax = nexttile;
% bar(replace(string(Cur_interval_str), [".0", " cm/s"], ""), cur_total_percentage, 'FaceColor', [.5, .5, .5])
% ylabel("(%)")
% title(ax, "current speed (cm s^{-1})")
% figset_linefont(ax)
% ylim([0 ceil(max(cur_total_percentage)/5)*5])
% grid on
% 
% saving_str = sprintf("%s_current_statistics_bar.png", filedate);
% exportgraphics(fig, fullfile(pic_c, saving_str))
% 
% %% Joint probability
% cur_total_percentage = percent_table(1:end-1, end);
% dir_total_percentage = percent_table(end, 1:end-1);
% fig = figure("OuterPosition", [1 1 800 600]);
% tiledlayout(1, 1, "TileSpacing", "compact", "Padding", "tight");
% ax = nexttile;
% contourf(1:length(dir_total_percentage), 1:length(cur_total_percentage), percent_table(1:end-1, 1:end-1), 0:.1:2,'LineStyle', 'none')
% shading interp
% colormap(flipud(gray(64)))
% set(ax, "Xtick", 1:length(dir_total_percentage), "Xticklabels", directions_str)
% set(ax, "Ytick", 1:length(cur_total_percentage), "Yticklabels", replace(string(Cur_interval_str), [".0", " cm/s"], ""))
% clbr = colorbar;
% clbr.Label.String = "(%)";
% xlabel(ax, "direction")
% ylabel(ax, "current speed (cm s^{-1})")
% figset_linefont(ax)
% 
% saving_str = sprintf("%s_current_statistics_joint_probability.png", filedate);
% exportgraphics(fig, fullfile(pic_c, saving_str))
% 
%% Statistics-for 3 layers
output_name = sprintf("%s_Cur_threelayers_statistics.csv", filedate);
fid = fopen(fullfile(output_folder, output_name), "w", "n", "UTF-8");
fprintf(fid, ",CSmax_time,CSmax,Dir_CSmax,CSmean,Dirmean,Dirmain\n");
for ii = length(layer_str):-1:1
    dday = datenum(Cur.((layer_str{ii} + "_time")));
    Cur_speed = Cur.QC.((layer_str{ii}))*100;
    Cur_dir = Cur.QC.((layer_str{ii} + "_Dir"));
    
    [cur_max, cur_max_idx] = max(Cur_speed, [], "omitmissing");
    dir_max = Cur_dir(cur_max_idx);
    dday_max = dday(cur_max_idx);
    cur_mean = mean(Cur_speed, "omitmissing");
    dir_mean = mean(Cur_dir, "omitmissing");
    dir_main = find_main_direction(Cur_dir);

    val_format = [repmat(',%.1f', 1, 4)];

    fprintf(fid, ['%s,%s', val_format, ',%s\n'], layer_str{ii}, datestr(dday_max, "mm/dd HH:MM:SS"), ...
        cur_max, dir_max, cur_mean, dir_mean, dir_main);
end

fclose(fid);

%% contourf profile
layer_str = ["BottomLayer", "MiddleLayer", "TopLayer"];

% for ii = 1:3
dday = datenum(Cur.((layer_str{ii} + "_time")));
u_prof = flipud(Cur.u_profile')*100;
v_prof = flipud(Cur.v_profile')*100;
depth = 3:14;
load("redblue.mat");
cclim = -100:10:100;

fig = figure("OuterPosition", [1 1 1000 600]);
tiledlayout(2, 1, "TileSpacing", "compact", "Padding", "tight");
ax = nexttile;
contourf(dday, depth, u_prof, cclim, "LineStyle", "none");
clim([cclim(1), cclim(end)])
colormap(redblue)
set(ax, "YDir", "reverse")
clbr = colorbar;
clbr.Label.String = "speed (cm/s)";
xlim([floor(dday(1)) ceil(dday(end))])
ylabel("depth (m)")
title(ax, "U")
figset_linefont(ax)
figset_date(ax, dday)
figset_date_minorticks(ax, dday)


ax = nexttile;
contourf(dday, depth, v_prof, cclim, "LineStyle", "none");
clim([cclim(1), cclim(end)])
colormap(redblue)
set(ax, "YDir", "reverse")
clbr = colorbar;
clbr.Label.String = "speed (cm/s)";
xlim([floor(dday(1)) ceil(dday(end))])
ylabel("depth (m)")

title(ax, "V")
figset_linefont(ax)
figset_date(ax, dday)
figset_date_minorticks(ax, dday)

xlabel("date (mm/dd)")
saving_str = sprintf("%s_current_profile.png", filedate);
exportgraphics(fig, fullfile(pic_c, saving_str))

% end
%% plot
fig = figure("OuterPosition", [1 1 1920/2 1080]);
tt = tiledlayout(7, 1, "TileSpacing", "compact", "Padding", "tight");
ax = nexttile; % the tile you plot
dday = datenum(Cur.SL_time);
% plot(dday, Cur.with_nan_data.SL, 'Color', 'r', 'LineWidth', 2, "DisplayName", "Fail"); hold on
plot(dday, Cur.QC.SL, 'Color', 'k', 'LineWidth', 2, "DisplayName", "Pass"); 
% idx_flag3 = find(Cur.SLflags_total == 3);
% plot(dday(idx_flag3), Cur.QC.SL(idx_flag3), '.', "Color", "#FFD306", "MarkerSize", 10, "DisplayName", "Suspect")
% if isempty(idx_flag3)
%     plot(1, 1, '.', "Color", "#FFD306", "MarkerSize", 10, "DisplayName", "Suspect")
% end
ylim([floor(min(Cur.QC.SL)*2)/2 ceil(max(Cur.QC.SL)*2)/2])
xlim([floor(dday(1)) ceil(dday(end))])
grid on
% legend("Box", "on", "NumColumns", 3, "Location", "northeast");
% lgd_pos = ax.Legend.Position;
% lgd_pos(1) = lgd_pos(1) + 0.16; % 數值調大 = 往右移
% lgd_pos(2) = lgd_pos(2) + 0.01; % 數值調小 = 往下移
% ax.Legend.Position = lgd_pos;
ylabel("(m)")
figset_linefont(ax)
figset_date(ax, dday)
figset_date_minorticks(ax, dday)
% set(ax, 'XTicklabels', [])
title(ax, "Sea Level")

for ii = length(layer_str):-1:1
    set(ax, "XTicklabels", [])
    ax = nexttile; % the tile you plot
    Cur_QC_speed = Cur.QC.((layer_str{ii}))*100;
    Cur_QCyet_speed = Cur.with_nan_data.((layer_str{ii}))*100;
    Cur_QC_dir = Cur.QC.((layer_str{ii} + "_Dir"));
    Cur_QCyet_dir = Cur.with_nan_data.((layer_str{ii} + "_Dir"));
    dday = datenum(Cur.((layer_str{ii} + "_time")));

    % plot(dday, Cur_QCyet_speed, 'Color', 'r', 'LineWidth', 2, "DisplayName", "Fail"); hold on
    plot(dday, Cur_QC_speed, 'Color', 'k', 'LineWidth', 2, "DisplayName", "Pass"); 
    % idx_flag3 = find(Cur.((layer_str{ii} + "flags_total")) == 3);
    % plot(dday(idx_flag3), Cur_QC_speed(idx_flag3), '.', "Color", "#FFD306", "MarkerSize", 10, "DisplayName", "Suspect")
    % ylim([floor(min(Cur_QC_speed)*2)/2 ceil(max(Cur_QC_speed)*2)/2])
    xlim([floor(dday(1)) ceil(dday(end))])
    grid on
    % if ii == 3
    %     legend("Location", "northoutside", "Box", "off", "NumColumns", 3)
    % end
    ylabel("(cm s^{-1})")
    figset_linefont(ax)
    figset_date(ax, dday)
    figset_date_minorticks(ax, dday)
    title(ax, sprintf("%s", replace(layer_str(ii), "Layer", " Layer")))
    set(ax, "XTicklabels", [])
    

    ax = nexttile;
    u = Cur_QCyet_speed.*sind(Cur_QC_dir);
    v = Cur_QCyet_speed.*cosd(Cur_QC_dir);
    xlim([floor(dday(1)) ceil(dday(end))])
    % quiver_f(dday, u, v, "Color", "r"); hold on
    u = Cur_QC_speed.*sind(Cur_QC_dir);
    v = Cur_QC_speed.*cosd(Cur_QC_dir);
    quiver_f(dday, u, v, "Color", "k");
    xlim([floor(dday(1)) ceil(dday(end))])
    
    ylabel("(cm s^{-1})")
    % quiver_f(dday(idx_flag3), u(idx_flag3), v(idx_flag3), "Color", "#FFD306");
    xlim([floor(dday(1)) ceil(dday(end))])
    ylim([-150 150])
    grid on
    figset_linefont(ax)
    figset_date(ax, dday)
    figset_date_minorticks(ax, dday)

end

saving_str = sprintf("%s_current.png", filedate);
exportgraphics(fig, fullfile(pic_c, saving_str))

%% Windrose
% ========================= WindRose ===========================
% fig = figure("Visible", "off");
% fig = figure("OuterPosition", [1 1 1920/4+200 1080]);
% fig = figure("OuterPosition", [1 1 1920/4+200 1080], "Visible", "off");
% tiledlayout(3, 1, "TileSpacing", "compact", "Padding", "tight");
% title_str = sprintf("%s~%s", datestr(all_dday_datetime(1), 'yyyy/mm/dd'), datestr(all_dday_datetime(end), 'yyyy/mm/dd'));
for ii = length(layer_str):-1:1
    fig = figure();
    tiledlayout(1, 1, "TileSpacing", "compact", "Padding", "tight");
    % title_str = sprintf("N %s (%.1f mab)", layer_str, ii+1.4);
    title_str = sprintf("%s", replace(layer_str(ii), "Layer", " Layer"));
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
    Options.vWinds          = 0:10:60;
    Options.LabLegend       = 'Cur in cm/s';
    Options.LegendVariable  = 'Cur';
    Options.scalefactor     = 0.9;
    Options.TitleString     = title_str;
    Options.axes            = ax;
    Options.figcolor        = 'w';
    
    valid_idx = ~isnan(Cur.QC.((layer_str{ii} + "_Dir"))) & ~isnan(Cur.QC.((layer_str{ii}))*100);
    Rose_dir = Cur.QC.((layer_str{ii} + "_Dir"))(valid_idx);
    Rose_WS = Cur.QC.((layer_str{ii}))(valid_idx)*100;
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

    saving_str = sprintf("%s_%s_CurRose.png", filedate, layer_str{ii});
    exportgraphics(fig, fullfile(pic_c, saving_str))

end

% file_str = sprintf("%s\\%sN_3layers_Windrose.png", output_folder, filedate);
% exportgraphics(fig, file_str)


%% PVD (Progressive Vector Diagram)
% cd(func)


% PVD_time_S = [0;diff((dday_S-datenum(dday_S(1)))*86400)];
figure("OuterPosition", [1 1 1920/2 1080])
tt = tiledlayout(3,1,"TileSpacing","compact","Padding","tight");
for ii = length(layer_str):-1:1
    Cur_QC_speed = Cur.QC.((layer_str{ii}));
    Cur_QC_dir = Cur.QC.((layer_str{ii} + "_Dir"));
    dday = datenum(Cur.((layer_str{ii} + "_time")));
    u = Cur_QC_speed.*sind(Cur_QC_dir);
    v = Cur_QC_speed.*cosd(Cur_QC_dir);

    ax = nexttile;
    totalday = ceil(dday(end)-dday(1)); % days from the start to the end of the observation 
    dayday = diff(floor(dday)); % round down the dday data, force it into the beginging of the day (e.g. floor(2026/04/30 11:30) -> 2026/04/30 00:00)
    another_day = find(dayday == 1); % diff: difference value between values of the double data; if the day is changed, diff(dayday) = 1
    PVD_time = [0;diff((dday-datenum(dday(1)))*86400)]; % turning day into second, then made it as a matrix (double)
    xlocal=cumsum(u.*PVD_time/1000); % 10分鐘一筆資料 & 單位轉換成公里
    ylocal=cumsum(v.*PVD_time/1000);
    x = cumsum(abs(u.*PVD_time/1000)); % calculate the distance of U component, then accumulate the data
    y = cumsum(abs(v.*PVD_time/1000)); % calculate the distance of V component, then accumulate the data
    % distance = sqrt(x(end)^2+y(end)^2); % Pythagorean theorem
    % vel = distance/totalday; % total distance / total days
    distance = sqrt(xlocal(end)^2+ylocal(end)^2); % Pythagorean theorem
    vel = distance/totalday; % total distance / total days
    

    plot(xlocal,ylocal,'k','linewidth',1.5);hold on;
    plot(xlocal(another_day),ylocal(another_day),'ob','markerSize',5,'MarkerFaceColor','none');hold on;
    plot(xlocal(1),ylocal(1),'ob','markerSize',3,'MarkerFaceColor','b');hold on;
    plot(xlocal(end),ylocal(end),'om','markerSize',5,'MarkerFaceColor','none');hold on;
    axis equal;
    grid on;
    axis_lim = [-250 500 -400 200];
    axis(axis_lim)
        
    text(xlocal(1),ylocal(1)+50,[datestr(dday(1), 'yyyy/mm/dd HH:MM')],'FontSize',12,'color','b', ...
        'HorizontalAlignment','center');
    text(xlocal(end)+30,ylocal(end),[datestr(dday(end), 'yyyy/mm/dd HH:MM')],'fontsize',12,'color','m', ...
        'HorizontalAlignment','left');
    % text(48, -95, ['底床上', num2str(ii+1.4), 'm'],'FontName','標楷體','FontSize',12,'HorizontalAlignment','right')
    % for jj = 2:2:length(another_day+1)
    %     text(xlocal(another_day(jj-1))+7, ylocal(another_day(jj-1))+5,[datestr((dday(another_day(jj))), 'dd')], ...
    %         'FontSize',12,'color','k');
    % end
    y_axis_length = axis_lim(4)-axis_lim(3);
    x_axis_length = axis_lim(2)-axis_lim(1);
    text(0.01, 0.95, ['Net Displacement: ', num2str(distance, '%.1f'), ' km'], 'fontsize', 16, 'Units', 'normalized')
    text(0.01, 0.85, ['Net Velocity: ', num2str(vel, '%.1f'), ' km/day'], 'fontsize', 16, 'Units', 'normalized')
    text(0.12, -0.05, '(km)', 'FontSize', 15, 'Units', 'normalized')
    text(-0.02, 0.2, '(km)', 'FontSize', 15, 'HorizontalAlignment','right', 'Units', 'normalized')
    set(gca,'FontWeight','bold','fontsize',15, 'tickdir', 'out','linewidth',1.5, ...
        'Ticklength', [.03 .03]);hold on
    ax.XAxis.MinorTick = 'on';
    ax.XAxis.MinorTickValues = axis_lim(1):10:axis_lim(2);
    ax.YAxis.MinorTick = 'on';
    ax.YAxis.MinorTickValues = axis_lim(3):10:axis_lim(4);

    title_str = sprintf("%s PVD", replace(layer_str(ii), "Layer", " Layer"));
    title(ax, title_str, 'FontSize', 18)
end

file_str = sprintf("%s\\%s_PVD_3layers.png", pic_c, filedate);
exportgraphics(gcf, file_str)


%% scatter UV
layers = ['Bot. layer'; 'Mid. layer'; 'Top. layer'];
figure("OuterPosition", [1 1 1920/2-300 1080])
tt = tiledlayout(3, 1, "TileSpacing", "compact", "Padding", "tight");
for ii = length(layer_str):-1:1
    ax = nexttile;
    Cur_QC_speed = Cur.QC.((layer_str{ii}));
    Cur_QC_dir = Cur.QC.((layer_str{ii} + "_Dir"));
    dday = datenum(Cur.((layer_str{ii} + "_time")));
    u = Cur_QC_speed.*sind(Cur_QC_dir);
    v = Cur_QC_speed.*cosd(Cur_QC_dir);
    scatter(u, v, 8, "filled", "MarkerFaceColor", [.5 .5 1]); hold on % scatter chart of U & V component
    axis equal
    text(.1, -.7, '(m/sec)', 'FontSize',15)
    ax.XAxisLocation = 'origin'; % making X axis fixed at y = 0
    ax.YAxisLocation = 'origin'; % making Y axis fixed at x = 0
    ax.TickDir = 'both'; % having ticks both inside and outside axis
    axis([-1.5 1.5 -1.5 1.5])
    set(ax, 'Xtick', [-1.5:.5:-.5, .5:.5:1.5], 'Ytick', -1.5:.5:1.5, ...
        'fontsize',13,'linewidth',1.5, 'Ticklength', [.03 .03], ...
        'Clipping', 'off', 'fontweight', 'bold') % "Clipping": allow plots out of frame
    % plot([-.2, -.2], [-.07, .07], 'LineWidth', 2, 'Color', [.2 .2 .2])
    % text(-.2, -.08, '-0.2', 'FontSize', 13, 'FontWeight', 'bold', 'HorizontalAlignment', 'center')
    ax.XAxis.MinorTick = 'on';
    ax.XAxis.MinorTickValues = -1.5:.25:1.5;
    ax.YAxis.MinorTick = 'on';
    ax.YAxis.MinorTickValues = -1.5:.25:1.5;
    ax.Layer = 'top';
    title_str = sprintf("%s", layers(ii, :));
    title(ax, title_str, 'FontSize', 15)

end
% title_str = sprintf("\\bfUV scatter diagram\n\\rm%s", plotdate_all);
% title(tt, title_str, 'fontsize', 18)

file_str = sprintf("%s\\%s_UV_scatter_diagram_3layers_2sites.png", pic_c, filedate);
exportgraphics(gcf, file_str)

%% spectrum

for ii = 1:3
    u = Cur.u(:, ii);
    v = Cur.v(:, ii);
    spectrum_cur(u*100, v*100, sprintf("%s", layer_str{ii}),plotdate_all)
    ylim([1e0 1e6])
    file_str = sprintf("%s\\%s_%s_UV_spectrum.png", pic_c, filedate, layer_str{ii});
    exportgraphics(gcf, file_str)
end

%% T-tide
tide_names = {"M2"; "K1"; "O1"; "S2"; "N2"; "P1"; "K2"; "L2"};
tide_names = string(tide_names);

idx_name = zeros(8, 1);
dday_st = dday(1);

tidecon = t_tide(Cur.SL, 1/6, dday_st, 22);

tt_names = strip(string(tidecon.name));
for jj = 1:length(tt_names)
    if any(strcmpi(tt_names(jj), tide_names))
        % idx_name = [idx_name; jj];
        ig = find(strcmpi(tt_names(jj), tide_names));
        idx_name(ig) = jj;
    end
end

output_name = sprintf("%s_SL_t_tide.csv", filedate);
fid = fopen(fullfile(output_folder, output_name), "w", "n", "UTF-8");
fprintf(fid, "tide,degree/hr,amp(m),pha(degree)\n");
for ii = 1:length(tide_names)
    idx = idx_name(ii);
    if idx ~= 0
        rad_hr = tidecon.freq(idx)*360;
        fprintf(fid, "%s,%.2f,%.2f,%.2f\n", tide_names(ii), rad_hr, tidecon.tidecon(idx, 1), tidecon.tidecon(idx, 3));
    end
end

fclose(fid);
% tt_names(idx_name)



%% 
for ii = 1:3
    u = Cur.u(:, ii);
    v = Cur.v(:, ii);
    idx_name = [];

    comp_uv = complex(u, v);
    tidecon = t_tide(comp_uv, 1/6);

    tt_names = strip(string(tidecon.name));
    for jj = 1:length(tt_names)
        if any(strcmpi(tt_names(jj), tide_names))
            idx_name = [idx_name; jj];
        end
    end


    
end



%% 
%{
%% Spring tide
% cd(func)
figure('OuterPosition', [1 1 1920/2 1080/2])
t = tiledlayout(2, 1, "TileSpacing", "compact", "Padding", "tight");
ax = nexttile;
plot(C.dday, T.SL, 'k','LineWidth', 3)
axis([floor(C.dday(springtide_time)) floor(C.dday(springtide_time))+1.5 floor(min(T.SL)) ceil(max(T.SL))])
set(gca, 'xtick', floor(C.dday(springtide_time)):0.25:floor(C.dday(springtide_time))+1.5, ...
    'xticklabel',{[datestr(floor(C.dday(springtide_time)),'mm/dd'),  ' 00:00'],'06:00','12:00','18:00',[datestr(floor(C.dday(springtide_time))+1,'mm/dd'),  ' 00:00'],'06:00','12:00'})
ylabel('Depth (m)')
grid on
figset_linefont(ax)
title_txt = sprintf('\\bf%s station 36 hours spring tide level\n\\rm%s 00:00 ~ %s 12:00', ...
    station, datestr(floor(C.dday(springtide_time)),'mm/dd'), datestr(floor(C.dday(springtide_time))+1,'mm/dd'));
title(t, title_txt, 'FontSize', 18)
hold on

dday_st = find(C.dday == floor(C.dday(springtide_time)));
dday_end = find(C.dday == floor(C.dday(springtide_time))+1.5);
ax = nexttile;
quiver_f(C.dday(dday_st:dday_end), C.u(dday_st:dday_end,upp)*100, C.v(dday_st:dday_end,upp)*100)
axis([floor(C.dday(springtide_time)) floor(C.dday(springtide_time))+1.5 -60 60])
set(gca, 'xtick', floor(C.dday(springtide_time)):0.25:floor(C.dday(springtide_time))+1.5, ...
    'xticklabel',{[datestr(floor(C.dday(springtide_time)),'mm/dd'),  ' 00:00'],'06:00','12:00','18:00',[datestr(floor(C.dday(springtide_time))+1,'mm/dd'),  ' 00:00'],'06:00','12:00'})
set(gca, 'ytick', -60:30:60)
figset_linefont(ax)
grid on
ylabel('Speed (cm s^{-1})')
xlabel(['month/day hour:minute of ', datestr(C.dday(1), 'yyyy')])
cd(pic_c)
exportgraphics(gcf, [filedate, '_', station,'_spring_tide_level.png'])








%
% C.Cur = sqrt(C.u.^2+C.v.^2);
% C.Dir = rad2deg(atan2(C.u, C.v))+360;
ig = find(C.Dir >= 360);
C.Dir(ig) = C.Dir(ig)-360;

upp = 3;
mid = 2;
low = 1;
layers = [upp mid low];

station = 'Xingda';
% flag_time_interval = time_interval_test(C.dday, 600, 60);

% ============================= QC_Data ==============================
dday = nan(C.Test(1).all_data, 1); dday(C.Test(1).pass) = C.dday(C.Test(1).pass);
passing_percentage.dday = length(C.Test(1).pass)/C.Test(1).all_data*100;
Cur = nan(C.Test(2).all_data, 3); 
Dir = nan(C.Test(3).all_data, 3); 
u = nan(C.Test(2).all_data, 3); 
v = nan(C.Test(2).all_data, 3); 

SL = nan(T.Test(1).all_data, 1); SL(T.Test(1).pass) = T.SL(T.Test(1).pass);

for ii = 1:3
    Cur(C.Test(ii*2).pass, ii) = C.Cur(C.Test(ii*2).pass, ii);
    u(C.Test(ii*2).pass, ii) = C.u(C.Test(ii*2).pass, ii);
    v(C.Test(ii*2).pass, ii) = C.v(C.Test(ii*2).pass, ii);
    Dir(C.Test(ii*2+1).pass, ii) = C.Dir(C.Test(ii*2+1).pass, ii);
    passing_percentage.Cur(ii) = length(C.Test(ii*2).pass)/C.Test(1).all_data*100;
    passing_percentage.Dir(ii) = length(C.Test(ii*2+1).pass)/C.Test(1).all_data*100;
    passing_percentage.SL = length(T.Test(2).pass)/T.Test(1).all_data*100;
end


% ================= find spring tide & neap tide ===================
windowsize = 6*36;

leveldiff = [];
for ii = 1:(length(T.SL)-windowsize+1)
    leveldiff(ii,1) = max(T.SL(ii:ii+windowsize-1)) - min(T.SL(ii:ii+windowsize-1));
end
[springtide, springtide_time] = max(leveldiff);
[neaptide, neaptide_time] = min(leveldiff);


%% Tseng pro's
% making a stastic table saving as .txt
% cd(func)
filename = sprintf('%s\\%s_%s_Bottomlayer_Cur_Dir.txt', p_data, filedate, station);
Vanalyis(u(:,low)*100, v(:,low)*100, Cur(:,low)*100, Dir(:,low), filename, p_data);   %輸出流速流向聯合機率分布統計表

filename = sprintf('%s\\%s_%s_Middlelayer_Cur_Dir.txt', p_data, filedate, station);
Vanalyis(u(:,mid)*100, v(:,mid)*100, Cur(:,mid)*100, Dir(:,mid), filename, p_data);   %輸出流速流向聯合機率分布統計表

filename = sprintf('%s\\%s_%s_Toplayer_Cur_Dir.txt', p_data, filedate, station);
Vanalyis(u(:,upp)*100, v(:,upp)*100, Cur(:,upp)*100, Dir(:,upp), filename, p_data);   %輸出流速流向聯合機率分布統計表


%% plot
figure("OuterPosition", [1 1 1920/2 1080])
tt = tiledlayout(8, 1, "TileSpacing", "compact", "Padding", "tight");
ax = nexttile; % the tile you plot
plot(dday, T.SL, 'r', 'LineWidth', 2, 'DisplayName', 'Raw'); hold on
plot(dday, SL, 'k', 'LineWidth', 2, 'DisplayName', 'QC') % plot water level data
ylim([floor(min(SL)*2)/2 ceil(max(SL)*2)/2]); % upper and lower limit of Y axis
xlim([floor(dday(1)) ceil(dday(end))]) % upper and lower limit of X axis ("floor" means round down (complete discarding), "ceil" means round up (complete Carry))
ylabel('Depth (m)') % label of Y axis
figset_linefont(ax) % function handle "figsetting"
figset_date(ax, dday)
figset_date_minorticks(ax, dday)
legend('Box', 'off', 'NumColumns', 2, 'Location', 'best')
set(ax, 'xticklabels', []) % discarding the X axis label preventing plot too small
title_str = sprintf('\\bf%s station Tide level and Current speed & direction\n\\rm%s', station, plotdate_all); % title string
title(tt, title_str, 'fontsize', 15) % print title string of the FIGURE (the whole picture)
title_str = sprintf('Tide level, passing rate: %.2f%%', passing_percentage.SL);
title(ax, title_str, 'FontSize', 12); % print title string of the TILE (your plotting)
grid on

ax = nexttile;
quiver_f(dday(1:6:end), WIND.wu, WIND.wv) % stick figure of wind
axis([floor(dday(1)) ceil(dday(end)) -10 10]) % setting X & Y axis at the same time
set(gca,'ytick',-10:5:10);
ylabel('Speed (m/s)');
figset_linefont(ax)
figset_date(ax, dday)
figset_date_minorticks(ax, dday)
grid on
title(ax, 'Wind', 'FontSize', 12)
set(ax, 'xticklabels', [])


ax = nexttile;
plot(dday, C.Cur(:,upp)*100, 'r','LineWidth', 1.2, 'DisplayName', 'Raw'); hold on
plot(dday, Cur(:,upp)*100, 'k','LineWidth', 1.2, 'DisplayName', 'QC') % line chart of the upper layer
axis([floor(dday(1)) ceil(dday(end)) 0 200])
ylabel('Speed (cm/s)')
figset_linefont(ax)
figset_date(ax, dday)
figset_date_minorticks(ax, dday)
grid on
legend('Box', 'off', 'NumColumns', 2, 'Location', 'best')
title_str = sprintf('Top layer, passing rate: %.2f%%', passing_percentage.Cur(upp));
title(ax, title_str, 'fontsize', 12)
set(ax, 'xticklabels', [])


ax = nexttile;
quiver_f(dday, C.u(:,upp)*100, C.v(:,upp)*100, "Color", 'r'); hold on
quiver_f(dday, u(:,upp)*100, v(:,upp)*100)
axis([floor(dday(1)) ceil(dday(end)) -100 100])
set(ax, 'ytick', -100:50:100)
ylabel('Speed (cm/s)')
figset_linefont(ax)
figset_date(ax, dday)
figset_date_minorticks(ax, dday)
set(ax, 'xticklabels', [])
grid on

% Middle layer
ax = nexttile;
plot(dday, C.Cur(:,mid)*100, 'r','LineWidth', 1.2, 'DisplayName', 'Raw'); hold on
plot(dday, Cur(:,mid)*100,'k','LineWidth', 1.2, 'DisplayName', 'QC')
axis([floor(dday(1)) ceil(dday(end)) 0 200])
ylabel('Speed (cm/s)')
% set(ax,'ytick',0:20:80)
figset_linefont(ax)
figset_date(ax, dday)
figset_date_minorticks(ax, dday)
title_str = sprintf('Middle layer, passing rate: %.2f%%', passing_percentage.Cur(mid));
title(ax, title_str, 'fontsize', 12)
set(ax, 'xticklabels', [])
grid on
legend('Box', 'off', 'NumColumns', 2, 'Location', 'best')

ax = nexttile;
quiver_f(dday, C.u(:,mid)*100, C.v(:,mid)*100, 'Color', 'r'); hold on
quiver_f(dday, u(:,mid)*100, v(:,mid)*100)
axis([floor(dday(1)) ceil(dday(end)) -100 100])
set(ax, 'ytick', -100:50:100)
ylabel('Speed (cm/s)')
figset_linefont(ax)
figset_date(ax, dday)
figset_date_minorticks(ax, dday)
set(ax, 'xticklabels', [])
grid on

% bottom layer
ax = nexttile;
plot(dday, C.Cur(:,low)*100, 'r','LineWidth', 1.2, 'DisplayName', 'Raw'); hold on
plot(dday, Cur(:,low)*100, 'k', 'LineWidth', 1.2, 'DisplayName', 'QC')
axis([floor(dday(1)) ceil(dday(end)) 0 200])
ylabel('Speed (cm/s)')
% set(gca, 'ytick', 0:20:80)
figset_linefont(ax)
figset_date(ax, dday)
figset_date_minorticks(ax, dday)
title_str = sprintf('Bottom layer, passing rate: %.2f%%', passing_percentage.Cur(low));
title(ax, title_str, 'fontsize', 12)
set(ax, 'xticklabels', [])
grid on
legend('Box', 'off', 'NumColumns', 2, 'Location', 'best')

ax = nexttile;
quiver_f(dday, C.u(:,low)*100, C.v(:,low)*100, 'Color', 'r'); hold on
quiver_f(dday, u(:,low)*100, v(:,low)*100)
axis([floor(dday(1)) ceil(dday(end)) -100 100])
set(ax, 'ytick', -100:50:100)
ylabel('Speed (cm/s)')
xlabel('Date (month/day)')
figset_linefont(ax)
figset_date(ax, dday)
figset_date_minorticks(ax, dday)
grid on

cd(pic_c)
exportgraphics(gcf,[filedate, '_threelayers_Current_speed_flow_vector_depth.png'])

%% Current Rose 
MaxProp = 50; % current direction probability

% cd(func)
figure("OuterPosition", [1 1 1920/2 1080])
tt = tiledlayout(3, 1, "TileSpacing", "compact", "Padding", "tight");
ax = nexttile;
WindRose(C.Dir(:,upp),C.Cur(:,upp)*100, ... % the function i don't where to download it, but in your functions folder
    'nDirections', 16, ...
    'gridstyle', ':', ...
    'gridcolor', 'k', ...
    'gridwidth', 2, ...
    'gridalpha', 0.5, ...
    'labels', {'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'}, ...
    'cMap', 'invgray', ...
    'vWinds',[0 10 20 30 40 50 60], ...
    'TitleString', [station, ' Cur Top Layer '], ...
    'LabLegend', 'Cur in cm', ...
    'LegendVariable', 'Cur' , ...
    'zeroAndNegative', true, ...
    'MaxFrequency', MaxProp, ...
    'FreqLabelAngle', 'auto', ...
    'AngleNorth', 0, ...
    'axes', gca, ...
    'AngleEast', 90);
figset_linefont(ax)
ax.Legend.Location = 'westoutside';

ax = nexttile;
WindRose(C.Dir(:,mid),C.Cur(:,mid)*100,'nDirections', 16,'gridstyle', ':', 'gridcolor', 'k', 'gridwidth', 2, 'gridalpha', 0.5, 'labels', {'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'}, 'cMap', 'invgray','vWinds',[0 10 20 30 40 50 60], ...
    'TitleString', [station, ' Cur Middle Layer '], 'LabLegend', 'Cur in cm', 'LegendVariable', 'Cur' ,'zeroAndNegative', true, ...
    'MaxFrequency', MaxProp, 'FreqLabelAngle', 'auto', 'AngleNorth', 0, 'AngleEast', 90, ...
    "axes", gca);
figset_linefont(ax)
% ax.Legend.Location = 'westoutside';
set(ax.Legend, 'visible', 'off')

ax = nexttile;
WindRose(C.Dir(:,low),C.Cur(:,low)*100,'nDirections', 16,'gridstyle', ':', 'gridcolor', 'k', 'gridwidth', 2, 'gridalpha', 0.5, 'labels', {'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'}, 'cMap', 'invgray','vWinds',[0 10 20 30 40 50 60], ...
    'TitleString', [station, ' Cur Bottom Layer '], 'LabLegend', 'Cur in cm', 'LegendVariable', 'Cur' ,'zeroAndNegative', true, ...
    'MaxFrequency', MaxProp, 'FreqLabelAngle', 'auto', 'AngleNorth', 0, 'AngleEast', 90, ...
    "axes", gca);
figset_linefont(ax)
% ax.Legend.Location = 'westoutside';
set(ax.Legend, 'visible', 'off')

file_str = sprintf("%s\\%s_3layers_Windrose.png", pic_c, filedate);
exportgraphics(gcf, file_str)

%}


