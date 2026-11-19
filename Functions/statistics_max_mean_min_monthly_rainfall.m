function statistics_table = statistics_max_mean_min_monthly_rainfall(ipt_time, ipt, station, opts)
arguments
    ipt_time
    ipt {mustBeNumeric, mustBeVector}
    station (1, 1) string
    opts.OutputPath (1, 1) string = ""
    opts.FileName (1, 1) string = ""
end

ipt_time = datetime(ipt_time);
st_year = ipt_time(1).Year;
ed_year = ipt_time(end).Year;
statistics_table1 = NaN(ed_year-st_year, 12);

for year_time = st_year:ed_year
    for month_time = 1:12
        ig = find(ipt_time.Month == month_time & ipt_time.Year == year_time);
        sum_value = sum(ipt(ig), "omitmissing");
        statistics_table1(year_time-st_year+1, month_time) = sum_value;
    end
end

statistics_table = mean(statistics_table1, "omitmissing");



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


    prt_str = sprintf("測站,月份,%s\n", combined_str);

    

    fprintf(fid, "%s", prt_str);
    col_str = {"平均"};
    data_str = repmat(',%.1f', 1, width(statistics_table));
    for col_num = 1:length(col_str)
        prt_str = sprintf(",%s%s\n", col_str{col_num}, data_str);
        fprintf(fid, prt_str, statistics_table(col_num, :));
    end
    fclose(fid);

end



end




