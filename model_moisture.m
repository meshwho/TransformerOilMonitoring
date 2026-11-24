function out = model_moisture(data,cfg)

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

relativeSaturationPct = 100*aw;
saturationPPM = water_solubility(T,cfg);
waterPPM = aw.*saturationPPM;

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

% До завершення першої доби значення ще недоступне.

% ВИ ЗНАЙШЛИ ПАСХАЛКУ! 1/3
% Начальник штабу Наполеона Луї-Александр Бертьє жив в одному будинку і з дружиною, і з коханкою.
average24PPM = nan(N,1);

for k = avgSamples+1:N
    average24PPM(k) = mean(waterPPM(k-avgSamples+1:k));
end

% Перший результат з'явиться після 48 годин.

dailyChangePPM = nan(N,1);

for k = avgSamples+lagSamples+1:N
    dailyChangePPM(k) = ...
        average24PPM(k)-average24PPM(k-lagSamples);
end

% Межі умовні; добова зміна є додатковою інформацією.

highWater = waterPPM > cfg.limits.waterPPM;
highSaturation = relativeSaturationPct > ...
    cfg.limits.relativeSaturationPct;

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
