function polarcontourf_dai(WaveDirecSpec, freq, options)
    arguments
        WaveDirecSpec double
        freq double
        options.Grid (1,1) string{mustBeMember(options.Grid, {'on', 'off'})} = 'on'
        options.Fontsize (1,1) {mustBeNumeric} = 10
        options.GridLinewidth (1,1) {mustBeNumeric} = 1
        options.Linewidth (1,1) {mustBeNumeric} = 1.5
        options.Clim = 'auto'   % 建議設為 'auto'，或給定 [cmin, cmax]
        options.TextColor {mustBeText} = 'k'
        options.ClabelString (1, 1) string = ''
        options.Colorbar (1,1) string{mustBeMember(options.Colorbar, {'on', 'off'})} = 'on'
    end

    % 1. 角度完美閉合處理 (0 到 360 度，將第 1 欄 0 度複製到第 91 欄 360 度)
    n_dir = size(WaveDirecSpec, 2);
    dir_step = 360 / n_dir;
    a = 0:dir_step:360; 
    Spec_closed = [WaveDirecSpec, WaveDirecSpec(:, 1)]; % 閉合矩陣
    % Spec_closed(Spec_closed = 0) = NaN;

    % 2. 建立極座標網格 (freq 為半徑，a 為角度)
    [df, ddir] = meshgrid(freq, deg2rad(a));
    [px, py] = pol2cart(ddir, df);

    % 3. 繪製等高線填充圖
    contourf(px, py, Spec_closed', 40, 'LineColor', 'none');
    shading interp;
    hold on;

    % 4. 專業海洋色盤：無能量處為純白，隨能量增加變藍、綠、紅
    % 建立白色底的 Jet 色盤
    custom_cmap = turbo(256);
    % custom_cmap(1:15, :) = repmat(linspace(1, 0, 15)', 1, 3); % 最低能量漸變為白色
    custom_cmap(1, :) = ones(1, 3); % 最低能量漸變為白色
    colormap(custom_cmap);

    % 5. 設定動態或自訂色階 (避免血紅過曝)
    if ischar(options.Clim) && strcmpi(options.Clim, 'auto') || isstring(options.Clim)
        max_val = max(Spec_closed(:));
        if max_val > 0
            clim([max_val * 0.02, max_val]); % 忽略最低 2% 的背景底噪
        end
    else
        clim(options.Clim);
    end

    % 6. 極座標格線與標籤
    axis equal;
    max_f = max(freq);
    axis([-max_f*1.15 max_f*1.15 -max_f*1.15 max_f*1.15]);
    axis off;

    % 同心圓頻率線
    r_labels = 0.1:0.1:max_f;
    th = linspace(0, 2*pi, 360);
    for r = r_labels
        [x, y] = pol2cart(th, r);
        plot(x, y, ':', 'LineWidth', options.GridLinewidth, 'Color', [.6 .6 .6]);
    end

    % 放射狀角度線 (每 30 度)
    if strcmpi(options.Grid, 'on')
        for th_deg = 0:30:330
            [x, y] = pol2cart(deg2rad(th_deg), [0, max_f]);
            plot(x, y, ':', 'LineWidth', options.GridLinewidth, 'Color', [.6 .6 .6]);
        end
    end

    % 標註方位角文字 (0, 30, 60 ... 330)
    for th_deg = 0:30:330
        [x, y] = pol2cart(deg2rad(th_deg), max_f * 1.08);
        text(x, y, sprintf('%d^\\circ', th_deg), 'HorizontalAlignment', 'center', ...
            'FontSize', options.Fontsize - 1, 'Color', options.TextColor);
    end

    % 標註頻率數值
    for r = r_labels
        [x, y] = pol2cart(deg2rad(15), r);
        text(x, y, sprintf('%.1f', r), 'FontSize', options.Fontsize - 2, ...
            'Color', [.3 .3 .3], 'Margin', 0.1);
    end

    if strcmpi(options.Colorbar, 'on')
        clbr = colorbar;
        clbr.Label.String = options.ClabelString;
    end
    
    view([90 -90]); % 0度朝上 (正北)
end