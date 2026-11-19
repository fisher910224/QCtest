function statistics_table = statistics_max_mean_min_monthly(ipt_time, ipt, station, opts)
arguments
    ipt_time
    ipt {mustBeNumeric, mustBeVector}
    station (1, 1) string
    opts.Seasonal (1, 1) string {mustBeMember(opts.Seasonal, ["Two", "Four", "off"])} = "off"
    opts.OutputPath (1, 1) string = ""
    opts.FileName (1, 1) string = ""
end

if opts.Seasonal == "Two"
    statistics_table = zeros(3, 15);
elseif opts.Seasonal == "Four"
    statistics_table = zeros(3, 17);
else
    statistics_table = zeros(3, 13);
end


ipt_time = datetime(ipt_time);

for month_time = 1:12
    ig = find(ipt_time.Month == month_time);
    max_value = max(ipt(ig), [], "omitmissing");
    mean_value = mean(ipt(ig), "omitmissing");
    min_value = min(ipt(ig), [], "omitmissing");

    statistics_table(1, month_time) = max_value;
    statistics_table(2, month_time) = mean_value;
    statistics_table(3, month_time) = min_value;
end


if opts.Seasonal == "Two"

    summer_time = find(ipt_time.Month >= 4 & ipt_time.Month <= 9);
    max_value = max(ipt(summer_time), [], "omitmissing");
    mean_value = mean(ipt(summer_time), "omitmissing");
    min_value = min(ipt(summer_time), [], "omitmissing");

    statistics_table(1, 13) = max_value;
    statistics_table(2, 13) = mean_value;
    statistics_table(3, 13) = min_value;

    winter_time = find(ipt_time.Month < 4 | ipt_time.Month > 9);
    max_value = max(ipt(winter_time), [], "omitmissing");
    mean_value = mean(ipt(winter_time), "omitmissing");
    min_value = min(ipt(winter_time), [], "omitmissing");

    statistics_table(1, 14) = max_value;
    statistics_table(2, 14) = mean_value;
    statistics_table(3, 14) = min_value;

end

if opts.Seasonal == "Four"

    spring_time = find(ipt_time.Month >= 3 & ipt_time.Month <= 5);
    max_value = max(ipt(spring_time), [], "omitmissing");
    mean_value = mean(ipt(spring_time), "omitmissing");
    min_value = min(ipt(spring_time), [], "omitmissing");

    statistics_table(1, 13) = max_value;
    statistics_table(2, 13) = mean_value;
    statistics_table(3, 13) = min_value;

    summer_time = find(ipt_time.Month >= 6 & ipt_time.Month <= 8);
    max_value = max(ipt(summer_time), [], "omitmissing");
    mean_value = mean(ipt(summer_time), "omitmissing");
    min_value = min(ipt(summer_time), [], "omitmissing");

    statistics_table(1, 14) = max_value;
    statistics_table(2, 14) = mean_value;
    statistics_table(3, 14) = min_value;

    autumn_time = find(ipt_time.Month >= 9 & ipt_time.Month <= 11);
    max_value = max(ipt(autumn_time), [], "omitmissing");
    mean_value = mean(ipt(autumn_time), "omitmissing");
    min_value = min(ipt(autumn_time), [], "omitmissing");

    statistics_table(1, 15) = max_value;
    statistics_table(2, 15) = mean_value;
    statistics_table(3, 15) = min_value;

    winter_time = find(ipt_time.Month <= 2 | ipt_time.Month >= 12);
    max_value = max(ipt(winter_time), [], "omitmissing");
    mean_value = mean(ipt(winter_time), "omitmissing");
    min_value = min(ipt(winter_time), [], "omitmissing");

    statistics_table(1, 16) = max_value;
    statistics_table(2, 16) = mean_value;
    statistics_table(3, 16) = min_value;
end

max_value = max(ipt, [], "omitmissing");
mean_value = mean(ipt, "omitmissing");
min_value = min(ipt, [], "omitmissing");

statistics_table(1, end) = max_value;
statistics_table(2, end) = mean_value;
statistics_table(3, end) = min_value;


% if ~isempty(opts.OutputPath)
if opts.OutputPath ~= ""

    if ~isstring(opts.OutputPath); opts.OutputPath = string(opts.OutputPath); end

    if opts.FileName == ""
        filename = sprintf("%s_temp_statistics.csv", station);
    else
        filename = string(opts.FileName);
    end

    [fid, errmsg] = fopen(fullfile(opts.OutputPath, filename), "w", "n", "UTF-8");
    if fid == -1
        error("%s", errmsg)
    end
    write_ch = [239 187 191];
    fwrite(fid, write_ch, "uint8");
    % month_str = repmat(',%.1f', 1, 12);
    month_str = string(1:12);
    combined_str = join(month_str, ",");

    if width(statistics_table) == 13

        prt_str = sprintf("測站,月份,%s,全部\n", combined_str);

    elseif width(statistics_table) == 15

        prt_str = sprintf("測站,月份,%s,夏季,冬季,全部\n", combined_str);

    elseif width(statistics_table) == 17

        prt_str = sprintf("測站,月份,%s,春季,夏季,秋季,冬季,全部\n", combined_str);

    end

    fprintf(fid, "%s", prt_str);
    col_str = {"最大", "平均", "最小"};
    data_str = repmat(',%.1f', 1, width(statistics_table));
    for col_num = 1:length(col_str)
        prt_str = sprintf(",%s%s\n", col_str{col_num}, data_str);
        fprintf(fid, prt_str, statistics_table(col_num, :));
    end
    fclose(fid);

end



end




