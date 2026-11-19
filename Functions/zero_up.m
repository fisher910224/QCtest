function [sorted_heights, significant_wave_height] = zero_up(wave_data, time_stamps)
% 初始化變量
zero_up_crossings = [];
wave_periods = [];
wave_heights = [];

% 1. 找到 zero-up crossings
for i = 2:length(wave_data)
    if wave_data(i-1) < 0 && wave_data(i) >= 0
        zero_up_crossings = [zero_up_crossings; time_stamps(i)];
    end
end

% 2. 計算波浪週期和波高
for j = 2:length(zero_up_crossings)
    % 計算週期
    period = zero_up_crossings(j) - zero_up_crossings(j-1);
    wave_periods = [wave_periods; period];
    
    % 找到此週期內的波浪高度
    wave_section = wave_data(time_stamps >= zero_up_crossings(j-1) & time_stamps < zero_up_crossings(j));
    wave_height = max(wave_section) - min(wave_section);
    wave_heights = [wave_heights; wave_height];
end

% 3. 計算平均波浪週期和顯著波高
mean_period = nanmean(wave_periods);

% 計算顯著波高（最高的三分之一波浪的平均高度）
sorted_heights = sort(wave_heights, 'descend');
significant_wave_height = nanmean(sorted_heights(1:round(length(sorted_heights)/3)));
