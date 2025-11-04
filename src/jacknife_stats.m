function [results, values] = jacknife_stats(cfg, latencies)

N = size(latencies.latencies_1,1); % Número de sujetos

latencies_1 = latencies.latencies_1;
latencies_2 = latencies.latencies_2;
differences = latencies.differences;

mean_lat1 = mean(latencies_1, 1, "omitnan");
mean_lat2 = mean(latencies_2, 1, "omitnan");
mean_diff = mean(differences, 1, "omitnan");


se_lat1 = sqrt((N-1)/N * sum((latencies_1 - mean_lat1).^2,1, "omitnan"));
se_lat2 = sqrt((N-1)/N * sum((latencies_2 - mean_lat2).^2,1, "omitnan"));
se_diff = sqrt((N-1)/N * sum((differences - mean_diff).^2,1, "omitnan"));

t_j   = mean_diff ./ se_diff;
pval = 2 * tcdf(-abs(t_j), N-1);

tcrit = tinv(1-cfg.stats.ic/2, N-1);     % valor t para IC% seleccionado.

ci_lat1 = [mean_lat1 - tcrit*se_lat1; mean_lat1 + tcrit*se_lat1];
ci_lat2 = [mean_lat2 - tcrit*se_lat2; mean_lat2 + tcrit*se_lat2];
ci_diff = [mean_diff - tcrit*se_diff; mean_diff + tcrit*se_diff];

% Corrección por comparaciones multiples (Holm-Bonferroni):
if cfg.stats.fwe

    [h, adj_p, crit_p] = holm_bonferroni(pval, .05);

    results = table(cfg.thresholds', mean_lat1', ci_lat1', ...
        mean_lat2', ci_lat2', mean_diff', ci_diff', pval', adj_p, ...
        'VariableNames', {'Threshold', 'Mean latency I', 'IC I', ...
        'Mean latency II', 'IC II', 'Difference', 'IC', 'p-value', ...
        'Corrected p-value'});
else

    results = table(cfg.thresholds', mean_lat1', ci_lat1', ...
        mean_lat2', ci_lat2', mean_diff', ci_diff', pval', ...
        'VariableNames', {'Threshold', 'Mean latency I', 'IC I', ...
        'Mean latency II', 'IC II', 'Difference', 'IC', 'p-value'});

end

values.mean_lat1 = mean_lat1; 
values.mean_lat2 = mean_lat2; 
values.mean_diff = mean_diff;

values.ci_lat1 = ci_lat1;
values.ci_lat2 = ci_lat2;
values.ci_diff = ci_diff;

values.pval = pval;
if cfg.stats.fwe; values.cpval = adj_p; end

end

