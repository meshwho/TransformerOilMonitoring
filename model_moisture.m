function out = model_moisture(data,cfg)
% МАТЕМАТИЧНА МОДЕЛЬ ВОЛОГОВМІСТУ МАСЛА
% 3.4: RS = 100*aw
% 3.5: Csat = C0*exp(-B/Tk)
% 3.6: Cw = aw*Csat
% 3.7: Середній вологовміст за 24 години
% 3.8: Різниця двох добових середніх

%% Вхідні показання датчика

t = data.tH(:);
T = data.oilTempSensorC(:);
aw = data.waterActivity(:);
N = numel(t);

if N < 2 || numel(T) ~= N || numel(aw) ~= N
    error('Час, температура та активність води мають різну довжину.');
end

if any(~isfinite([t;T;aw])) || any(diff(t) <= 0)
    error('Некоректні показання датчиків або час вимірювань.');
end

if any(aw < 0 | aw > 1)
    error('Активність води повинна бути в межах від 0 до 1.');
end

%% Розрахунок за формулами 3.4-3.6

relativeSaturationPct = 100*aw;
saturationPPM = water_solubility(T,cfg);
waterPPM = aw.*saturationPPM;

%% Визначення кількості вимірювань у часових інтервалах

dt = median(diff(t));

if any(abs(diff(t)-dt) > 1e-6*dt)
    error('Для ковзного середнього потрібен рівномірний крок часу.');
end

avgRatio = cfg.moisture.averageWindowH/dt;
lagRatio = cfg.moisture.dailyLagH/dt;
avgSamples = round(avgRatio);
lagSamples = round(lagRatio);

if avgSamples < 1 || lagSamples < 1 || ...
        abs(avgRatio-avgSamples) > 1e-6 || ...
        abs(lagRatio-lagSamples) > 1e-6
    error('Інтервали усереднення мають містити ціле число кроків.');
end

%% Ковзне середнє за повні 24 години, формула 3.7
% До завершення першої доби значення ще недоступне.

average24PPM = nan(N,1);

for k = avgSamples+1:N
    average24PPM(k) = mean(waterPPM(k-avgSamples+1:k));
end

%% Добова зміна, формула 3.8
% Порівнюємо два повні добові середні.
% Перший результат з'явиться після 48 годин.

dailyChangePPM = nan(N,1);

for k = avgSamples+lagSamples+1:N
    dailyChangePPM(k) = ...
        average24PPM(k)-average24PPM(k-lagSamples);
end

%% Діагностичні попередження за поточними показаннями
% Межі умовні; добова зміна є додатковою інформацією.

highWater = waterPPM > cfg.limits.waterPPM;
highSaturation = relativeSaturationPct > ...
    cfg.limits.relativeSaturationPct;

%% Результати

out.waterActivity = aw;
out.waterPPM = waterPPM;
out.saturationPPM = saturationPPM;
out.relativeSaturationPct = relativeSaturationPct;
out.average24PPM = average24PPM;
out.dailyChangePPMperDay = dailyChangePPM;
out.highWater = highWater;
out.highSaturation = highSaturation;
out.warning = highWater | highSaturation;

end
