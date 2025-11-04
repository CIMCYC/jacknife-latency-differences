function latencies = jacknife(cfg,data,time)

n_thresholds = numel(cfg.thresholds);
n_subjects = size(data.cond_1,1);
idx_start = find( time >= 0, 1,'first');

%% Pre-alocar resultados:
% Aqui generamos las variables vacías donde almancenaremos las latencias
% para cada condición y la diferencia entre ambas condiciones.

latencies_1 = nan(n_subjects,n_thresholds);   % Latencias de familia 1
latencies_2 = nan(n_subjects,n_thresholds);   % Latencias de familia 2
differences  = nan(n_subjects,n_thresholds);  % diferencia lat1 – lat2

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
        differences(i,j) = latencies_1(i,j) - latencies_2(i,j);

    end
end

%% Formatear y devolver resutlados:

latencies.latencies_1 = latencies_1;
latencies.latencies_2 = latencies_2;
latencies.differences = differences;

end

