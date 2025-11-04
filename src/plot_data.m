function plot_data(cfg,data,plottitle)

figure;
hold on;

plot(data.time, data.cond_1', 'Color', [cfg.plot.color_1 cfg.plot.color_alpha]);
plot(data.time, data.cond_2', 'Color', [cfg.plot.color_2 cfg.plot.color_alpha]);

% Plot mean curves for each family
plot(data.time, mean(data.cond_1,1),'Color',cfg.plot.color_1, 'LineWidth', 3);
plot(data.time, mean(data.cond_2,1),'Color',cfg.plot.color_2, 'LineWidth', 3);

xlabel('Time (ms)');
ylabel('Amplitude (a.u.)');
title(plottitle);
box on;

end

