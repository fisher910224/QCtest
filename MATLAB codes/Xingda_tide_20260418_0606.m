%% Xingda Harbor
% 0418-0606
% 20260811 edited
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
if ~isfolder(p_data)
    mkdir(p_data)
end

%% Figure setting
figset_linefont = @(ax) set(ax, 'fontsize', 12, 'linewidth', 1.5, "TickLength", [0.005 0.02], 'TickDir', 'out'); % setting of font size, frame line size, tick length and size
figset_date = @(ax, wave_day) set(ax, 'XTick', floor(wave_day(1)):4:ceil(wave_day(end)), ...
    'Xticklabel', datestr(floor(wave_day(1)):4:ceil(wave_day(end)), 'mm/dd')); % Major ticks which means 4 days
figset_date_minorticks = @(ax, wave_day) set(ax.XAxis, 'Minortick', 'on', 'MinorTickValues', floor(wave_day(1)):1:ceil(wave_day(end))); % Minor ticks which means one day

%% Load data
load([main_folder, '\PROCESSED_DATA.mat'])
plotdate_all = sprintf('%s~%s', datestr(C.dday(1), 'yyyy/mm/dd'), datestr(C.dday(end), 'mm/dd'));
filedate = sprintf('%s_%s', datestr(C.dday(1), 'yyyymmdd'), datestr(C.dday(end), 'mmdd'));

C.Cur = sqrt(C.u.^2+C.v.^2);
C.Dir = rad2deg(atan2(C.u, C.v))+360;
ig = find(C.Dir >= 360);
C.Dir(ig) = C.Dir(ig)-360;

upp = 3;
mid = 2;
low = 1;

station = 'Xingda';
flag_time_interval = time_interval_test(C.dday, 600, 60);

% [NAME,FREQ,TIDECON,XOUT]=T_TIDE(XIN)
T(1) = t_tide(C.Pressure-mean(C.Pressure), 1/6);
main_tide = {'K1'; 'O1'; 'M2'; 'S2'};
nn = cellstr(T(1).name);
ig = [];
for jj = 1:width(C.u)
    T(jj+1) = t_tide(complex(C.u(:, jj), C.v(:, jj)), 1/6);
    for ii = 1:length(main_tide)
        nn = cellstr(T(jj+1).name);
        ig(ii, 1) = find(strcmp(nn, main_tide{ii}));
        ig(ii, jj+1) = find(strcmp(nn, main_tide{ii}));
    end
end


[~, idx_max] = sort(T(1).tidecon(:, 1), 'descend');
idx_max3 = idx_max(1:3);


%% Print results
f_file = fopen([p_data, '\', station, '_', 'Tide_amplitude.txt'], 'w');
fprintf(f_file, '================= Main Tide Results =================\n');
fprintf(f_file, 'Tide        Freq.(cpd)     Amp.           Pha.    \n');
for ii = 1:length(ig)
    fprintf(f_file, '%-3s         %5.4f         %5.4f         %5.2f\n', main_tide{ii}, T(1).freq(ig(ii))*24, T(1).tidecon(ig(ii), 1), T(1).tidecon(ig(ii), 3));
end

fprintf(f_file, '\n================= Max3 Tide Results =================\n');
for ii = 1:length(idx_max3)
    fprintf(f_file, '%-3s         %5.4f         %5.4f         %5.2f\n', nn{idx_max3(ii)}, T(1).freq(idx_max3(ii))*24, T(1).tidecon(idx_max3(ii), 1), T(1).tidecon(idx_max3(ii), 3));
end

fclose(f_file);

%% Ellipse
figure
tiledlayout(1, 1, "TileSpacing", "compact", "Padding", "tight")
ax = nexttile;
for jj = 2:4
    for ii = 1:length(main_tide)
        ellipse(T(jj).tidecon(ig(ii, jj), 1), T(jj).tidecon(ig(ii, jj), 3), deg2rad(T(jj).tidecon(ig(ii, jj), 5)), ii, jj); hold on
    end
end
plot([0.6 0.6], [3 3.3], 'LineWidth', 2, 'Color', 'r')
text(0.7, 3, '30 cm s^{-1}', 'FontSize', 12, 'Color', 'r', 'Rotation', 90)
set(ax, 'xtick', 1:4, 'xticklabels', main_tide, 'ytick', 2:4, 'yticklabels', ['Low.'; 'Mid.'; 'Upp.'])
grid on
ylabel('Layers')
figset_linefont(ax)
title_txt = sprintf('\\bf%s station tidal ellipse\n\\rm%s', station, plotdate_all);
title(ax, title_txt, 'FontSize', 18)
file_txt = sprintf('%s\\%s_%s_tidal ellipse.png', pic_c, filedate, station);
exportgraphics(gcf, file_txt)


