function plot_latency_differences(cfg,values)

figure;
subplot(1,3,[1 2]);
title('Latency analysis');
hold on;
offset = .01;

% Extraemos los resultados significativos corregidos o sin corregir:
if isfield(values,'cpval_lat')
    pvalues = values.cpval_lat;
else
    pvalues = values.pval_lat;
end

% Añadir los puntos del scatter
for i = 1:length(values.mean_lat_1)
    if pvalues(i) < .05
        scatter(values.mean_lat_1(i), cfg.thresholds(i), 50, ...
            'filled', ...
            'MarkerFaceColor', cfg.plot.color_1);

        scatter(values.mean_lat_2(i), cfg.thresholds(i) + offset, 50, ...
            'filled', ...
            'MarkerFaceColor', cfg.plot.color_2 );
    else
        scatter(values.mean_lat_1(i), cfg.thresholds(i), 50, ...
            'filled', ...
            'MarkerFaceColor', cfg.plot.color_1, ...
            'MarkerEdgeColor', cfg.plot.color_1, ...
            'MarkerFaceAlpha', cfg.plot.color_alpha, ...
            'MarkerEdgeAlpha', cfg.plot.color_alpha);

        scatter(values.mean_lat_2(i), cfg.thresholds(i) + offset, 50, ...
            'filled', ...
            'MarkerFaceColor', cfg.plot.color_2, ...
            'MarkerEdgeColor', cfg.plot.color_2, ...
            'MarkerFaceAlpha', cfg.plot.color_alpha, ...
            'MarkerEdgeAlpha', cfg.plot.color_alpha);
    end
end

% Intervalos de confianza (asimétricos)
x_low_1 = values.ci_lat_1(1,:); x_high_1 = values.ci_lat_1(2,:);
x_low_2 = values.ci_lat_2(1,:); x_high_2 = values.ci_lat_2(2,:);

% Dibujar líneas horizontales (barras de error)
for i = 1:length(values.mean_lat_1)
    if pvalues(i) < cfg.stats.alpha
        line([x_low_1(i) x_high_1(i)], ...
            [cfg.thresholds(i) cfg.thresholds(i)], ...
            'Color', cfg.plot.color_1, ...
            'LineWidth', 1.5);

        line([x_low_2(i) x_high_2(i)], ...
            [cfg.thresholds(i) + offset cfg.thresholds(i) + offset], ...
            'Color', cfg.plot.color_2 , ...
            'LineWidth', 1.5);
    else
        line([x_low_1(i) x_high_1(i)], ...
            [cfg.thresholds(i) cfg.thresholds(i)], ...
            'Color', [cfg.plot.color_1 cfg.plot.color_alpha], ...
            'LineWidth', 1.5);

        line([x_low_2(i) x_high_2(i)], ...
            [cfg.thresholds(i) + offset cfg.thresholds(i) + offset], ...
            'Color', [cfg.plot.color_2 cfg.plot.color_alpha], ...
            'LineWidth', 1.5);
    end
end

xlabel('Mean latency (ms)');
ylabel('Percentage of peak');
ylim([0 1]);
set(gca, 'Box', 'on', 'TickDir', 'out');

subplot(1,3,3)
hold on;

xline(0)
xline(cfg.stats.alpha,':', 'alpha level')

for i = 1 : length(pvalues)
    if pvalues(i) < cfg.stats.alpha
        scatter(pvalues(i), cfg.thresholds(i), 50, ...
            'filled', ...
            'MarkerFaceColor', [.3 .3 .3]);
    else
        scatter(pvalues(i), cfg.thresholds(i), 50, ...
            'filled', ...
            'MarkerFaceColor', [.7 .7 .7]);
    end
end

xlabel('p-value');
ylim([0 1]);
xlim([-.1 max(pvalues)+0.1])
set(gca, 'Box', 'on', 'TickDir', 'out');
end

