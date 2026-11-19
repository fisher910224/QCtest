function h = specplotter(cph, S, ci_u, ci_l, ff, lat);
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
% for making double x-axis, check http://www.mathworks.com/help/matlab/creating_plots/graph-with-multiple-x-axes-and-y-axes.html

if nargin < 6; lat = []; end

if isstruct(S) == 0;
loglog(cph, S,'k-', 'linewidth', 1.2);

elseif isstruct(S) == 1;
    loglog(cph, S.CW,'k-', 'linewidth', 1.2);hold on;
     loglog(cph, S.CCW,'b-', 'linewidth', 1.2);
end

ax1 = gca; % current axes
ax = axis;

if isstruct(S) == 1;
      if max(S.CW) > max(S.CCW);
          Sp = S.CW;
      elseif max(S.CW) < max(S.CCW);
          Sp = S.CCW;
      elseif max(S.CW) == max(S.CCW);
          Sp = S.CW;
      end
end

if isstruct(S) == 0;
Sp = S;
end

ybase10 = floor( log10(Sp) / log10(10));  % find the closest power in y-axis
y_max = 10^(max(ybase10) + 1);
y_min = 10^(min(ybase10));

xbase10 = floor( log10(cph) / log10(10)); 
x_max = 10^(max(xbase10) + 0.2);
x_min = 10^(min(xbase10) + 0.8 );

xp = unique(xbase10); % power in x axis
yp = unique(ybase10); % power in y axis

xtick = [10.^xp; x_max];
ytick = [10.^yp; y_max];

axis([x_min x_max y_min y_max]);
set(ax1, 'XAxisLocation', 'bottom', 'YAxisLocation', 'left');
set(ax1, 'xtick', xtick(1: end-1),'TickLength' , [.01 .01]);
set(ax1, 'ytick', ytick, 'TickLength'  , [.01 .01]);
set(ax1, 'box', 'off');
% plotting confidence interval;
citick_x  = 10^(min(xbase10) + 2 ); % x location of confidence interval 
citick_yc = 10^(min(ybase10) + 1); % point of center of confidence interval
hold on
loglog(citick_x, citick_yc, 'k.','markersize',10);
%citick_yu = citick_yc + citick_yc * 0.5*( ci_u - ci_l ); % upper bound for confidence interval
%citick_yl =  citick_yc - citick_yc* 0.5*( ci_u - ci_l ); % lower bound for confidence interval
citick_yu = citick_yc * ( ci_u ); % upper bound for confidence interval % Change it @ Oct-2-2015, this is right
citick_yl =  citick_yc * ( ci_l ); % lower bound for confidence interval
% plotting spectra confidence interval
loglog([citick_x, citick_x ],[citick_yu, citick_yl], 'k-', 'linewidth', 1.0);

% plotting signal resolution (Nyquist frequency)
citick_xr = citick_x + (0.5* ff);        % right bound for frequency resolution
citick_xl =  citick_x - (0.5* ff);       % left bound for frequency resolution
loglog([citick_xl, citick_xr ],[citick_yu, citick_yu], 'k-', 'linewidth', 1.0);
loglog([citick_xl, citick_xr ],[citick_yl, citick_yl], 'k-', 'linewidth', 1.0);
text(citick_xr, citick_yc, ' 95%', 'FontSize', 16,'fontweight', 'bold');

if nargin < 6
xlabel(ax1,'Frequency (cph)','FontName','Helvetica','FontSize', 16,'fontweight', 'bold');
ylabel(ax1,'Variance/cph','FontName','Helvetica','FontSize', 16,'fontweight', 'bold');
set(gca, 'FontName','Helvetica','FontSize',16,'fontweight', 'bold','fontsize', 16);
end
% if provide local latitude, K1, M2 and local inertial frequency are drawn
% in the figure
if nargin == 6 ;
    
%% plotting some tidal frequency lines for better visulization
% rho = 7.2921*10^-5; % earth's rotation is 7.2921*10^-5 (cycle s-1), from 2*pi / 86400 s
% rho = rho*3600; % convert from cycle per second to cycle per hour (this has more accuracy

rho = 1/ 86400; % Use this then convert to period will make senses. Add @ Oct 1 2015.
rho = rho*3600;

%rho = 2*pi / 24; % earth's rotation rate, in cycle per hour, from 2*pi / 24 h
inerf = 2*rho*sind(lat); % local inertial frequency

% K1f = 2*pi / 23.934; % frequency of K1 tide, in cph
% M2f = 2*pi / 12.421; % frequency of M2 tide, in cp

K1f = 1 / 23.934; % frequency of K1 tide, in cph, % Use this then convert to period will make senses. Add @ Oct 1 2015.
M2f = 1 / 12.421; % frequency of M2 tide, in cp

% drawing line of K1 frequency
K1ftick = 10^(min(ybase10) + 0.5);
loglog([K1f , K1f  ],[y_min, K1ftick], 'k-', 'linewidth', 1.1);
text(K1f, 10^(min(ybase10) + 0.56), ' K_1','FontSize', 12,'fontweight', 'bold');

% drawing line of M2 frequency
M2ftick = 10^(min(ybase10) + 0.5);
loglog([M2f , M2f  ],[y_min, M2ftick], 'k-', 'linewidth', 1.1);
text(M2f, 10^(min(ybase10) + 0.56), ' M_2','FontSize', 12,'fontweight', 'bold');

% drawing line of M2 frequency
inerftick = 10^(min(ybase10) + 0.25);
loglog([inerf , inerf  ],[y_min, inerftick], 'r-', 'linewidth', 1.3);
text(inerf, 10^(min(ybase10) + 0.16), ' f', 'color',[1 0 0],'FontSize', 15,'fontweight', 'bold');


set(ax1, 'FontName', 'Helvetica', 'FontSize',16,'fontweight', 'normal') % set command specifies tick font size
xlabel(ax1,'Frequency (cph)','FontName','Helvetica','FontSize', 16,'fontweight', 'bold'); % this specifies "label fonts"
ylabel(ax1,'Variance/cph','FontName','Helvetica','FontSize', 16,'fontweight', 'bold'); 

%set(ax1, 'FontName','Times New Roman','FontSize',12,'fontweight', 'bold','fontsize', 12);
% 

% below adding top x-axis. Very FUCKING ANNOYING. STUPID MATLAB. FUCK
% This can be done in GMT by using one line command

ax2 = axes('position', get(ax1, 'position')); % Create a new axes in the same position as the first one, overlaid on top
%%
set(ax2,'box','off','color','none');
 set(ax2, 'XAxisLocation', 'top', 'YAxisLocation', 'right','xticklabel',[]);
 set(ax2, 'XLim', get(ax1, 'XLim'),'xdir','reverse','xscale','log');
 set(ax2, 'YLim', get(ax1, 'YLim'));
 %%
 

set(ax2, 'xscale','log')%, 'xdir', 'reverse');
%grid on
%set(ax2, 'XTiCK', flipud(1./xtick(1: end-1)),'TickLength' , [.93 .63]);

UpXTickLabels = 1./xtick;
%set(ax2, 'XTickLabel', []);
p10 = log10(UpXTickLabels);
p10 = p10(2: end-1);

mp10={};
for nn = 1: numel(p10);
    mp = strcat( ['10^{', num2str( p10(nn) ), '}'] ); % Generating tick texts, so dumb.
    % adding { } is because to prevent the power has more than one
    % character.
    mp10 = cat(1, mp10, mp);
end

% The only way to put superscript on tick label... is to use function text.
% so dumb...
text([flipud(xtick(2:end-1))]', 0.967.*[y_max.*ones(1, max(size(xtick(2:end-1) )))  ], ...
    mp10, ...
    'hor','center','FontName', 'Helvetica', 'FontSize',16,'fontweight', 'normal');
% I decide just not to plot the rightmost tick for better visulization.

set(ax2, 'YTickLabel', []); % just left side is enough. so we close right hand side.
set(ax2, 'FontSize',16,'fontweight', 'normal') ;% set command specifies tick font size
xlabel(ax2,'Period (hour)','FontName','Helvetica','FontSize', 16,'fontweight', 'bold'); % this specifies "label fonts"
%title('Period (hour)','FontName','Times New Roman','FontSize', 12,'fontweight', 'bold');

end