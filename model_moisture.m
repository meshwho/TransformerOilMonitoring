
function out = model_moisture(data, cfg)
% МАТЕМАТИЧНА МОДЕЛЬ ВОЛОГОВМІСТУ
%
% Розрахунок розчинності води та
% відносного насичення масла вологою.

T = data.oilTempSensorC;
waterPPM = data.waterPPM;

%% Розчинність води залежно від температури

Csat = cfg.moisture.satAtRefPPM .* ...
    exp(cfg.moisture.betaPerC .* ...
    (T - cfg.moisture.refTempC));

%% Відносне насичення водою, %

RS = 100 .* waterPPM ./ Csat;

%% Перевірка допустимих значень

highWater = waterPPM > cfg.limits.waterPPM;

highSaturation = RS > ...
    cfg.limits.relativeSaturationPct;

warning = highWater | highSaturation;

%% Результати

out.waterPPM = waterPPM;
out.saturationPPM = Csat;
out.relativeSaturationPct = RS;

out.highWater = highWater;
out.highSaturation = highSaturation;
out.warning = warning;

end
