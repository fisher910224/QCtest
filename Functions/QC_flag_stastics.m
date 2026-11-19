function [Test] = QC_flag_stastics(processed_data, station, output_path, options)
arguments
    processed_data {mustBeA(processed_data, ["string", "table"])} 
    station (1, 1) string
    output_path (1, 1) string
    options.TestingItem (1, 1) string {mustBeMember(options.TestingItem, ["Current", "Wave", "Sealevel"])}
end
%{
WRITE BY LEEYEEMIN
============================== TESTING CODE ===============================
processed_data = "C:\Users\adm\Desktop\Xingda\2026\0418_0606\QC\Meng\Xingda-Current_QC.txt";
options.TestingItem = "Current";

processed_data = "C:\Users\adm\Desktop\Xingda\2026\0418_0606\QC\Meng\Xingda-Wave_QC.txt";
options.TestingItem = "Wave";

processed_data = "C:\Users\adm\Desktop\Xingda\2026\0418_0606\QC\Meng\Xingda-Sealevel_QC.txt";
options.TestingItem = "Sealevel";

output_path = "C:\Users\adm\Desktop\Xingda\2026\0418_0606\processed_data";
station = "Xingda";

%}
    if isstring(processed_data) == 1
        df = readtable(processed_data, "Delimiter", ',', 'ReadVariableNames', false);
    elseif istable(processed_data) == 1
        df = processed_data;
    else
        printf("Error: can't find file!!!")
        return
    end
    
    Test = struct();
    for ii = 1:width(df)/2
        df_array = df.(['Var', num2str(ii*2)]);
        Test(ii).all_data = length(df_array);
        Test(ii).pass = find(df_array == 1);
        Test(ii).suspect = find(df_array == 3);
        Test(ii).fail = find(df_array == 4);
        Test(ii).missing = find(df_array == 9 | df_array == 0);
        Test(ii).UTD = find(df_array == 2);
    end
    
    

    if options.TestingItem == 'Current'
        testing_items = {'Time', 'Bot. Vel.', 'Bot. Dir.', 'Mid. Vel.', 'Mid. Dir.', 'Top. Vel.', 'Top. Dir.'};
    elseif options.TestingItem == 'Wave'
        testing_items = {'Time', 'Hs', 'Tp', 'MDir'};
    elseif options.TestingItem == 'Sealevel'
        testing_items = {'Time', 'SL'};
    end

    f_txt = sprintf('%s\\%s_%s_flag_stastics.txt', output_path, station, options.TestingItem);
    fid = fopen(f_txt, 'w');
    fprintf(fid, '================================ Flags stastics ================================\n');
    fprintf(fid, 'Testing items  Data numbers  Pass(%%)    Suspect(%%) Fail(%%)    Missing(%%) UTD(%%)\n');
    for ii = 1:length(testing_items)
    fprintf(fid, '%-14s %-13.0f %-10.2f %-10.2f %-10.2f %-10.2f %-10.2f\n', ...
        testing_items{ii}, ...
        Test(ii).all_data, ...
        length(Test(ii).pass)       /Test(ii).all_data*100, ...
        length(Test(ii).suspect)    /Test(ii).all_data*100, ...
        length(Test(ii).fail)       /Test(ii).all_data*100, ...
        length(Test(ii).missing)    /Test(ii).all_data*100, ...
        length(Test(ii).UTD)        /Test(ii).all_data*100);
    end
    fclose(fid);





