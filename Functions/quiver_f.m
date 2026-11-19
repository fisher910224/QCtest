function [Xscale] = quiver_f(tt, Udata, Vdata, options)

    arguments
        tt 
        Udata 
        Vdata
        options.LineWidth {mustBeNumeric} = 1
        options.Color {mustBeText} = 'k'
        options.ShowArrowHead {mustBeMember(options.ShowArrowHead, {'on', 'off'})} = 'off'
        options.AutoScale {mustBeMember(options.AutoScale, {'on', 'off'})} = 'off'
    end

set(gca,'units','pixels');
ppos = get(gca,'position'); % get the x-y position and normalized lengths of x- and y-axis of the upper panel
set(gca,'units','norm');

YYlim = max([abs(Udata) abs(Vdata)]);

% if ~isempty(options.Xlim)
%     Xlim = options.Xlim;
%     Xscale = (diff([time(Xlim(1)) time(Xlim(end))])/diff([-(max(Ylim)) max(Ylim)]))*(ppos(4)/ppos(3));
% else
Xscale = (diff([tt(1) tt(end)])/diff([-(max(YYlim)) max(YYlim)]))*(ppos(4)/ppos(3)); % this command computes the distorted offset of x-axis due to the layout of the panel. 
% end

ax1 = quiver(tt, zeros(size(tt)), Xscale*Udata, Vdata, ...
            'LineWidth', options.LineWidth, ...
            'Color', options.Color);

    if strcmpi(options.ShowArrowHead, 'on')
        ax1.ShowArrowHead = "on";
    else
        ax1.ShowArrowHead = 'off';
    end

    if strcmpi(options.AutoScale, 'on')
        ax1.AutoScale = "on";
    else
        ax1.AutoScale = "off";
    end


end

