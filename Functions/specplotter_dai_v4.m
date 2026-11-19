function h = specplotter_dai_v4(cph, S, ci_u, ci_l, ff, NameValueArgs)
% specplotter_dai_v4 - Modern plotter using argument validation block.
%
% This version uses the `arguments` block for clear, robust input parsing,
% making it self-documenting and easier to use.

% --- Argument Validation Block ---
% This block must be the first thing in the function.
arguments
    % 1. --- Positional (Required) Arguments ---
    % These must be provided in order.
    % We add validation for size and type. (1,:) means it must be a row vector.
    cph (1,:) {mustBeNumeric, mustBeFinite}
    S         % We can't validate "struct or numeric" here, so we check it later.
    ci_u (1,1) {mustBeNumeric, mustBeFinite}
    ci_l (1,1) {mustBeNumeric, mustBeFinite}
    ff (1,1) {mustBeNumeric, mustBeFinite}
    
    % 2. --- Name-Value (Optional) Arguments ---
    % These can be provided in any order using 'Name', Value pairs.
    % We define a default value, making them optional.
    NameValueArgs.Parent (1,1) matlab.graphics.axis.Axes = matlab.graphics.axis.Axes.empty()
    NameValueArgs.lat (1,1) {mustBeNumeric, mustBeFinite} = []
end
% --- End of Argument Validation ---

% After the block, all variables are validated and exist in the workspace.

% --- Custom validation for S ---
if ~isstruct(S) && ~isnumeric(S)
    error('Input "S" must be either a numeric array or a struct.');
end

% --- Handle the Parent Axes (for tiledlayout) ---
if isempty(NameValueArgs.Parent)
    % If no parent is given, create a new figure.
    figure;
    ax1 = gca;
else
    % If a parent axes is provided, use it.
    ax1 = NameValueArgs.Parent;
end
axes(ax1); % Make sure ax1 is the current axes for plotting

% --- Extract optional latitude ---
lat = NameValueArgs.lat;

% [ ... 接下來貼上 specplotter_dai_v3 的所有繪圖程式碼 ... ]
% [ ... The rest of the plotting code from v3 goes here ... ]
% [ ... (from the "yyaxis(ax1, 'left');" line onwards) ... ]

% (以下是 v3 版本的繪圖核心程式碼，無需修改)
% =========================================================================
% STEP 1: Plot on the LEFT Y-AXIS (the primary axis)
% =========================================================================
yyaxis(ax1, 'left'); % Activate the left side
cla; % Clear the axes in case it was used before
hold on;

if isstruct(S)
    loglog(cph, S.CW, 'r-', 'LineWidth', 1.2, 'DisplayName', 'CW (Clockwise)');
    loglog(cph, S.CCW, 'b-', 'LineWidth', 1.2, 'DisplayName', 'CCW (Counter-Clockwise)');
    legend('show', 'Location', 'southwest', 'FontSize', 12);
else
    loglog(cph, S, 'k-', 'LineWidth', 1.2, 'DisplayName', 'Variance');
end

% --- Calculate Axis Limits ---
if isstruct(S)
    Sp = max([S.CW(:); S.CCW(:)]);
else
    Sp = S;
end
ybase10 = floor(log10(Sp));
y_max = 10^(max(ybase10) + 1);
y_min = 10^(min(ybase10));

xbase10 = floor(log10(cph));
x_max = 10^(max(xbase10) + 0.2);
x_min = 10^(min(xbase10) + 0.8);

xp = unique(xbase10);
yp = unique(ybase10);
xtick = 10.^xp;
ytick = 10.^yp;

axis([x_min x_max y_min y_max]);
set(ax1, 'XScale', 'log', 'YScale', 'log', ...
         'XAxisLocation', 'bottom', 'YAxisLocation', 'left', ...
         'box', 'on', ...
         'xtick', xtick, 'ytick', ytick, 'TickLength', [.01 .01], ...
         'FontName', 'Helvetica', 'FontSize', 16, 'fontweight', 'normal', ...
         'YColor', 'k'); % Ensure left y-axis is black
xlabel('Frequency (cph)', 'fontweight', 'bold');
ylabel('Variance / cph', 'fontweight', 'bold');

% --- Plotting Confidence Interval and Resolution ---
citick_x  = 10^(min(xbase10) + 2);
citick_yc = 10^(min(ybase10) + 1);
loglog(citick_x, citick_yc, 'k.', 'markersize', 10, 'HandleVisibility', 'off');
citick_yu = citick_yc * ci_u;
citick_yl = citick_yc * ci_l;
loglog([citick_x, citick_x], [citick_yu, citick_yl], 'k-', 'linewidth', 1.0, 'HandleVisibility', 'off');
citick_xr = citick_x + (0.5 * ff);
citick_xl = citick_x - (0.5 * ff);
loglog([citick_xl, citick_xr], [citick_yu, citick_yu], 'k-', 'linewidth', 1.0, 'HandleVisibility', 'off');
loglog([citick_xl, citick_xr], [citick_yl, citick_yl], 'k-', 'linewidth', 1.0, 'HandleVisibility', 'off');
text(citick_xr, citick_yc, ' 95%', 'FontSize', 16, 'fontweight', 'bold', 'VerticalAlignment', 'middle');

% --- Plotting Tidal and Inertial Frequencies ---
if ~isempty(lat)
    rho = 360/24; 
    inerf = 2 * rho * sind(lat) / 360; 
    K1f = 1 / 23.934; 
    M2f = 1 / 12.421; 

    loglog([K1f, K1f], [y_min, 10^(min(ybase10) + 4)], 'k--', 'linewidth', 1.1, 'HandleVisibility', 'off');
    text(K1f, 10^(min(ybase10) + 0.5), ' K_1', 'FontSize', 12, 'fontweight', 'bold');
    loglog([M2f, M2f], [y_min, 10^(min(ybase10) + 4)], 'k--', 'linewidth', 1.1, 'HandleVisibility', 'off');
    text(M2f, 10^(min(ybase10) + 0.5), ' M_2', 'FontSize', 12, 'fontweight', 'bold');
    inerftick = 10^(min(ybase10) + 0.25);
    loglog([inerf, inerf], [y_min, inerftick], 'r-', 'linewidth', 1.3, 'HandleVisibility', 'off');
    text(inerf, 10^(min(ybase10) + 0.1), ' f', 'color', 'r', 'FontSize', 15, 'fontweight', 'bold');
end
hold off;

% =========================================================================
% STEP 2: Activate the RIGHT Y-AXIS to create the top X-axis
% =========================================================================
yyaxis(ax1, 'right'); % Activate the right side
cla; % Clear this side, we only use it for the top X-axis

% Set scales and limits to match the left side exactly
set(ax1, 'XScale', 'log', 'YScale', 'log', ...
         'XLim', [x_min x_max], 'YLim', [y_min y_max], ...
         'YColor', 'none'); % Make the right Y-axis invisible

% Configure the TOP X-axis
set(ax1, 'XAxisLocation', 'top');
top_ticks = xtick;
top_labels = 1 ./ top_ticks;
set(ax1, 'XTick', top_ticks, ...
         'XTickLabel', arrayfun(@(x) sprintf('%.g', x), top_labels, 'UniformOutput', false));
xlabel('Period (hour)', 'FontName', 'Helvetica', 'FontSize', 16, 'fontweight', 'bold');

% --- Set output handle ---
if nargout > 0
    h = ax1;
end

end