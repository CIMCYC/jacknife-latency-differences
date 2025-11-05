function [norm_lat, norm_slo] = check_normality(cfg, latencies, slopes)

lat_diff = latencies.latencies_d;
slo_diff = slopes.slopes_d;

% Determinamos el número de umbrales a comprobar:
n_thresholds = size(lat_diff,2);

% Computamos el test de normalidad de latencias para cada umbral:
for i = 1 : n_thresholds
    if strcmp(cfg.normality.test, 'saphiro')
        [h_lat(i),p_lat(i)] = swtest(lat_diff(:,i),cfg.normality.alpha);
    elseif strcmp(cfg.normality.test, 'lillie')
        [h_lat(i),p_lat(i)] = lillietest(lat_diff(:,i),'Alpha',cfg.normality.alpha);
    end
end

% Computamos el test de normalidad para pendientes:
if strcmp(cfg.normality.test, 'saphiro')
    [h_slo,p_slo] = swtest(slo_diff,cfg.normality.alpha);
elseif strcmp(cfg.normality.test, 'lillie')    
    [h_slo,p_slo] = lillietest(slo_diff,'Alpha',cfg.normality.alpha);
end

% Devolvemos los resultados en una tabla:
norm_lat = table(cfg.thresholds', ~h_lat', p_lat', ...
    'VariableNames', {'Threshold', 'Normality test', 'p-value'});

norm_slo = table(~h_slo', p_slo', ...
    'VariableNames', {'Normality test', 'p-value'});

% Print the results:
fprintf('\n <strong> Latencies > Normality test results: </strong> \n\n');
disp(norm_lat);

fprintf('\n <strong> Slopes > Normality test results: </strong> \n\n');
disp(norm_slo);

end

