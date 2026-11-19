function statistics_wind(ipt_time, ipt_speed, ipt_direction, station, opts)
arguments
    ipt_time
    ipt_speed {mustBeNumeric, mustBeVector}
    ipt_direction {mustBeNumeric, mustBeVector}
    station (1, 1) string
    % opts.Seasonal (1, 1) string {mustBeMember(opts.Seasonal, ["Two", "Four", "off"])} = "off"
    opts.OutputPath (1, 1) string = ""
    opts.FileName (1, 1) string = ""
end

% dir_str = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];

ipt_time = datetime(ipt_time);

max_time = cell(15, 1);
max_value = zeros(15, 2);
mean_value = zeros(15, 1);
DD = cell(15, 1);

for month_time = 1:12
    dday_idx = find(ipt_time.Month == month_time);
    spd = ipt_speed(dday_idx);
    ddir = ipt_direction(dday_idx);
    dday = ipt_time(dday_idx);
    [spd_max, max_idx] = max(spd, [], "omitmissing");
    max_time{month_time} = datestr(dday(max_idx), 'yyyy/mm/dd HH:MM');
    max_value(month_time, 1) = spd_max;
    max_value(month_time, 2) = ddir(max_idx);
    mean_value(month_time) = mean(spd, "omitmissing");
    DD{month_time} = find_main_direction(ddir);
end

dday_idx = find(ipt_time.Month >= 4 & ipt_time.Month <= 9);
spd = ipt_speed(dday_idx);
ddir = ipt_direction(dday_idx);
dday = ipt_time(dday_idx);
[spd_max, max_idx] = max(spd, [], "omitmissing");
max_time{13} = datestr(dday(max_idx), 'yyyy/mm/dd HH:MM');
max_value(13, 1) = spd_max;
max_value(13, 2) = ddir(max_idx);
mean_value(13) = mean(spd, "omitmissing");
DD{13} = find_main_direction(ddir);


dday_idx = find(ipt_time.Month >= 10 | ipt_time.Month <= 3);
spd = ipt_speed(dday_idx);
ddir = ipt_direction(dday_idx);
dday = ipt_time(dday_idx);
[spd_max, max_idx] = max(spd, [], "omitmissing");
max_time{14} = datestr(dday(max_idx), 'yyyy/mm/dd HH:MM');
max_value(14, 1) = spd_max;
max_value(14, 2) = ddir(max_idx);
mean_value(14) = mean(spd, "omitmissing");
DD{14} = find_main_direction(ddir);


dday_idx = find(~isnat(ipt_time));
spd = ipt_speed(dday_idx);
ddir = ipt_direction(dday_idx);
dday = ipt_time(dday_idx);
[spd_max, max_idx] = max(spd, [], "omitmissing");
max_time{end} = datestr(dday(max_idx), "yyyy/mm/dd HH:MM");
max_value(end, 1) = spd_max;
max_value(end, 2) = ddir(max_idx);
mean_value(end) = mean(spd, "omitmissing");
DD{end} = find_main_direction(ddir);


if opts.OutputPath ~= ""

    if ~isstring(opts.OutputPath); opts.OutputPath = string(opts.OutputPath); end

    if opts.FileName == ""
        filename = sprintf("%s_wind_statistics.csv", station);
    else
        filename = string(opts.FileName);
    end

    [fid, errmsg] = fopen(fullfile(opts.OutputPath, filename), "w", "n", "UTF-8");
    if fid == -1
        error("%s", errmsg)
    end
    write_ch = [239 187 191];
    fwrite(fid, write_ch, "uint8");

    fprintf(fid, "月份,最大風速發生時間,最大風速(m/s),最大風速風向,平均風速(m/s),主要風向\n");
    
    % data_str = repmat(',%.1f', 1, 5);
    for col_num = 1:12
        % prt_str = sprintf("%d月,%s,%s\n", col_num, data_str);
        fprintf(fid, "%d月,%s,%.1f,%d,%.1f,%s\n", col_num, max_time{col_num}, max_value(col_num, 1:2), mean_value(col_num), DD{col_num});
    end
    
    col_num = 13;
    fprintf(fid, "夏季,%s,%.1f,%d,%.1f,%s\n", max_time{col_num}, max_value(col_num, 1:2), mean_value(col_num), DD{col_num});
    
    col_num = 14;
    fprintf(fid, "冬季,%s,%.1f,%d,%.1f,%s\n", max_time{col_num}, max_value(col_num, 1:2), mean_value(col_num), DD{col_num});
    
    col_num = 15;
    fprintf(fid, "全部,%s,%.1f,%d,%.1f,%s\n", max_time{col_num}, max_value(col_num, 1:2), mean_value(col_num), DD{col_num});
    
    fclose(fid);

end

