clear; close all; clc;
addpath('src');

%% Configutación inicial:
% Ejecutamos el archivo de configuración config.m donde se definen todos
% los parátros necesarios para realizar el análisis de latencias. Cualquier
% cambio en la configuración debe hacerse en ese archivo y no directamente
% en el código.

run config.m

%% Carga de datos:
% Cargamos los datos necesarios para el análisis. Puesto que vamos a
% comparar curvas petenecientes a dos condiciones, debemos importar los
% datos para cada condición y el vector temporal común a ambas condiciones.
% Las matrices de datos de cada condición tendrán una estructura [N x t]
% donde N es el número de sujetos y t cada uno de los puntos temporales de
% la curva.

load(cfg.datapath.cond_1); 
load(cfg.datapath.cond_2); 
load(cfg.datapath.time); 

% Las dos condiciones y el vector de tiempos deben almacenarse en la
% estructura data de la siguiente manera:

data.cond_1 = family1;
data.cond_2 = family2;
data.time = time;

% Representación gráfica de los datos originales:

plot_data(cfg, data, 'Original curves');

%% Suavizamos las curvas si es necesario:
% Podemos aplicar un suavizado temporal a los datos para mitigar el ruido 
% de las curvas. Tener en cuenta el tamaño de ventana y la frecuencia de
% muestreo de la señal para definir valores apropiados para el suavizado.

if cfg.smooth.flag
    data.cond_1 = movmean(data.cond_1, cfg.smooth.wind, 2);
    data.cond_2 = movmean(data.cond_2, cfg.smooth.wind, 2);
end

% Representación gráfica de los datos suavizados:
plot_data(cfg, data, 'Smoothed curves');

%% Jacknife analysis for latencies ans slopes:

[latencies, slopes] = jacknife(cfg, data, time);

%% Test de normalidad:
% Almacenamos los resultados en una tabla. En la columna Normality test
% almacenamos si el test de normalidad es positivo para un nivel de
% alpha = 0.05 (por defecto). Es decir, si podemos asumir que la
% distribución de latencias se ha extraído de una distribución normal.

[norm_test_lat, norm_test_slo] = check_normality(cfg, latencies, slopes);

% Histograma de latencias:
% figure; histogram(latencies.latencies_d(:,9),7)

%% Jacknife-based latency and slope statistics:
[lat_stats, slo_stats, values] = jacknife_stats(cfg, latencies, slopes);

%% Representación gráfica:
% Representamos gráficamente los resultados del análisis completo de
% latencias:

plot_latency_differences(cfg, values);
plot_slopes(cfg, values, slopes);