% --- 生成 5100x3 的 purorg 色彩矩陣 ---

% 1. 定義顏色數量
n_colors = 5100;

% 2. 定義漸層中的關鍵顏色點 (Control Points)
% 這些點是基於 "Inferno" 色彩對照表選取的，非常符合您圖片的漸層。
% 每一列代表一個顏色點 [位置, R, G, B]，位置從 0 (起點) 到 1 (終點)。
% RGB 值也應在 0 到 1 的範圍內。
control_points = [
    0.0,    0.00, 0.00, 0.00;  % 黑色 (Black)
    0.25,   0.24, 0.01, 0.32;  % 深紫色 (Deep Purple)
    0.5,    0.58, 0.12, 0.44;  % 洋紅色 (Magenta/Reddish)
    0.75,   0.96, 0.38, 0.21;  % 橘色 (Orange)
    1.0,    1, 1, 37/255   % 亮黃色 (Light Yellow)
];

% 分離位置和顏色通道
positions = control_points(:, 1);
r_ch = control_points(:, 2);
g_ch = control_points(:, 3);
b_ch = control_points(:, 4);

% 3. 創建插值的目標位置向量
% 我們需要在 0 到 1 之間生成 5100 個點
interp_positions = linspace(0, 1, n_colors)';

% 4. 使用線性內插法 (linear interpolation) 為每個顏色通道生成顏色值
r_interp = interp1(positions, r_ch, interp_positions);
g_interp = interp1(positions, g_ch, interp_positions);
b_interp = interp1(positions, b_ch, interp_positions);

% 5. 將三個通道合併成最終的 purorg 矩陣
% 變數名稱為 purorg，大小為 5100x3，類型為 double
purorg = [r_interp, g_interp, b_interp];

% 清理臨時變數 (可選)
clear control_points positions r_ch g_ch b_ch interp_positions r_interp g_interp b_interp;

disp('已成功建立變數 purorg (5100x3 double)。');

% --- (可選) 視覺化驗證生成的色彩對照表 ---
figure;
imagesc(1:n_colors); % 創建一個長條圖像
colormap(purorg);    % 應用我們生成的 purorg 色彩對照表
set(gca, 'YTick', []); % 隱藏 Y 軸
title('生成的 purorg 色彩對照表');
xlabel('顏色索引 (1 到 5100)');

save purorg.mat purorg

%% 
yy = purorg(1:510:5100,:);
% yy = redblue_flu(1:510:end,:);
figure("OuterPosition", scsize)
tiledlayout(1,1,"TileSpacing","compact","Padding","tight")
ax1 = nexttile;
contourf(dday_20240109, 1:width(Cur_S1), log(shear_S1)', "LineStyle", "none")
clim([-15 -5])
axis([floor()])
colorbar
colormap(yy);
% colormap(flipud(yy))
% colormap(redblue_flu)
shading interp
set(ax1, "Ydir", "reverse", "Ytick", 0:3:15, "TickDir", "out")
figset_dateS1(ax1)
figset_linefont(ax1)


