clear; close all; clc;
addpath('src');

%% Cargamos los datos:
load('data/family_1.mat');
load('data/family_2.mat');

%% Suavizamos las curvas si es necesario:
cond_1 = movmean(family1, 2, 2, 'Endpoints', 'shrink');
cond_2 = movmean(family2, 2, 2, 'Endpoints', 'shrink');

%% Helper:

first_cross = @(curve, thr, tVec, idx0) ...
             local_first_cross(curve, thr, tVec, idx0);

%% Configuración jacknife y definición de parámetros:

% Umbrales de amplitud (0-100%) donde se realizará el análisis:
amplitude_thresholds = .1:.1:.9;
n_thresholds = numel(amplitude_thresholds);
n_subjects = size(cond_1,1);

tCrit     = tinv(1-0.05/2, n_subjects-1);     % valor t para IC 95 %
idx_start = find( time >= 0, 1,'first'); % No buscar cruces antes de 0 ms

%% Pre-alocar resultados:
% Aqui generamos las variables vacías donde almancenaremos las latencias
% para cada condición y la diferencia entre ambas condiciones.

latencies_1 = nan(n_subjects,n_thresholds);   % Latencias de familia 1
latencies_2 = nan(n_subjects,n_thresholds);   % Latencias de familia 2
differences  = nan(n_subjects,n_thresholds);   % diferencia lat1 – lat2

%% Jacknife Leave-One-Out:
% Estimación de las latencinas para cada condición y la diferencia entre
% ambas usando la técnica de jacknife (leave-one-out). Para ello,
% computamos la media de las curvas para cada condición dejando un sujeto
% fuera y repetimos de forma iterativa.

for i = 1 : n_subjects

    subjects_keep = setdiff(1:n_subjects, i); % Sujetos que se quedan

    m1 = mean(cond_1(subjects_keep,:), 1);    % Curva media cond_1
    m2 = mean(cond_2(subjects_keep,:), 1);    % Curva media cond_2

    for j = 1 : n_thresholds
        
        % Seleccionamos el umbral actual:
        threshold = amplitude_thresholds(j);

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

%% Test de normalidad:
% Para este análisis asumimos que las diferencias de latencia siguen una
% distribución normal. Para asegurarnos, podemos computar un análisis de
% normalidad para cada umbral de amplitud donde estemos calculando la
% diferencia de latencia. El análisis seleccionado es el de Shapiro-Wilk o 
% Shapiro-Francia, adecuado para muestras pequeñas.

for i = 1 : n_thresholds
    [H(i),p(i)] = swtest(differences(:,i));
end

% Almacenamos los resultados en una tabla. En la columna Normality test
% almacenamos si el test de normalidad es positivo para un nivel de 
% alpha = 0.05 (por defecto). Es decir, si podemos asumir que la 
% distribución de latencias se ha extraído de una distribución normal.

normality = table(~H', p', 'VariableNames', {'Normality test', 'p-value'});
disp(normality)

%% Estadística:

N = n_subjects;

mean_lat1 = nanmean(latencies_1, 1);
mean_lat2 = nanmean(latencies_2, 1);
mean_diff = nanmean(differences, 1);

se_lat1 = sqrt((N-1)/N * nansum((latencies_1 - mean_lat1).^2,1));
se_lat2 = sqrt((N-1)/N * nansum((latencies_2 - mean_lat2).^2,1));
se_diff = sqrt((N-1)/N * nansum((differences - mean_diff).^2,1));

tJ   = mean_diff ./ se_diff;
pVal = 2 * tcdf(-abs(tJ), N-1);

CI_Lat1 = [mean_lat1 - tCrit*se_lat1; mean_lat1 + tCrit*se_lat1];
CI_Lat2 = [mean_lat2 - tCrit*se_lat2; mean_lat2 + tCrit*se_lat2];
CI_D    = [mean_diff - tCrit*se_diff; mean_diff + tCrit*se_diff];

% Corrección por comparaciones multiples (Holm-Bonferroni):
[h, adj_p, crit_p] = holm_bonferroni(pVal, .05);

% Guardamos los resultados en una tabla:
results = table(amplitude_thresholds', mean_lat1', CI_Lat1', ...
    mean_lat2', CI_Lat2', mean_diff', CI_D', pVal', adj_p, ...
    'VariableNames', {'Threshold', 'Mean latency I', 'IC I', ...
    'Mean latency II', 'IC II', 'Difference', 'IC', 'p-value', ...
    'Corrected p-value'});

disp(results);

%% Representación gráfica de los resultados de latencia:

figure; hold on;
offset = .01;

% Añadir los puntos del scatter
scatter(mean_lat1, amplitude_thresholds, 50, 'filled', 'MarkerFaceColor', [.51 .80 .74]);
scatter(mean_lat2, amplitude_thresholds + offset, 50, 'filled', 'MarkerFaceColor', [1 .41 0.38] );
scatter(abs(mean_diff), amplitude_thresholds, 50, 'filled', 'MarkerFaceColor', [1 .41 0.38] );

% Intervalos de confianza (asimétricos)
x_low_1 = CI_Lat1(1,:); x_high_1 = CI_Lat1(2,:);
x_low_2 = CI_Lat2(1,:); x_high_2 = CI_Lat2(2,:);
x_low_d = abs(CI_D(1,:)); x_high_d = abs(CI_D(2,:));

% Dibujar líneas horizontales (barras de error)
for i = 1:length(mean_lat1)
    line([x_low_1(i) x_high_1(i)], [amplitude_thresholds(i) amplitude_thresholds(i)], 'Color', [.51 .80 .74], 'LineWidth', 1.5);
    line([x_low_2(i) x_high_2(i)], [amplitude_thresholds(i) + offset amplitude_thresholds(i) + offset], 'Color', [1 .41 0.38] , 'LineWidth', 1.5);
    line([x_low_d(i) x_high_d(i)], [amplitude_thresholds(i) amplitude_thresholds(i)], 'Color', [1 .41 0.38] , 'LineWidth', 1.5);
end

xlabel('Mean latency (ms)');
ylabel('Percentage of peak');
ylim([0 1]);
set(gca, 'Box', 'on', 'TickDir', 'out');

%% Representación de cada una de las condiciones:

figure; hold on;
plot(time, family1', 'Color', [.51 .80 .74 0.3]);
plot(time, family2', 'Color', [1 .41 0.38 0.3]);

% Plot mean curves for each family
plot(time, mean(family1,1),'Color',[.51 .80 .74], 'LineWidth', 3);
plot(time, mean(family2,1),'Color',[ 1 .41 0.38], 'LineWidth', 3);

xlabel('Time (ms)');
ylabel('Amplitude (a.u.)');
title('Two Families of Right-Skewed Curves');
legend({'Family 1','Family 2'}, 'Location', 'best');
grid on; box on;
xlim([0 1000]);