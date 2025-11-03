function lat = local_first_cross(curve, thr, tVec, idx0)
% Devuelve la latencia (tVec) del primer cruce del umbral ‘thr’.
% Si no hay cruce válido devuelve NaN.

    idx = find(curve(idx0:end) >= thr, 1, 'first');
    if isempty(idx), lat = NaN; return; end

    idx = idx + idx0 - 1;

    if idx == 1
        lat = tVec(1);
        return;
    end

    dy = curve(idx) - curve(idx-1);
    if dy == 0
        lat = tVec(idx);
    else
        lat = tVec(idx-1) + ...
              (thr - curve(idx-1)) * (tVec(idx) - tVec(idx-1)) / dy;
    end

end