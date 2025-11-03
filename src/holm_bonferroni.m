function [h, adj_p, crit_p] = holm_bonferroni(p, alpha)
% HOLM_BONFERRONI aplica la corrección de Holm–Bonferroni a un conjunto de 
% p-values.
%
% Uso:
%   [h, adj_p, crit_p] = holm_bonferroni(p, alpha)
%
% Entradas:
%   p     : vector de p-values (1D)
%   alpha : nivel de significación global (ej. 0.05)
%
% Salidas:
%   h      : vector lógico indicando qué hipótesis se rechazan (1 = significativo)
%   adj_p  : p-values ajustados según Holm–Bonferroni
%   crit_p : umbrales críticos aplicados en cada paso
%
% Ejemplo:
%   p = [0.01 0.03 0.12 0.002 0.04 0.07 0.001 0.02 0.06];
%   [h, adj_p, crit_p] = holm_bonferroni(p, 0.05)

    if nargin < 2
        alpha = 0.05;
    end

    p = p(:); % asegurar forma columna
    m = numel(p);

    % Ordenar p-values y guardar el orden original
    [sorted_p, sort_idx] = sort(p);
    h = false(m,1);
    crit_p = alpha ./ (m - (0:m-1))'; % umbrales críticos

    % Procedimiento step-down
    for i = 1:m
        if sorted_p(i) <= crit_p(i)
            h(i) = true;
        else
            break; % una vez falla, las siguientes no son significativas
        end
    end

    % Calcular p-values ajustados (forma estándar)
    adj_p_sorted = sorted_p .* (m - (0:m-1))';
    adj_p_sorted = cummax(adj_p_sorted); % asegurar monotonía
    adj_p_sorted = min(adj_p_sorted, 1);
    adj_p = zeros(size(p));
    adj_p(sort_idx) = adj_p_sorted;

    % Reordenar resultados al orden original
    h(sort_idx) = h;

end
