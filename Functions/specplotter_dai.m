function [ax1, ax2] = specplotter_dai(cph, S, ci_u, ci_l, ff, options);
% This is a plotter for plotting results from spec_f.m or spec_fv.m
% Plotting in a more professional way
% Input: cph (frequency)
%          S (spectra). If rotary spectra is gigen, then black line is for
%          CW and the blue line is for CCW.
%          ci_l: upper level of confidence interval
%          ci_m: lower level of confidence interval
%          ff: fendemental frequency, unit in cycle per hour.
%          lat: latitude in degree (option, this is for drawing inertial period on the spectral plot) 
%         All output should be from spec_f.m or spec_fv.m
%         Ying-Chih Fang Sep-29-2015 @University of Alaska Fairbanks 16:23 AKDT
%         Ting-Yu Dai Oct-9-2025 @National Sun Yet-Sen University D.O. 11:25 GMT+8
% for making double x-axis, check http://www.mathworks.com/help/matlab/creating_plots/graph-with-multiple-x-axes-and-y-axes.html
arguments
        cph {mustBeNumeric}
        S
        ci_u {mustBeNumeric}
        ci_l {mustBeNumeric}
        ff {mustBeNumeric}
        options.Latitude {mustBeScalarOrEmpty} = []
        options.LegendShow {mustBeMember(options.LegendShow, {'on', 'off'})} = 'off'
        options.LegendBox {mustBeMember(options.LegendBox, {'on', 'off'})} = 'on'
        options.LegendLocation {mustBeMember(options.LegendLocation, ...
            {'north', 'northeast', 'east', 'southeast', ...
            'south', 'southwest', 'west', 'northwest', ...
            'northoutside', 'southoutside', 'eastoutside', 'westoutside', ...
            'best', 'bestoutside', 'layout'})} = 'northeast'
        options.Linewidth {mustBeScalarOrEmpty} = 1.2
        options.NumColumns {mustBeScalarOrEmpty} = 1
        options.Title {mustBeText} = ''
        options.eightHR {mustBeMember(options.eightHR, {'on', 'off'})} = 'off'
        options.sixHR {mustBeMember(options.sixHR, {'on', 'off'})} = 'off'
        options.fourHR {mustBeMember(options.fourHR, {'on', 'off'})} = 'off'
        % options.Parent (1,1) matlab.graphics.axis.Axes = matlab.graphics.axis.Axes.empty()
end

%% 
% ax1 = nexttile; % current axes
ax1 = gca;
if isstruct(S) == 0
loglog(cph, S,'k-', 'linewidth', options.Linewidth);

elseif isstruct(S) == 1
    loglog(cph, S.CW,'r-', 'linewidth', options.Linewidth, 'DisplayName', 'CW');hold on;
    loglog(cph, S.CCW,'b-', 'linewidth', options.Linewidth, 'DisplayName', 'CCW');
end

if strcmp(options.LegendShow, 'on')
        if isstruct(S)
            legend('show', 'FontSize', 12, 'box', options.LegendBox, 'NumColumns', options.NumColumns, ...
                'Location', options.LegendLocation);
        end
end


% ax = axis;

if isstruct(S) == 1
      if max(S.CW) > max(S.CCW)
          Sp = S.CW;
      elseif max(S.CW) < max(S.CCW)
          Sp = S.CCW;
      elseif max(S.CW) == max(S.CCW)
          Sp = S.CW;
      end
else 
    Sp = S;
end

ybase10 = floor( log10(Sp) / log10(10));  % find the closest power in y-axis
y_max = 10^(max(ybase10) + 1);
y_min = 10^(min(ybase10));

xbase10 = floor( log10(cph) / log10(10)); 
x_max = 10^(max(xbase10) + 0.2);
x_min = 10^(min(xbase10) + 0.8 );

xp = unique(xbase10); % power in x axis
% yp = unique(ybase10); % power in y axis

xtick = [10.^xp; x_max];
% ytick = [10.^yp; y_max];

axis([x_min x_max y_min y_max]);
% set(ax1, 'XAxisLocation', 'bottom', 'YAxisLocation', 'left');
% set(ax1, 'xtick', xtick(1: end-1),'TickLength' , [.01 .01]);
% set(ax1, 'ytick', ytick, 'TickLength'  , [.01 .01]);
set(ax1, 'box', 'off');
% plotting confidence interval;
citick_x  = 10^(min(xbase10) + 2.5 ); % x location of confidence interval 
citick_yc = 10^(min(ybase10) + 4); % point of center of confidence interval
hold on
loglog(citick_x, citick_yc, 'k.','markersize',10, 'HandleVisibility', 'off');
%citick_yu = citick_yc + citick_yc * 0.5*( ci_u - ci_l ); % upper bound for confidence interval
%citick_yl =  citick_yc - citick_yc* 0.5*( ci_u - ci_l ); % lower bound for confidence interval
citick_yu = citick_yc * ( ci_u ); % upper bound for confidence interval % Change it @ Oct-2-2015, this is right
citick_yl =  citick_yc * ( ci_l ); % lower bound for confidence interval
% plotting spectra confidence interval
loglog([citick_x, citick_x ],[citick_yu, citick_yl], 'k-', 'linewidth', 1.0, 'HandleVisibility', 'off');

% plotting signal resolution (Nyquist frequency)
citick_xr = citick_x + (0.5* ff);        % right bound for frequency resolution
citick_xl =  citick_x - (0.5* ff);       % left bound for frequency resolution
loglog([citick_xl, citick_xr ],[citick_yu, citick_yu], 'k-', 'linewidth', 1.0, 'HandleVisibility', 'off');
loglog([citick_xl, citick_xr ],[citick_yl, citick_yl], 'k-', 'linewidth', 1.0, 'HandleVisibility', 'off');
text(citick_xr, citick_yc, ' 95%', 'FontSize', 16,'fontweight', 'bold');

% if nargin < 6
%     xlabel(ax1,'Frequency (cph)','FontName','Helvetica','FontSize', 16,'fontweight', 'bold');
%     ylabel(ax1,'Variance/cph','FontName','Helvetica','FontSize', 16,'fontweight', 'bold');
%     set(gca, 'FontName','Helvetica','FontSize',16,'fontweight', 'bold','fontsize', 16);
% end
% if provide local latitude, K1, M2 and local inertial frequency are drawn
% in the figure

%% plotting some tidal frequency lines for better visulization
% rho = 7.2921*10^-5; % earth's rotation is 7.2921*10^-5 (cycle s-1), from 2*pi / 86400 s
% rho = rho*3600; % convert from cycle per second to cycle per hour (this has more accuracy

rho = 1/ 86400; % Use this then convert to period will make senses. Add @ Oct 1 2015.
rho = rho*3600;

% K1f = 2*pi / 23.934; % frequency of K1 tide, in cph
% M2f = 2*pi / 12.421; % frequency of M2 tide, in cp

K1f = 1 / 23.934; % frequency of K1 tide, in cph, % Use this then convert to period will make senses. Add @ Oct 1 2015.
M2f = 1 / 12.421; % frequency of M2 tide, in cp

% drawing line of K1 frequency
% K1ftick = 10^(min(ybase10) + 2);
% loglog([K1f , K1f],[y_min, K1ftick], 'k-', 'linewidth', 1.1, 'HandleVisibility', 'off');
xline(K1f,'k--', 'linewidth', 1.1, 'HandleVisibility', 'off');
text(K1f, 10^(min(ybase10) + 0.8), ' K_1','FontSize', 12,'fontweight', 'bold');

% drawing line of M2 frequency
% M2ftick = 10^(min(ybase10) + 2);
% loglog([M2f , M2f],[y_min, M2ftick], 'k-', 'linewidth', 1.1, 'HandleVisibility', 'off');
xline(M2f, 'k--', 'linewidth', 1.1, 'HandleVisibility', 'off');
text(M2f, 10^(min(ybase10) + 0.8), ' M_2','FontSize', 12,'fontweight', 'bold');

if ~isempty(options.Latitude) 
    lat = options.Latitude;
    %rho = 2*pi / 24; % earth's rotation rate, in cycle per hour, from 2*pi / 24 h
    inerf = 2*rho*sind(lat); % local inertial frequency
    % drawing line of M2 frequency
    inerftick = 10^(min(ybase10) + 0.25);
    % loglog([inerf , inerf  ],[y_min, inerftick], 'r-', 'linewidth', 1.3, 'HandleVisibility', 'off');
    xline(inerf, 'r--', 'linewidth', 1.3, 'HandleVisibility', 'off');
    text(inerf, 10^(min(ybase10) + 0.16), ' f', 'color',[1 0 0],'FontSize', 15,'fontweight', 'bold');
end

if strcmpi(options.eightHR, 'on') == 1
    xline(1/8, '--', 'linewidth', 1.3, 'HandleVisibility', 'off', 'Color', [.3 .3 .3])
    text(1/8, 10^(min(ybase10) - 0.15), '8 Hr', 'color',[.3 .3 .3],'FontSize', 15,'fontweight', 'bold', 'HorizontalAlignment', 'center')
end

if strcmpi(options.sixHR, 'on') == 1
    xline(1/6, '--', 'linewidth', 1.3, 'HandleVisibility', 'off', 'Color', [.3 .3 .3])
    text(1/6, 10^(min(ybase10) - 0.15), '6 Hr', 'color',[.3 .3 .3],'FontSize', 15,'fontweight', 'bold', 'HorizontalAlignment', 'center')
end

if strcmpi(options.fourHR, 'on') == 1
    xline(1/4, '--', 'linewidth', 1.3, 'HandleVisibility', 'off', 'Color', [.3 .3 .3])
    text(1/4, 10^(min(ybase10) - 0.15), '4 Hr', 'color',[.3 .3 .3],'FontSize', 15,'fontweight', 'bold', 'HorizontalAlignment', 'center')
end

set(ax1, 'FontName', 'Helvetica', 'FontSize',16,'fontweight', 'normal') % set command specifies tick font size
xlabel(ax1,'Frequency (cph)','FontName','Helvetica','FontSize', 16,'fontweight', 'bold'); % this specifies "label fonts"
ylabel(ax1,'Variance/cph','FontName','Helvetica','FontSize', 16,'fontweight', 'bold'); 

%set(ax1, 'FontName','Times New Roman','FontSize',12,'fontweight', 'bold','fontsize', 12);
% 

% below adding top x-axis. Very FUCKING ANNOYING. STUPID MATLAB. FUCK
% This can be done in GMT by using one line command
hold off
ax2 = axes('position', get(ax1, 'position')); % Create a new axes in the same position as the first one, overlaid on top
% loglog(1./citick_x, 1./citick_yc, 'k.','markersize',10, 'HandleVisibility', 'off', 'Visible', 'off');
% linkaxes([ax1, ax2], 'x');
set(ax2, 'XAxisLocation', 'top', ...
    'YAxisLocation', 'right', ...
    'box', 'off', 'color', 'none');%,'xticklabel',[]);

ax2_xlim = flip(1./get(ax1, 'XLim'));

set(ax2, 'XLim', ax2_xlim, 'xdir', 'reverse', 'xscale', 'log');
set(ax2, 'YLim', get(ax1, 'YLim'), 'YScale', 'log');
ax2_xticklabel = get(ax2, 'XTickLabels');
ax2_xtick = get(ax2, 'XTick');
set(ax2, 'YTickLabel', [], 'XTickLabel', []); % just left side is enough. so we close right hand side.
text(ax2_xtick, 0.6.*(y_max.*ones(1, max(size(xtick(2:end-1))))), ax2_xticklabel, ...
    "FontSize", 16, "HorizontalAlignment", "center")
set(ax2, 'FontSize',16,'fontweight', 'normal') ;% set command specifies tick font size
% ax2_xtick

if strcmp(options.Title, '') 
    xlabel(ax2,'Period (hour)','FontName','Helvetica','FontSize', 16,'fontweight', 'bold'); % this specifies "label fonts"
else
    title_string = sprintf('Period (hour) %s', options.Title);
    xlabel(ax2, title_string, 'FontName','Helvetica','FontSize', 16,'fontweight', 'bold'); % this specifies "label fonts"
end

% cla;
%%

% set(ax2, 'xscale','log')%, 'xdir', 'reverse');
%grid on
% set(ax2, 'XTiCK', flipud(1./xtick(1: end-1)),'TickLength' , [.93 .63]);

% UpXTickLabels = 1./xtick;
% %set(ax2, 'XTickLabel', []);
% p10 = log10(UpXTickLabels);
% p10 = p10(2: end-1);
% 
% mp10={};
% for nn = 1: numel(p10)
%     mp = strcat( ['10^{', num2str( p10(nn) ), '}'] ); % Generating tick texts, so dumb.
%     % adding { } is because to prevent the power has more than one
%     % character.
%     mp10 = cat(1, mp10, mp);
% end
% 
% % The only way to put superscript on tick label... is to use function text.
% % so dumb...
% % text([flipud(xtick(2:end-1))]', 0.967.*(y_max.*ones(1, max(size(xtick(2:end-1) )))  ), ...
% %     mp10, ...
% %     'hor','center','FontName', 'Helvetica', 'FontSize',16,'fontweight', 'normal');
% text([flipud(xtick(2:end-1))]', 1.04.*(y_max.*ones(1, max(size(xtick(2:end-1) )))  ), ...
%     mp10, ...
%     'hor','center','FontName', 'Helvetica', 'FontSize',16,'fontweight', 'normal');
% I decide just not to plot the rightmost tick for better visulization.

%title('Period (hour)','FontName','Times New Roman','FontSize', 12,'fontweight', 'bold');

end