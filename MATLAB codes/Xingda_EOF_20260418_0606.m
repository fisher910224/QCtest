%% Xingda Harbor
% 0418-0606
% 20260811 edited
clear; close all; clc; 

%% Path
main_folder = 'C:\Users\adm\Desktop\Xingda\2026\0418_0606';
cd(main_folder)
pic_c = [main_folder, '\picture\current'];
pic_w = [main_folder, '\picture\wave'];
if ~isfolder(pic_c)
    mkdir(pic_c)
end
if ~isfolder(pic_w)
    mkdir(pic_w)
end

%% Figure setting
figset_linefont = @(ax) set(ax, 'fontsize', 18, 'linewidth', 1.5, "TickLength", [0.005 0.02], 'TickDir', 'out'); % setting of font size, frame line size, tick length and size
figset_date = @(ax, wave_day) set(ax, 'XTick', floor(wave_day(1)):4:ceil(wave_day(end)), ...
    'Xticklabel', datestr(floor(wave_day(1)):4:ceil(wave_day(end)), 'mm/dd')); % Major ticks which means 4 days
figset_date_minorticks = @(ax, wave_day) set(ax.XAxis, 'Minortick', 'on', 'MinorTickValues', floor(wave_day(1)):1:ceil(wave_day(end))); % Minor ticks which means one day

%% Load data
load([main_folder, '\PROCESSED_DATA.mat'])
plotdate_all = sprintf('%s~%s', datestr(C.dday(1), 'yyyy/mm/dd'), datestr(C.dday(end), 'mm/dd'));
filedate = sprintf('%s_%s', datestr(C.dday(1), 'yyyymmdd'), datestr(C.dday(end), 'mmdd'));

% C.Cur = sqrt(C.u.^2+C.v.^2);
% C.Dir = rad2deg(atan2(C.u, C.v))+360;
% ig = find(C.Dir >= 360);
% C.Dir(ig) = C.Dir(ig)-360;

upp = 3;
mid = 2;
low = 1;

station = 'Xingda';
flag_time_interval = time_interval_test(C.dday, 600, 60);

%% EOF
[Eigenvector, Variance, Amplitude] = eof([C.u, C.v]);
Percentage = Variance./sum(Variance)*100;
depth = (1:3)';
color_box = ['k', 'm', 'b'];

figure("OuterPosition", [1 1 1920 1080])
tt = tiledlayout(3, 3, "TileSpacing", "compact", "Padding", "tight");
for ii = 1:3
    ax = nexttile;
    quiver3(zeros(size(depth)), zeros(size(depth)), depth, ...
        Eigenvector(1:3, ii), Eigenvector(4:end, ii), zeros(size(depth)), ...
        0, 'filled', 'ShowArrowHead', 'on', 'LineWidth', 2.5, 'Color', color_box(ii), 'MaxHeadSize', 60); hold on
    % quiver3(zeros(size(depth)), zeros(size(depth)), depth, ...
    %     Eigenvector(1:3, 2), Eigenvector(4:end, 2), zeros(size(depth)), ...
    %     0, 'filled', 'ShowArrowHead', 'off', 'LineWidth', 1.2, 'Color', 'm'); hold on
    plot([0, 0], [0, 1], 'LineWidth', 1.2, 'Color', 'r')
    plot([0, 1], [0, 0], 'LineWidth', 1.2, 'Color', 'b')
    ylim([-1 1])
    xlim([-1 1])
    zlim([0 3.5])
    text(-0.5, 0.5, 0, 'N', 'FontSize', 18, 'Color', 'r')
    plot3([0, 0], [0, 0], [0, 4], ...
        'linewidth', 1.2, 'Color', [.5 .5 .8], 'LineStyle', '--')
    set(ax, 'ztick', 1:3, 'zticklabels', ['Bot.'; 'Mid.'; 'Top.'])
    figset_linefont(ax)
    axis square
    if ii == 1
        title(ax, 'Eigenvector (Current profile)')
    end
    
    ax = nexttile([1 2]);
    mode_perc = sprintf('mode %.0f: %.2f%%', ii, Percentage(ii));
    plot(C.dday, Amplitude(:, ii), 'Color', color_box(ii), 'LineWidth', 1.2, 'DisplayName', mode_perc); hold on
    % plot(C.dday, Amplitude(:, 2), 'Color', 'm', 'LineWidth', 0.8, 'DisplayName', 'mode 2'); hold on
    grid on
    ylim([-2 2])
    legend('Box', 'off', 'NumColumns', 2)
    figset_date_minorticks(ax, C.dday)
    figset_date(ax, C.dday)
    figset_linefont(ax)
    ylabel('Velocity (m s^{-1})')
    if ii == 1
        title(ax, 'Amplitude (Principal component)')
    end
end
xlabel('Date (mm/dd)')
title_txt = sprintf('\\bf%s EOF mode 1~3\n\\rm%s', station, plotdate_all);
title(tt, title_txt, 'fontsize', 24)
file_name = sprintf('%s\\%s_EOF_%s.png', pic_c, filedate, station);
exportgraphics(gcf, file_name)

%% EOF spectrum
dt = 10/60/24;
fs = 1/dt;
window = hann(1024);
Curm = mean(C.Cur, 2);
eof_u = Eigenvector(1:3, :);
eof_v = Eigenvector(4:6, :);
mode1_um = mean(eof_u(:, 1));
mode1_vm = mean(eof_v(:, 1));
mode1_curm = sqrt(mode1_um^2 + mode1_vm^2);

mode2_um = mean(eof_u(:, 2));
mode2_vm = mean(eof_v(:, 2));
mode2_curm = sqrt(mode2_um^2 + mode2_vm^2);

mode3_um = mean(eof_u(:, 3));
mode3_vm = mean(eof_v(:, 3));
mode3_curm = sqrt(mode3_um^3 + mode3_vm^3);


[ss_mode1, df_mode1] = pwelch(Amplitude(:, 1)*mode1_curm, window, 1024/2, 1024, fs);
[ss_mode2, df_mode2] = pwelch(Amplitude(:, 2)*mode2_curm, window, 1024/2, 1024, fs);
[ss_mode3, df_mode3] = pwelch(Amplitude(:, 3)*mode3_curm, window, 1024/2, 1024, fs);
[ss_cur, df_cur] = pwelch(Curm, window, 1024/2, 1024, fs);
figure("OuterPosition", [1 1 1920/2 1080])
ax = nexttile;
loglog(df_mode1, ss_mode1, 'DisplayName', 'mode 1', 'Color', 'k', 'LineWidth', 2); hold on
loglog(df_mode2, ss_mode2, 'DisplayName', 'mode 2', 'Color', 'm', 'LineWidth', 2); hold on
loglog(df_mode3, ss_mode3, 'DisplayName', 'mode 3', 'Color', 'b', 'LineWidth', 2); hold on
loglog(df_cur, ss_cur, 'DisplayName', 'Cur_{mean}', 'Color', 'r', 'LineWidth', 2); hold on
xline(1.9322, 'Label', 'M_2', 'Color', [.5 .5 .5], 'LineWidth', 1.2, ...
    'HandleVisibility', 'off', 'LineStyle', '--', 'FontSize', 24, 'LabelHorizontalAlignment', 'center', ...
    'LabelVerticalAlignment', 'bottom', 'LabelOrientation', 'horizontal')
xline(1.0027, 'Label', 'K_1', 'Color', [.5 .5 .5], 'LineWidth', 1.2, ...
    'HandleVisibility', 'off', 'LineStyle', '--', 'FontSize', 24, 'LabelHorizontalAlignment', 'center', ...
    'LabelVerticalAlignment', 'bottom', 'LabelOrientation', 'horizontal')
xline(3, 'Label', '8 hr', 'Color', [.5 .5 .5], 'LineWidth', 1.2, ...
    'HandleVisibility', 'off', 'LineStyle', '--', 'FontSize', 15, 'LabelHorizontalAlignment', 'center', ...
    'LabelVerticalAlignment', 'bottom', 'LabelOrientation', 'horizontal')
xline(4, 'Label', '6 hr', 'Color', [.5 .5 .5], 'LineWidth', 1.2, ...
    'HandleVisibility', 'off', 'LineStyle', '--', 'FontSize', 15, 'LabelHorizontalAlignment', 'center', ...
    'LabelVerticalAlignment', 'bottom', 'LabelOrientation', 'horizontal')

ylabel('Power Spectral Density (m^2 s^{-2} cpd^{-1})');
xlabel('Frequency (cpd)');
legend('Box', 'off')
set(ax, 'linewidth', 2, 'Fontsize', 18)

exportgraphics(gcf, 'C:\Users\adm\Desktop\Xingda\2026\0418_0606\picture\current\mode_1_vs_original_data.png')

%% Wind and mode 2
figure("OuterPosition", [1 1 1920 1080*2/3])
tt = tiledlayout(2, 3, "TileSpacing", "compact", "Padding", "tight");
ax = nexttile;
ii = 2;
quiver3(zeros(size(depth)), zeros(size(depth)), depth, ...
    -Eigenvector(1:3, ii), -Eigenvector(4:end, ii), zeros(size(depth)), ...
    0, 'filled', 'ShowArrowHead', 'on', 'LineWidth', 2.5, 'Color', color_box(ii), 'MaxHeadSize', 60); hold on
plot([0, 0], [0, 1], 'LineWidth', 1.2, 'Color', 'r')
plot([0, 1], [0, 0], 'LineWidth', 1.2, 'Color', 'b')
ylim([-1 1])
xlim([-1 1])
zlim([0 3.5])
text(-0.5, 0.5, 0, 'N', 'FontSize', 18, 'Color', 'r')
plot3([0, 0], [0, 0], [0, 4], ...
    'linewidth', 1.2, 'Color', [.5 .5 .8], 'LineStyle', '--')
set(ax, 'ztick', 1:3, 'zticklabels', ['Bot.'; 'Mid.'; 'Top.'])
figset_linefont(ax)
axis square

ax = nexttile([1 2]);
plot(C.dday, -normalize(Amplitude(:, 2)), 'Color', 'm'); hold on
plot(C.dday(1:6:end), normalize(WIND.wv), 'Color', 'k', 'LineWidth', 2)
yline(0, 'LineWidth', 2, 'Color', 'y', 'LineStyle', '-')
grid on
ylabel('Normalized Amp.')
figset_linefont(ax)
figset_date(ax, C.dday)
figset_date_minorticks(ax, C.dday)



ax = nexttile;
ii = 3;
quiver3(zeros(size(depth)), zeros(size(depth)), depth, ...
    Eigenvector(1:3, ii), Eigenvector(4:end, ii), zeros(size(depth)), ...
    0, 'filled', 'ShowArrowHead', 'on', 'LineWidth', 2.5, 'Color', color_box(ii), 'MaxHeadSize', 60); hold on
plot([0, 0], [0, 1], 'LineWidth', 1.2, 'Color', 'r')
plot([0, 1], [0, 0], 'LineWidth', 1.2, 'Color', 'b')
ylim([-1 1])
xlim([-1 1])
zlim([0 3.5])
text(-0.5, 0.5, 0, 'N', 'FontSize', 18, 'Color', 'r')
plot3([0, 0], [0, 0], [0, 4], ...
    'linewidth', 1.2, 'Color', [.5 .5 .8], 'LineStyle', '--')
set(ax, 'ztick', 1:3, 'zticklabels', ['Bot.'; 'Mid.'; 'Top.'])
figset_linefont(ax)
axis square

ax = nexttile([1 2]);
plot(C.dday, normalize(Amplitude(:, 3)), 'Color', 'b'); hold on
plot(C.dday(1:6:end), normalize(WIND.wu), 'Color', 'k', 'LineWidth', 2)
yline(0, 'LineWidth', 2, 'Color', [.8 .8 .8], 'LineStyle', '-')
grid on
ylabel('Normalized Amp.')
figset_linefont(ax)
figset_date(ax, C.dday)
figset_date_minorticks(ax, C.dday)


% exportgraphics(gcf, 'C:\Users\adm\Desktop\Xingda\2026\0418_0606\picture\current\mode2_3_wuv.png')
exportgraphics(gcf, 'C:\Users\adm\Desktop\Xingda\2026\0418_0606\picture\current\mode2_3_negativewv_wu.png')




