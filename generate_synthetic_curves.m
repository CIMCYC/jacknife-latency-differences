clear; close all; clc;
addpath('src')  

%% General parameters:

fs = 250;               % Sampling frequency (Hz)
n_curves = 70;          % Number of curves per family
sigma = 150;            % Standard deviation (width of the curve)
alpha = 3;              % Skewness factor (higher = more right-skewed)
noise_level = 0.08;     % Relative noise level (0 = no noise)

%% Means for each family (temporal offset):

mu_family1 = 300;   % Mean time (ms) for family 1
mu_family2 = 350;   % Mean time (ms) for family 2

%%  Generate the two families:

[~, family1]    = generate_skewed_curves(n_curves, mu_family1, sigma, alpha+2, fs, noise_level);
[time, family2] = generate_skewed_curves(n_curves, mu_family2, sigma, alpha, fs, noise_level);

%% Plot the results:

figure('Color','w'); hold on;
plot(time, family1', 'Color', [.51 .80 .74 0.45]);
plot(time, family2', 'Color', [1 .41 0.38 0.45]);

% Plot mean curves for each family
plot(time, mean(family1,1),'Color',[.51 .80 .74], 'LineWidth', 3);
plot(time, mean(family2,1),'Color',[ 1 .41 0.38], 'LineWidth', 3);

xlabel('Time (ms)');
ylabel('Amplitude (a.u.)');
title('Two Families of Right-Skewed Curves');
legend({'Family 1','Family 2'}, 'Location', 'best');
grid on; box on;
xlim([0 1000]);

%% Save the data:

% Create folder if it doesn't exist
if ~exist('data', 'dir')
    mkdir('data');
end

% Generate filename based on parameters:
filename = sprintf('data/family_1.mat');
save(filename, 'time', 'family1');

filename = sprintf('data/family_2.mat');
save(filename, 'time', 'family2');