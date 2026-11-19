function r_plot_coastline_here(lim,options)
% This function plots a coastline map within a specified range.
%
% INPUT:
% - lim: A 4-element vector [lon_min lon_max lat_min lat_max].
% - options:
%     - Fill ['on', 'off'(default)]: fills the land areas on the map or not.
%
% USAGE:
%   r_plot_coastline_here([-180 180 -90 90], 'Fill', 'on');
%   r_plot_coastline_here([-180 180 -90 90]);

    arguments
        lim (1,4) double
        options.Fill {mustBeMember(options.Fill, {'on', 'off'})} = 'off'
        options.Grid {mustBeMember(options.Grid, {'on', 'off'})} = 'off'
        options.GridStyle {mustBeMember(options.GridStyle, {':','-','-.','--','none'})} = 'off'
        options.LineWidth {mustBeNumeric}
    end

    ax1 = gca; hold on

    coas = load('coa_i_global.dat');

    if strcmpi(options.Fill, 'on')
        fill_coa = fillseg(coas,repmat(.8,1,3));
        set(fill_coa,'edgecolor','none')
    end

    if strcmpi(options.Grid, 'on')
        grid on
    end

    if strcmpi(options.GridStyle, '.')
        ax1.GridLineStyle = '.';
    elseif strcmpi(options.GridStyle, '-.')
        ax1.GridLineStyle = '-.';
    elseif strcmpi(options.GridStyle, ':')
        ax1.GridLineStyle = ':';
    elseif strcmpi(options.GridStyle, '--')
        ax1.GridLineStyle = '--';
    elseif strcmpi(options.GridStyle, 'none')
        ax1.GridLineStyle = 'none';
    end

    nolegend(plot(coas(:,1),coas(:,2),'color','k'));
    axis equal
    set(ax1,'box','on','TickDir','out','TickLength',[0.02 0.025]*0.4,'LineWidth',1.2)
    set(ax1,'FontSize',14,'FontWeight','bold','FontName','times new roman')

    ax1.XTick = -180:2:180;
    ax1.YTick = -90:90;

    set(ax1,'XTickLabel',strcat(get(gca,'XTickLabel'), '\circE'))
    set(ax1,'YTickLabel',strcat(get(gca,'YTickLabel'), '\circN'))
    set(gca,'Xlim',[lim(1) lim(2)], 'Ylim', [lim(3) lim(4)])
end