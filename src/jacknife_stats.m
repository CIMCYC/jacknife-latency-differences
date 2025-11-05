function [lat_stats, slo_stats, values] = jacknife_stats(cfg, latencies, slopes)

N = size(latencies.latencies_1,1); % Número de sujetos

%% Estadisticos para las latencias:
latencies_1 = latencies.latencies_1;
latencies_2 = latencies.latencies_2;
latencies_d = latencies.latencies_d;

mean_lat_1 = mean(latencies_1, 1, "omitnan");
mean_lat_2 = mean(latencies_2, 1, "omitnan");
mean_lat_d = mean(latencies_d, 1, "omitnan");


se_lat_1 = sqrt((N-1)/N * sum((latencies_1 - mean_lat_1).^2,1, "omitnan"));
se_lat_2 = sqrt((N-1)/N * sum((latencies_2 - mean_lat_2).^2,1, "omitnan"));
se_lat_d = sqrt((N-1)/N * sum((latencies_d - mean_lat_d).^2,1, "omitnan"));

t_j_lat   = mean_lat_d ./ se_lat_d;
pval_lat = 2 * tcdf(-abs(t_j_lat), N-1);

tcrit = tinv(1-cfg.stats.ic/2, N-1);     % valor t para IC% seleccionado.

ci_lat_1 = [mean_lat_1 - tcrit*se_lat_1; mean_lat_1 + tcrit*se_lat_1];
ci_lat_2 = [mean_lat_2 - tcrit*se_lat_2; mean_lat_2 + tcrit*se_lat_2];
ci_lat_d = [mean_lat_d - tcrit*se_lat_d; mean_lat_d + tcrit*se_lat_d];

% Corrección por comparaciones multiples (Holm-Bonferroni):
if cfg.stats.fwe

    [h, adj_p, crit_p] = holm_bonferroni(pval_lat, .05);

    lat_stats = table(cfg.thresholds', mean_lat_1', ci_lat_1', ...
        mean_lat_2', ci_lat_2', mean_lat_d', ci_lat_d', pval_lat', adj_p, ...
        'VariableNames', {'Threshold', 'Mean latency I', 'IC I', ...
        'Mean latency II', 'IC II', 'Difference', 'IC', 'p-value', ...
        'Corrected p-value'});
else

    lat_stats = table(cfg.thresholds', mean_lat_1', ci_lat_1', ...
        mean_lat_2', ci_lat_2', mean_lat_d', ci_lat_d', pval_lat', ...
        'VariableNames', {'Threshold', 'Mean latency I', 'IC I', ...
        'Mean latency II', 'IC II', 'Difference', 'IC', 'p-value'});

end

%% Estadístico para las pendientes:
mean_slo_1 = mean(slopes.slopes_1, 'omitnan');
mean_slo_2 = mean(slopes.slopes_2, 'omitnan');
mean_slo_d = mean(slopes.slopes_d, 'omitnan');

% Error estándar jacknife:
se_slo_d = sqrt((N-1)/N*sum((slopes.slopes_d - mean_slo_d).^2,'omitnan'));

% Estadístico t y valor p
t_j_slope = mean_slo_d / se_slo_d;
pval_slope = 2 * tcdf(-abs(t_j_slope), N-1);

% Generamos tabla:
slo_stats = table(mean_slo_1, mean_slo_2, mean_slo_d, se_slo_d, ...
    pval_slope, 'VariableNames', {'Mean slope C1', 'Mean slope C2', ...
    'Mean difference', 'SE', 'p-value'});

%% Devolvemos valoes que pueden ser útiles para las representaciones
% gráficas:

values.mean_lat_1 = mean_lat_1; 
values.mean_lat_2 = mean_lat_2; 
values.mean_lat_d = mean_lat_d;

values.ci_lat_1 = ci_lat_1;
values.ci_lat_2 = ci_lat_2;
values.ci_lat_d = ci_lat_d;

values.pval_lat = pval_lat;

if cfg.stats.fwe; values.cpval_lat = adj_p; end

%% Print the results:
fprintf('\n <strong> Latencies > Statistical results: </strong> \n\n');
disp(lat_stats);

fprintf('\n <strong> Slopes > Statistical results: </strong> \n\n');
disp(slo_stats);

end

