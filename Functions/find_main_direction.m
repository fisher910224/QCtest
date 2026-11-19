function [D, counts] = find_main_direction(Dir)
% load("directions_str.mat")
directions_str = {'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', ...
                      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'};
Dir = Dir(~isnan(Dir));
    if isempty(Dir)
        D = 'N/A'; 
        return;
    end
dir_range = -11.25:22.5:348.75;
Dir(Dir >= 348.75) = Dir(Dir >= 348.75) - 360;

% pp = [];
% for ii = 1:length(dir_range)-1
%     ig = Dir >= dir_range(ii) & Dir < dir_range(ii+1);
%     pp(ii) = sum(ig);
% end

% [~, max_idx] = max(pp);
% kk = [pp; directions_str'];
counts = histcounts(Dir, dir_range);
[~, max_idx] = max(counts);
D = directions_str{max_idx};
end
