function [latencies, slopes] = jacknife(cfg,data,time)

n_thresholds = numel(cfg.thresholds);
n_subjects = size(data.cond_1,1);
idx_start = find( time >= 0, 1,'first');

latencies = struct();
slopes = struct();

%% Pre-alocar resultados:
% Aqui generamos las variables vacías donde almancenaremos las latencias
% para cada condición y la diferencia entre ambas condiciones.

latencies_1 = nan(n_subjects,n_thresholds);   % Latencias de familia 1
latencies_2 = nan(n_subjects,n_thresholds);   % Latencias de familia 2
latencies_d  = nan(n_subjects,n_thresholds);  % diferencia lat1 – lat2

slopes_1 = nan(n_subjects,1);   % Pendientes de familia 1
slopes_2 = nan(n_subjects,1);   % Pendientes de familia 2
slopes_d = nan(n_subjects,1);   % diferencia de pendientes

%% Jacknife Leave-One-Out:
% Estimación de las latencinas para cada condición y la diferencia entre
% ambas usando la técnica de jacknife (leave-one-out). Para ello,
% computamos la media de las curvas para cada condición dejando un sujeto
% fuera y repetimos de forma iterativa.

for i = 1 : n_subjects

    subjects_keep = setdiff(1:n_subjects, i); % Sujetos que se quedan

    m1 = mean(data.cond_1(subjects_keep,:), 1);    % Curva media cond_1
    m2 = mean(data.cond_2(subjects_keep,:), 1);    % Curva media cond_2

    for j = 1 : n_thresholds

        % Seleccionamos el umbral actual:
        threshold = cfg.thresholds(j);

        % Definimos los umbrales de amplitud para cada condición:
        threshold_1 = threshold * max(m1);
        threshold_2 = threshold * max(m2);

        % Calcular la latencia para cada condición:
        latencies_1(i,j) = first_cross(m1, threshold_1, time, idx_start);
        latencies_2(i,j) = first_cross(m2, threshold_2, time, idx_start);

        % Calcular la diferencia de latencias:
        latencies_d(i,j) = latencies_1(i,j) - latencies_2(i,j);

    end

    % Calculo de las pendientes de la regresion lineal sobre las latencias
    % medias:

    x = linspace(min(cfg.thresholds), max(cfg.thresholds), 100);
    if all(~isnan(latencies_1(i,:)))
        p1 = polyfit(cfg.thresholds, latencies_1(i,:), 1);
        y1(i,:) = polyval(p1,x);
        slopes_1(i) = p1(1);
        intercepts_1(i) = p1(2);
    end

    if all(~isnan(latencies_2(i,:)))
        p2 = polyfit(cfg.thresholds, latencies_2(i,:), 1);
        y2(i,:) = polyval(p2,x);
        slopes_2(i) = p2(1);
        intercepts_2(i) = p2(2);
    end

    slopes_d(i) = slopes_1(i) - slopes_2(i);
end

%% Calculo de la media:
mean_slope_1 = mean(mean(slopes_1));
mean_slope_2 = mean(mean(slopes_2));

mean_intercept_1 = mean(mean(intercepts_1));
mean_intercept_2 = mean(mean(intercepts_2));

y1_mean = mean_slope_1 * x + mean_intercept_1;
y2_mean = mean_slope_2 * x + mean_intercept_2;


%% Formatear y devolver resutlados:

latencies.latencies_1 = latencies_1;
latencies.latencies_2 = latencies_2;
latencies.latencies_d = latencies_d;

slopes.slopes_1 = slopes_1;
slopes.slopes_2 = slopes_2;
slopes.slopes_d = slopes_d;

% For data representation:
slopes.x = x;
slopes.y_1 = y1;
slopes.y_2 = y2;
slopes.mean_y_1 = y1_mean;
slopes.mean_y_2 = y2_mean;

end

