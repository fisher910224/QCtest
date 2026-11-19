function [sorted_dir_probability, sorted_dir_loc] = find_16Dir(dir)
%{
====================== FOR QIMEI PROJECT ======================
    FIND 16 DIRECTIONS OF CURRENT
                                        WRITED BY TING-YU DAI
===============================================================

    1   N           348.75~11.25
---------------------------------------------------------------
    2   NNE         11.25~33.75
---------------------------------------------------------------
    3   NE          33.75~56.25
---------------------------------------------------------------
    4   ENE         56.25~78.75
---------------------------------------------------------------
    5   E           78.75~101.25
---------------------------------------------------------------
...

dir = Dir(:,1);

%}

ig = [];
interval = 11.25:22.5:348.75;
for ii = 2:length(interval)
    ig(ii) = length(find(dir>=interval(ii-1) & dir<interval(ii)))/length(dir);
end
ig(1) = length(find(dir>=interval(end) | dir<interval(1)))/length(dir);

[sorted_dir_probability, sorted_dir_loc] = sort(ig*100, 'descend');

end

