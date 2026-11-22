function Csat = water_solubility(T,cfg)
% ТЕМПЕРАТУРНА РОЗЧИННІСТЬ ВОДИ В МАСЛІ
% Формула 3.5: Csat = C0*exp(-B/(T+273.15)).
%
% Коефіцієнти залежать від складу й старіння масла.
% Налаштування містять приклад для мінерального масла CIGRE 349.

if any(~isfinite(T(:))) || any(T(:) <= -273.15)
    error('Некоректна абсолютна температура масла.');
end

C0 = cfg.moisture.solubilityC0PPM;
B = cfg.moisture.solubilityBK;

if ~isfinite(C0) || ~isfinite(B) || C0 <= 0 || B <= 0
    error('Некоректні коефіцієнти розчинності води.');
end

Csat = C0.*exp(-B./(T+273.15));

end
