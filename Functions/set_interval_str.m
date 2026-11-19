function interval_str = set_interval_str(interval_range, unit_str)
    interval_str = cell(size(interval_range));
    unit_str = string(unit_str);
    for ii = 1:length(interval_range)
        if ii == 1
            interval_str{ii} = sprintf("<%.1f %s", interval_range(2), unit_str);
        elseif ii <= length(interval_range)-1
            interval_str{ii} = sprintf("%.1f~%.1f %s", interval_range(ii), interval_range(ii+1), unit_str);
        else
            interval_str{ii} = sprintf(">%.1f %s", interval_range(end), unit_str);
        end
    end
end