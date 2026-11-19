function flag = time_interval_test(tinp, interval, tolerance, options)
% tinp: double (datenum or datetime)
% tinp = dday; interval = 3600; tolerance = 60;
arguments
    tinp {mustBeA(tinp, ["double", "datetime"])}
    interval (1, 1) double {mustBePositive}
    tolerance (1, 1) double {mustBeNonnegative} = 0
    options.FigureDisplay (1, 1) string {mustBeMember(options.FigureDisplay, ["off", "on"])} = "off"
end


if isnumeric(tinp)
    tinp = datetime(tinp, 'ConvertFrom', 'datenum');
end
tinp = tinp(:);
delta_t = seconds(diff(tinp));
flag = ones(length(tinp), 1);
% flag(1) = 2;

idx_9 = delta_t > (interval + tolerance);
idx_3 = delta_t < (interval - tolerance);
flag(find(idx_9)+1) = 9;
flag(find(idx_3)+1) = 3;

if options.FigureDisplay == "on"
    figure
    plot(tinp(2:end), delta_t, '-o', 'Color', 'k'); hold on
    % yline(interval, 'r--', 'Expected Interval');
    % yline(interval + tolerance, 'r:', 'Upper Tolerance');
    % yline(interval - tolerance, 'r:', 'Lower Tolerance');
    scatter(tinp(flag==9), delta_t(max(1, find(flag==9)-1)), 'filled', 'MarkerFaceColor', 'r');
    scatter(tinp(flag==3), delta_t(max(1, find(flag==3)-1)), 'filled', 'MarkerFaceColor', 'g');
    ylabel('Time Interval (seconds)');
    title('Timing / Gap Test Results');
    grid on;
end


end








