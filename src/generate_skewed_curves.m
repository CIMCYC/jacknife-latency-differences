function [time, family] = generate_skewed_curves(n_curves, mu, sigma, alpha, fs, noise_level)
% GENERATE_SKEWED_CURVES generates a family of right-skewed normal curves.
%
%   [time, family] = generate_skewed_curves(n_curves, mu, sigma, alpha, fs, noise_level)
%
%   Parameters:
%       n_curves     - number of curves to generate
%       mu           - mean value (center of the curve in ms)
%       sigma        - standard deviation of the underlying normal distribution
%       alpha        - skewness factor (higher values produce stronger right skew)
%       fs           - sampling frequency (Hz)
%       noise_level  - relative noise level (0 = no noise, 0.05 = mild, 0.1 = strong)
%
%   Returns:
%       time   - time vector in milliseconds
%       family - matrix (n_curves x N) containing the generated curves
%
%   Description:
%       This function generates a set of synthetic curves following a skewed
%       normal distribution. Each curve has a small random deviation in mean
%       and amplitude to introduce variability. Optional Gaussian noise can
%       be added, scaled to the signal energy.
%
%   Author: David López-García
%   Date:   2025-10-29

% General parameters:
t_end = 1000;                     % total duration (ms)
time = 0 : 1000/fs : t_end;       % time vector
N = length(time);                 % number of time samples

% Helper function: skewed normal distribution:
skewed = @(x, mu) 2 * normpdf(x, mu, sigma) .* normcdf(alpha * ((x - mu)/sigma));

% Initialize output matrix:
family = zeros(n_curves, N);

% Generate each individual curve:
for i = 1:n_curves

    % Small random variation in mean and amplitude
    mu_i = mu + randn * 70;
    amp_i = 1 + 0.3 * randn;

    % Generate skewed curve
    curve = amp_i * skewed(time, mu_i);

    % Add Gaussian noise proportional to signal energy (if specified)
    if noise_level > 0
        signal_std = std(curve);
        curve = curve + noise_level * signal_std * randn(size(curve));
    end

    % Store curve in output matrix
    family(i, :) = curve;
end
end