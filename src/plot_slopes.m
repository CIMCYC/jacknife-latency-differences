function plot_slopes(cfg, values, slopes)

figure; hold on;
set(gca, 'Box', 'on', 'TickDir', 'out');
title('Slope analysis')
ylabel('Thresholds')

%% Representación de las pendientes individuales
for i = 1 : size(slopes.y_1,1)
    plot(slopes.y_1(i,:), slopes.x, '-', ...
        'Color', [cfg.plot.color_1 0.1], 'LineWidth', 1);
    plot(slopes.y_2(i,:), slopes.x , '-', ...
        'Color', [cfg.plot.color_2 0.1], 'LineWidth', 1);
end

%% Representamos la pendiente media:
plot(slopes.mean_y_1, slopes.x, '.', 'Color', cfg.plot.color_1, 'LineWidth', 1);
plot(slopes.mean_y_2, slopes.x, '.', 'Color', cfg.plot.color_2, 'LineWidth', 1);

%% Representamos las latencias:
scatter(values.mean_lat_1, cfg.thresholds, 50, ...
            'filled', ...
            'MarkerFaceColor',cfg.plot.color_1);

scatter(values.mean_lat_2, cfg.thresholds, 50, ...
            'filled', ...
            'MarkerFaceColor', cfg.plot.color_2);

end

