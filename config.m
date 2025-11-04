
%% Datos:
cfg.datapath.cond_1 = 'data/cond_1.mat';
cfg.datapath.cond_2 = 'data/cond_2.mat';
cfg.datapath.time = 'data/time.mat';

%% Suavizado de las curvas
cfg.smooth.flag = true;
cfg.smooth.wind = 5;

%% Amplitud thresholds:
%  Umbrales de amplitud relativos al pico máximo de las curvas donde 
%  realizaremos los análisis de latencia:

cfg.thresholds = [.1 .2 .3 .4 .5 .6 .7 .8 .9];

%% Test de normalidad:
%  El test estadístico que realizamos es una prueba t, por lo que se asume
%  normalidad en los datos. Para asegurarnos, podemos computar un análisis 
% de normalidad para cada umbral de amplitud donde estemos calculando la
% diferencia de latencia. El análisis seleccionado es el de Shapiro-Wilk o 
% Shapiro-Francia, adecuado para muestras pequeñas.

cfg.normality.flag = true;
cfg.normality.test = 'saphiro'; % 'saphiro' | 'lillie'
cfg.normality.alpha = .05;

%% Intervalo de confianza:
%  Definir el intervalo de confianza de los resultados:

cfg.stats.ic = .05; % IC = 95%

%% Correción por comparaciones multiples.
%  Puesto que estamos realizando varios test estádisiticos para distintos
%  umbrales de amplitud de las curvas, podemos aplicar correción por
%  comparaciones multiples. El método aplicado es Holm-Bonferroni.

cfg.stats.fwe = true;

%% Plots:

cfg.plot.color_1 = [.51 .80 .74];
cfg.plot.color_2 = [1 .41 0.38];
cfg.plot.color_alpha = .3;