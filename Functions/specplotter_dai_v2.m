function [ax1, ax2] = specplotter_dai_v2(varargin)
% specplotter_dai - A modernized plotter for spectral analysis results.
%
% This function creates a professional log-log spectral plot with an optional
% secondary X-axis for Period. It is fully compatible with tiledlayouts
% and standard figure/subplot usage.
%
% SYNTAX:
%   [ax1, ax2] = specplotter_dai(cph, S, ci_u, ci_l, ff, Name, Value, ...)
%   [ax1, ax2] = specplotter_dai(parent, cph, S, ..., Name, Value, ...)
%
% Ting-Yu Dai Oct-9-2025 @National Sun Yet-Sen University D.O.

% --- Input Parsing with Argument Validation ---
% Check if the first argument is an axes handle
if ~isempty(varargin) && isa(varargin{1}, 'matlab.graphics.axis.Axes')
    parent = varargin{1};
    args = varargin(2:end);
else
    parent = [];
    args = varargin;
end

% Use an input parser for robust name-value pair handling
p = inputParser;
p.addRequired('cph', @isnumeric);
p.addRequired('S', @(x) isnumeric(x) || isstruct(x));
p.addRequired('ci_u', @isnumeric);
p.addRequired('ci_l', @isnumeric);
p.addRequired('ff', @isnumeric);
p.addParameter('Latitude', [], @(x) isscalar(x) || isempty(x));
p.addParameter('LegendShow', 'off', @(x) ismember(x, {'on', 'off'}));
p.addParameter('LegendBox', 'on', @(x) ismember(x, {'on', 'off'}));
p.addParameter('Linewidth', 1.2, @isscalar);
p.addParameter('NumColumns', 1, @isscalar);
p.parse(args{:});

% Extract variables from the parser
cph = p.Results.cph;
S = p.Results.S;
ci_u = p.Results.ci_u;
ci_l = p.Results.ci_l;
ff = p.Results.ff;
options = p.Results;

% --- Set up the target axes ---
if isempty(parent)
    % If no parent axes is provided, get the current one (or create one).
    ax1 = gca;
else
    % If a parent axes is provided (e.g., from nexttile), use it.
    ax1 = parent;
end
axes(ax1); % Make sure ax1 is the active axes for plotting.
cla(ax1); % Clear the axes before plotting.
hold(ax1, 'on');

% --- Main Plotting on ax1 ---
if isstruct(S)
    loglog(ax1, cph, S.CW, 'r-', 'LineWidth', options.Linewidth, 'DisplayName', 'CW');
    loglog(ax1, cph, S.CCW, 'b-', 'LineWidth', options.Linewidth, 'DisplayName', 'CCW');
else
    loglog(ax1, cph, S, 'k-', 'LineWidth', options.Linewidth);
end

% Add legend if requested
if strcmp(options.LegendShow, 'on') && isstruct(S)
    legend(ax1, 'show', 'FontSize', 12, 'Box', options.LegendBox, 'NumColumns', options.NumColumns);
end

% --- Calculate Axis Limits and Ticks ---
if isstruct(S)
    Sp_max = max([S.CW(:); S.CCW(:)]);
else
    Sp_max = max(S(:));
end
ybase10_max = floor(log10(Sp_max));
y_max = 10^(ybase10_max + 1);
y_min_val = min(S.CW(S.CW>0)); % find a reasonable minimum
y_min = 10^floor(log10(y_min_val));

xbase10 = floor(log10(cph));
x_max = 10^(max(xbase10) + 0.2);
x_min = 10^(min(xbase10));

xtick_powers = unique(xbase10);
xtick = 10.^xtick_powers;
ytick_powers = floor(log10(y_min)):(ybase10_max+1);
ytick = 10.^ytick_powers;

axis(ax1, [x_min x_max y_min y_max]);
set(ax1, 'box', 'on', 'xtick', xtick, 'ytick', ytick);

% --- Plot Confidence Interval, Resolution, and Tides ---
% (This section is mostly unchanged, but now explicitly plots on ax1)
citick_x  = 10^(min(xbase10) + 1.5);
citick_yc = 10^(floor(log10(y_min)) + 0.5);
loglog(ax1, citick_x, citick_yc, 'k.', 'markersize', 10, 'HandleVisibility', 'off');
citick_yu = citick_yc * ci_u;
citick_yl = citick_yc * ci_l;
loglog(ax1, [citick_x, citick_x], [citick_yu, citick_yl], 'k-', 'linewidth', 1.0, 'HandleVisibility', 'off');
citick_xr = citick_x + (0.5 * ff);
citick_xl = citick_x - (0.5 * ff);
loglog(ax1, [citick_xl, citick_xr], [citick_yu, citick_yu], 'k-', 'linewidth', 1.0, 'HandleVisibility', 'off');
loglog(ax1, [citick_xl, citick_xr], [citick_yl, citick_yl], 'k-', 'linewidth', 1.0, 'HandleVisibility', 'off');
text(ax1, citick_xr, citick_yc, ' 95%', 'FontSize', 16, 'fontweight', 'bold', 'VerticalAlignment', 'middle');

K1f = 1 / 23.934;
M2f = 1 / 12.421;
loglog(ax1, [K1f, K1f], [y_min, 10^(floor(log10(y_min)) + 1.5)], 'k-', 'linewidth', 1.1, 'HandleVisibility', 'off');
text(ax1, K1f, 10^(floor(log10(y_min)) + 0.1), ' K_1', 'FontSize', 12, 'fontweight', 'bold', 'HorizontalAlignment', 'center');
loglog(ax1, [M2f, M2f], [y_min, 10^(floor(log10(y_min)) + 1.5)], 'k-', 'linewidth', 1.1, 'HandleVisibility', 'off');
text(ax1, M2f, 10^(floor(log10(y_min)) + 0.1), ' M_2', 'FontSize', 12, 'fontweight', 'bold', 'HorizontalAlignment', 'center');

if ~isempty(options.Latitude)
    lat = options.Latitude;
    rho = 3600 / 86400 * 360; % Earth rotation rate in deg/hour
    inerf = 2 * rho * sind(lat) / 360; % Inertial frequency in cph
    loglog(ax1, [inerf, inerf], [y_min, 10^(floor(log10(y_min)) + 0.25)], 'r-', 'linewidth', 1.3, 'HandleVisibility', 'off');
    text(ax1, inerf, 10^(floor(log10(y_min)) + 0.05), ' f', 'color', 'r', 'FontSize', 15, 'fontweight', 'bold');
end

% --- Finalize ax1 Appearance ---
set(ax1, 'FontName', 'Helvetica', 'FontSize', 16);
xlabel(ax1, 'Frequency (cph)', 'fontweight', 'bold');
ylabel(ax1, 'Variance/cph', 'fontweight', 'bold');
hold(ax1, 'off');

% =========================================================================
% Create a robust, interactive second X-axis for Period (THE MODERN WAY)
% =========================================================================
% Ensure graphics are drawn so we can get the final position of ax1
drawnow;
ax1_pos = get(ax1, 'Position');

% Create the second axes (ax2) and place it exactly on top of ax1
ax2 = axes('Position', ax1_pos, ...
           'Color', 'none', ...
           'box', 'on');

% Configure ax2 for the top X-axis (Period)
set(ax2, 'XAxisLocation', 'top', ...
         'YAxisLocation', 'right', ...
         'YTick', [], ...
         'XScale', 'log', 'YScale', 'log');

% Calculate and set the top ticks and labels
bottom_ticks = get(ax1, 'XTick');
top_labels = 1 ./ bottom_ticks;
set(ax2, 'XTick', bottom_ticks, ...
         'XTickLabel', arrayfun(@(x) sprintf('%.g', x), top_labels, 'UniformOutput', false));

% Set the limits to match ax1 and add a label
set(ax2, 'XLim', get(ax1, 'XLim'), ...
         'YLim', get(ax1, 'YLim'));
xlabel(ax2, 'Period (hour)', 'FontSize', 16, 'fontweight', 'bold');
set(ax2, 'FontName', 'Helvetica', 'FontSize', 16);

% Link the Y-axes so zooming is synchronized vertically
linkaxes([ax1, ax2], 'y');

% Make the bottom axes (ax1) the active one for any further user interactions
axes(ax1);

end
