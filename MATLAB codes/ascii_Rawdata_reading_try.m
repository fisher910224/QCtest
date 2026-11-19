%% Xingda Harbor-original file
% 0418-0606
% 20261110 edited
clear; close all; clc; 

%% Path
main_folder = 'C:\Users\adm\Desktop\Xingda';
cd(main_folder)

%% Figure setting
figset_linefont = @(ax) set(ax, 'fontsize', 14, 'linewidth', 1.5, "TickLength", [0.005 0.02], 'TickDir', 'out'); % setting of font size, frame line size, tick length and size
figset_date = @(ax, wave_day) set(ax, 'XTick', floor(wave_day(1)):4:ceil(wave_day(end)), ...
    'Xticklabel', datestr(floor(wave_day(1)):4:ceil(wave_day(end)), 'mm/dd')); % Major ticks which means 4 days
figset_date_minorticks = @(ax, wave_day) set(ax.XAxis, 'Minortick', 'on', 'MinorTickValues', floor(wave_day(1)):1:ceil(wave_day(end))); % Minor ticks which means one day

%% Load data
data_folder = "C:\Users\adm\Desktop\Xingda\107884-ascii";
% datestr(Data.Average_Time)
% fnms = fieldnames(df.Data);

dd = dir(fullfile(data_folder, "*.mat"));
variable_names = {"time", "datetime", "ASTQua", "Dist", "Status", "Pitch", "Roll"};
for jj = 1:length(variable_names)
    Burst.((variable_names{jj})) = cell(5, 1);
    BurstRawAltimeter.((variable_names{jj})) = cell(5, 1);
end

AmpBeam5_raw = cell(5, 1);
Amptime_raw = cell(5, 1);

for ii = 1:5
    df = load(fullfile(dd(ii).folder, dd(ii).name));
    fnms = string(fieldnames(df.Data));
    for jj = 1:length(fnms)
        if startsWith(fnms(jj), "Burst_")
            % fprintf(fnms(jj) + "\n");
            if contains(fnms(jj), "_Time")
                fprintf(fnms(jj) + "\n");
                Burst.time{ii} = df.Data.((fnms(jj)));
                Burst.datetime{ii} = datetime(Burst.time{ii}, "ConvertFrom", "datenum");
            elseif contains(fnms(jj), "Dist") && endsWith(fnms(jj), "AST")
                fprintf(fnms(jj) + "\n");
                Burst.Dist{ii} = df.Data.((fnms(jj)));
            elseif contains(fnms(jj), "QualityAST")
                fprintf(fnms(jj) + "\n");
                Burst.ASTQua{ii} = df.Data.((fnms(jj)));
            elseif endsWith(fnms(jj), "rStatus")
                fprintf(fnms(jj) + "\n");
                Burst.Status{ii} = df.Data.((fnms(jj)));
            elseif endsWith(fnms(jj), "_Pitch")
                fprintf(fnms(jj) + "\n");
                Burst.Pitch{ii} = df.Data.((fnms(jj)));
            elseif endsWith(fnms(jj), "_Roll")
                fprintf(fnms(jj) + "\n");
                Burst.Roll{ii} = df.Data.((fnms(jj)));
            end

        elseif startsWith(fnms(jj), "BurstRaw")
            if contains(fnms(jj), "_Time")
                fprintf(fnms(jj) + "\n");
                BurstRawAltimeter.time{ii} = df.Data.((fnms(jj)));
                BurstRawAltimeter.datetime{ii} = datetime(BurstRawAltimeter.time{ii}, "ConvertFrom", "datenum");
            elseif contains(fnms(jj), "Dist") && endsWith(fnms(jj), "AST")
                fprintf(fnms(jj) + "\n");
                BurstRawAltimeter.Dist{ii} = df.Data.((fnms(jj)));
            elseif contains(fnms(jj), "QualityAST")
                fprintf(fnms(jj) + "\n");
                BurstRawAltimeter.ASTQua{ii} = df.Data.((fnms(jj)));
            elseif endsWith(fnms(jj), "rStatus")
                fprintf(fnms(jj) + "\n");
                BurstRawAltimeter.Status{ii} = df.Data.((fnms(jj)));
            elseif endsWith(fnms(jj), "_Pitch")
                fprintf(fnms(jj) + "\n");
                BurstRawAltimeter.Pitch{ii} = df.Data.((fnms(jj)));
            elseif endsWith(fnms(jj), "_Roll")
                fprintf(fnms(jj) + "\n");
                BurstRawAltimeter.Roll{ii} = df.Data.((fnms(jj)));
            end
        end
    end

    AmpBeam5_raw{ii} = df.Data.BurstRawAltimeter_AmpBeam5;
    Amptime_raw{ii} = df.Data.BurstRawAltimeter_Time;
end


tt_raw = vertcat(BurstRawAltimeter.datetime{:});
dday_raw = vertcat(BurstRawAltimeter.time{:});
AQ_raw = vertcat(BurstRawAltimeter.ASTQua{:});
DD_raw = vertcat(BurstRawAltimeter.Dist{:});
SS_raw = vertcat(BurstRawAltimeter.Status{:});
PP_raw = vertcat(BurstRawAltimeter.Pitch{:});
RR_raw = vertcat(BurstRawAltimeter.Roll{:});

tt = vertcat(Burst.datetime{:});
dday = vertcat(Burst.time{:});
AQ = vertcat(Burst.ASTQua{:});
DD = vertcat(Burst.Dist{:});
SS = vertcat(Burst.Status{:});
PP = vertcat(Burst.Pitch{:});
RR = vertcat(Burst.Roll{:});

Ampbeam5 = vertcat(AmpBeam5_raw{:});
Amptime = vertcat(Amptime_raw{:});


TTilt = sqrt(PP.^2 + RR.^2);
TTilt_raw = sqrt(PP_raw.^2 + RR_raw.^2);

igg = find(AQ > 0);
ig_st = igg(1);
ig_ed = igg(end);
idx = ig_st:ig_ed;

igg = find(AQ_raw > 0);
ig_st = igg(1);
ig_ed = igg(end);
idx_raw = ig_st:ig_ed;

% % AA = double(AA);
% AAm = houravg(AQ(idx), ig_ed-ig_st+1, 2048)';
% DDm = houravg(DD(idx), ig_ed-ig_st+1, 2048)';
% SSm = houravg(SS(idx), ig_ed-ig_st+1, 2048)';
% ttm = tt(ig_st:2048:ig_ed-2048);
% ttm_dday = datenum(ttm);
% ddaym = dday(ig_st:2048:ig_ed-2048);

load("C:\Users\adm\Desktop\Xingda\2026\0418_0606\PROCESSED_DATA_WAVE.mat")
load("C:\Users\adm\Desktop\Xingda\2026\0418_0606\PROCESSED_DATA_CUR.mat")

%% 
ig = isnat(Wave.Hs_time);
event_period = [floor(dday(idx(1))) ceil(dday(idx(end)))];

fig = figure("OuterPosition", [1 1 1600 1200]);
tiledlayout(4, 1, "TileSpacing", "compact", "Padding", "tight");
% yyaxis left
ax = nexttile;

N_samples = width(Ampbeam5);
% SamplingFrequency = 2*2048;
% range_m = (0:(N_samples-1)).*(Soundspeed./ (2*SamplingFrequency));

scale_factor = 17.2 / 700; % 請依據儀器設定確認實際 bin size (約 0.0245m)
range_m = (1:size(Ampbeam5, 2)) * scale_factor;

contourf(Amptime(idx_raw), range_m(1, :), Ampbeam5(idx_raw, :)', "LineStyle", "none"); hold on
plot(datenum(Wave.filled_time(ig)), 15, "Marker", "^", "MarkerEdgeColor", "k", "MarkerFaceColor", "r")
clbr = colorbar;
clbr.Label.String = "(dB)";
colormap(jet(256))
% xline(datenum(Wave.filled_time(ig')), "linewidth", 1, "Color", "k", "Alpha", 0.5, "HandleVisibility", "off")
% xlim([floor(dday(1)) ceil(dday(end))])
xlim(event_period)
title(ax, sprintf("Amplitude of Beam 5"))
ylim([15 25]); 
ylabel(ax, sprintf("Distance from \nTransducer (m)"))
% grid on

figset_linefont(ax)
figset_date(ax, dday)
figset_date_minorticks(ax, dday)


% ax = nexttile;
% plot(datenum(tt(idx)), AA(idx), "Color", [.8 .8 .8], "DisplayName", "AST score"); hold on
% xline(datenum(Wave.filled_time(ig')), "linewidth", 1, "Color", "r", "Alpha", 0.5, "HandleVisibility", "off")
% plot(ttm_dday, AAm, "Color", "k", "DisplayName", "AST score mean")
% ylim([4000 13000])
% % set(ax, "Yscale", "log")
% title(ax, "AST quality")
% ylabel(ax, "Quality Score")
% legend
% set(ax, "YMinorTick", "off")
% grid on
% figset_linefont(ax)
% figset_date(ax, ttm_dday)
% figset_date_minorticks(ax, ttm_dday)


ax = nexttile;
plot(dday(idx), DD(idx), "Color", [164/255 194/255 244/255], "DisplayName", "AST Distance"); hold on
xline(datenum(Wave.filled_time(ig')), "linewidth", 1, "Color", "r", "Alpha", 0.3, "HandleVisibility", "off")
% plot(ttm_dday, DDm, "Color", "k", "DisplayName", "AST Distance mean")
plot(dday_raw(idx_raw), DD_raw(idx_raw), "Color", "k", "DisplayName", "AST Distance mean")
legend("Location", "southeast", "Box", "off", "NumColumns", 2)
% xline(datenum(Wave.filled_time(ig)), "linewidth", 2, "Color", "r", "Alpha", 0.5)
% dropouts = sum(DDm <= 0 | isnan(DDm) | DDm > 30) / length(DD_raw(idx)) * 100;
ylim([16 19])
xlim(event_period)
% set(ax, "Yscale", "log")
% xlim([floor(dday(1)) ceil(dday(end))])
% title(ax, sprintf("AST Distance, Dropout Rate: %.2f%%", dropouts))
title(ax, sprintf("AST Distance"))
ylabel(ax, "Distance (m)")
grid on
figset_linefont(ax)
figset_date(ax, dday)
figset_date_minorticks(ax, dday)




% yyaxis right
ax = nexttile;
% plot(Wave.Hs_time, Wave.QC.Hs, "Color", "k"); hold on
plot(datenum(Cur.SL_time), Cur.QC.SL, "Color", "k", "DisplayName", "Sea level"); hold on
xline(datenum(Wave.filled_time(ig')), "linewidth", 1, "Color", "r", "Alpha", 0.3, "HandleVisibility", "off")
% legend
title(ax, "Sea Level")
ylabel(ax, "Level (m)")
ylim([16 18])
xlim(event_period)
grid on
% xlabel(ax, "date (mm/dd)")
figset_linefont(ax)
figset_date(ax, dday)
figset_date_minorticks(ax, dday)

ax = nexttile;
plot(datenum(Wave.Hs_time), Wave.with_nan_data.Hs, "Color", "k", "DisplayName", "Hs"); hold on
% plot(datenum(Cur.SL_time), Cur.QC.SL, "Color", "k", "DisplayName", "Sea level"); hold on
xline(datenum(Wave.filled_time(ig')), "linewidth", 1, "Color", "r", "Alpha", 0.3, "HandleVisibility", "off")
% legend
title(ax, "Wave Height")
ylabel(ax, "Hs (m)")
% ylim([16 18])
xlim(event_period)
grid on
xlabel(ax, "date (mm/dd)")
figset_linefont(ax)
figset_date(ax, dday)
figset_date_minorticks(ax, dday)

exportgraphics(fig, fullfile(main_folder, "AST_quality.png"))


%% 
ig = isnat(Wave.Hs_time);
ttm_dday = datenum(ttm);
tt_dday = datenum(tt_raw);

fig = figure("OuterPosition", [1 1 1600 1200]);
tiledlayout(4, 1, "TileSpacing", "compact", "Padding", "tight");
% yyaxis left
ax = nexttile;
plot(dday(idx), AQ(idx), "Color", [164/255 194/255 244/255], "DisplayName", "AST score"); hold on
plot(dday_raw(idx_raw), AQ_raw(idx_raw), "Color", "k", "DisplayName", "AST score mean"); hold on
xline(datenum(Wave.filled_time(ig')), "linewidth", 1, "Color", "r", "Alpha", 0.5, "HandleVisibility", "off")
% plot(ttm_dday, AAm, "Color", "k", "DisplayName", "AST score mean")
ylim([4000 13000])
% set(ax, "Yscale", "log")
title(ax, "AST quality raw")
ylabel(ax, "Quality Score")
legend
set(ax, "YMinorTick", "off")
grid on
figset_linefont(ax)
figset_date(ax, tt_dday)
figset_date_minorticks(ax, tt_dday)


ax = nexttile;
plot(dday(idx), DD(idx), "Color", [164/255 194/255 244/255], "DisplayName", "AST distance"); hold on
plot(dday_raw(idx_raw), DD_raw(idx_raw), "Color", "k", "DisplayName", "AST distance mean"); hold on
xline(datenum(Wave.filled_time(ig')), "linewidth", 1, "Color", "r", "Alpha", 0.3, "HandleVisibility", "off")
% plot(ttm_dday, DDm, "Color", "k", "DisplayName", "AST Distance mean")
legend
% xline(datenum(Wave.filled_time(ig)), "linewidth", 2, "Color", "r", "Alpha", 0.5)
% dropouts = sum(DDm <= 0 | isnan(DDm) | DDm > 30) / length(DD_raw(idx)) * 100;
ylim([16.8 25])
% set(ax, "Yscale", "log")
% xlim([floor(tt_dday(1)) ceil(tt_dday(end))])
% title(ax, sprintf("AST Distance, Dropout Rate: %.2f%%", dropouts))
title(ax, sprintf("AST Distance raw"))
ylabel(ax, "Distance (m)")
grid on
figset_linefont(ax)
figset_date(ax, tt_dday)
figset_date_minorticks(ax, tt_dday)


ax = nexttile;
plot(dday(idx), SS(idx), "Color", "k", "DisplayName", "AST status", "Marker", "o", "MarkerSize", 2); hold on
xline(datenum(Wave.filled_time(ig')), "linewidth", 1, "Color", "r", "Alpha", 0.5, "HandleVisibility", "off")
% plot(ttm_dday, SSm, "Color", "k", "DisplayName", "AST status mean")
% ylim([4000 13000])
ylim([7 12])
% set(ax, "Yscale", "log")
title(ax, "AST status raw")
ylabel(ax, "Quality Score")
legend
set(ax, "YMinorTick", "off")
grid on
figset_linefont(ax)
figset_date(ax, tt_dday)
figset_date_minorticks(ax, tt_dday)


ax = nexttile;
plot(dday_raw(idx_raw), TTilt_raw(idx_raw), "Color", "k", "DisplayName", "Tilt", "Marker", "o", "MarkerSize", 2); hold on
xline(datenum(Wave.filled_time(ig')), "linewidth", 1, "Color", "r", "Alpha", 0.5, "HandleVisibility", "off")
% plot(ttm_dday, SSm, "Color", "k", "DisplayName", "AST status mean")
% ylim([4000 13000])
ylim([0 15])
% set(ax, "Yscale", "log")
title(ax, "Tilt")
ylabel(ax, sprintf("degree (^{\\circ})"))
legend
set(ax, "YMinorTick", "off")
grid on
figset_linefont(ax)
figset_date(ax, tt_dday)
figset_date_minorticks(ax, tt_dday)

exportgraphics(fig, fullfile(main_folder, "AST_TILT_status.png"))

%% 
fig = figure("OuterPosition", [1 1 1920 1080]);
tiledlayout(1, 1, "TileSpacing", "compact", "Padding", "tight");
% ax = nexttile;

ig = isnat(Wave.Hs_time);
event_period = [floor(dday(idx(1))) ceil(dday(idx(end)))];

% yyaxis left
ax = nexttile;

N_samples = width(Ampbeam5);
% SamplingFrequency = 2*2048;
% range_m = (0:(N_samples-1)).*(Soundspeed./ (2*SamplingFrequency));

scale_factor = 17.2 / 700; % 請依據儀器設定確認實際 bin size (約 0.0245m)
range_m = (1:size(Ampbeam5, 2)) * scale_factor;

contourf(Amptime(idx_raw), range_m(1, :), Ampbeam5(idx_raw, :)', "LineStyle", "none"); hold on
plot(datenum(Wave.filled_time(ig)), 15, "Marker", "^", "MarkerEdgeColor", "k", "MarkerFaceColor", "r")
clbr = colorbar;
clbr.Label.String = "(dB)";
colormap(jet(256))
% xline(datenum(Wave.filled_time(ig')), "linewidth", 1, "Color", "k", "Alpha", 0.5, "HandleVisibility", "off")
% xlim([floor(dday(1)) ceil(dday(end))])
xlim(event_period)
title(ax, sprintf("Amplitude of Beam 5"))
% ylim([15 25]); 
ylabel(ax, sprintf("Distance from \nTransducer (m)"))
% grid on

figset_linefont(ax)
figset_date(ax, dday)
figset_date_minorticks(ax, dday)

exportgraphics(fig, fullfile(main_folder, "AST_AmpBeam5.png"))

