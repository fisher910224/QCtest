function nolegend(plotcode)
% Disables legend display for a given plot
% USAGE:
%   h = plot(x, y);  % Plot data and store the handle in 'h'
%   nolegend(h);     % Exclude this plot from the legend

    h1 = plotcode;
    for ii = 1:length(h1)
        set(get(get(h1(ii),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end
end