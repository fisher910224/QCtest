function h = specplotter_dai_v5(cph, S, ci_u, ci_l, ff, NameValueArgs)
% specplotter_dai_v5 - Corrects read-only property error with yyaxis.
%
% VERSION 5: Removes the manual setting of 'YAxisLocation' after yyaxis is
% called, which is now a read-only property, ensuring full compatibility.

% --- Argument Validation Block ---
arguments
    cph (1,:) {mustBeNumeric, mustBeFinite}
    S
    ci_u (1,1) {mustBeNumeric, mustBeFinite}
    ci_l (1,1) {mustBeNumeric, mustBeFinite}
    ff (1,1) {mustBeNumeric, mustBeFinite}
    NameValueArgs.Parent (1,1) matlab.graphics.axis.Axes = matlab.graphics.axis.Axes.empty()
    NameValueArgs.lat (1,1) {mustBeNumeric, mustBeFinite} = []
end

% --- Custom validation for S ---
if ~isstruct(S) && ~isnumeric(S)
    error('Input "S" must be either a numeric array or a struct.');
end

% --- Handle the Parent Axes ---
if isempty(NameValueArgs.Parent)
    figure;
    ax1 = gca;
else
    ax1 = NameValueArgs.Parent;
end
axes(ax1);

lat = NameValueArgs.lat;

% =========================================================================
% STEP 1: Plot on the LEFT Y-AXIS
% =========================================================================
yyaxis(ax1, 'left');
cla;
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

% --- THE FIX IS HERE ---
% The property 'YAxisLocation' has been removed from this set command.
% The yyaxis('left') command already handled this.
set(ax1, 'XScale', 'log', 'YScale', 'log', ...
         'XAxisLocation', 'bottom', ... % <-- 'YAxisLocation' was here
         'box', 'on', ...
         'xtick', xtick, 'ytick', ytick, 'TickLength', [.01 .01], ...
         'FontName', 'Helvetica', 'FontSize', 16, 'fontweight', 'normal', ...
         'YColor', 'k');

xlabel('Frequency (cph)', 'fontweight', 'bold');
ylabel('Variance / cph', 'fontweight', 'bold');

% ... (Rest of the plotting code is identical to v4) ...
% [ ... 剩下的繪圖程式碼與 v4 完全相同 ... ]
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
yyaxis(ax1, 'right');
cla;

set(ax1, 'XScale', 'log', 'YScale', 'log', ...
         'XLim', [x_min x_max], 'YLim', [y_min y_max], ...
         'YColor', 'none'); 

set(ax1, 'XAxisLocation', 'top');
top_ticks = xtick;
top_labels = 1 ./ top_ticks;
set(ax1, 'XTick', top_ticks, ...
         'XTickLabel', arrayfun(@(x) sprintf('%.g', x), top_labels, 'UniformOutput', false));
xlabel('Period (hour)', 'FontName', 'Helvetica', 'FontSize', 16, 'fontweight', 'bold');

if nargout > 0
    h = ax1;
end

end