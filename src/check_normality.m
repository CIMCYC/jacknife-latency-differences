function [normality] = check_normality(cfg, differences)

% Determinamos el número de umbrales a comprobar:
n_thresholds = size(differences,2);

% Computamos el test de normalidad para cada umbral:
for i = 1 : n_thresholds
    if strcmp(cfg.normality.test, 'saphiro')
        [H(i),p(i)] = swtest(differences(:,i),cfg.normality.alpha);
    elseif strcmp(cfg.normality.test, 'lillie')
        [H(i),p(i)] = lillietest(differences(:,i),'Alpha',cfg.normality.alpha);
    end
end

% Devolvemos los resultados en una tabla:
normality = table(~H', p', 'VariableNames', {'Normality test', 'p-value'});

end

