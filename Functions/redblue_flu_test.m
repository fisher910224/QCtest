
redblue_flu = [];
interval = [1 1000 2000 2550 3100 4100 5100];
% black-blue
for ii = interval(1):interval(2)
    redblue_flu(ii, 1) = 0;
    redblue_flu(ii, 2) = 0;
    redblue_flu(ii, 3) = ii/(interval(2)-interval(1)+1);
end

% blue-flu. blue
for ii = interval(2):interval(3)
    redblue_flu(ii, 1) = 0;
    redblue_flu(ii, 2) = (ii-interval(2))/(interval(3)-interval(2)+1);
    redblue_flu(ii, 3) = 1;
end
% flu. blue-white
for ii = interval(3)+1:interval(4)
    redblue_flu(ii, 1) = (ii-interval(3))/(interval(4)-interval(3)+1);
    redblue_flu(ii, 2) = 1;
    redblue_flu(ii, 3) = 1;
end
% white-flu. red
for ii = interval(4)+1:interval(5)
    redblue_flu(ii, 1) = 1;
    redblue_flu(ii, 2) = 1-((ii-interval(4))/(interval(5)-interval(4)+1));
    redblue_flu(ii, 3) = 1;
end
% flu. red-red
for ii = interval(5)+1:interval(6)
    redblue_flu(ii, 1) = 1;
    redblue_flu(ii, 2) = 0;
    redblue_flu(ii, 3) = 1-(ii-interval(5))/(interval(6)-interval(5)+1);
end

% flu. red-red
for ii = interval(6)+1:interval(7)
    redblue_flu(ii, 1) = 1-(ii-interval(6))/(interval(7)-interval(6)+1);
    redblue_flu(ii, 2) = 0;
    redblue_flu(ii, 3) = 0;
end


%% 
yy = redblue_flu(2551:end,:);
figure("OuterPosition", scsize)
tiledlayout(1,1,"TileSpacing","compact","Padding","tight")
ax1 = nexttile;
contourf(dday_20240109, 1:width(Cur_S1), log(shear_S1)', "LineStyle", "none")
colorbar
colormap(flipud(yy))
set(ax1, "Ydir", "reverse")
figset_linefont(ax1)


