function [prob_table] = Statistics_wave_dir(Hs, Dir, Hs_interval, opts)


directions_str = {'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', ...
                          'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'};
dir_range = -11.25:22.5:348.75;
Dir(Dir >= 348.75) = Dir(Dir >= 348.75) - 360;

for Hs_idx = 1:length(Hs_interval)-1
    for Dir_idx = 1:15
        ig = find(Hs >= Hs_interval(Hs_idx) & Hs < Hs_interval(Hs_idx+1) ...
            & Dir >= dir_range(Dir_idx) & Dir < dir_range(Dir_idx+1));






end


