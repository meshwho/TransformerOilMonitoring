%% ПЕРЕВІРКА МОДЕЛІ ВОЛОГОВМІСТУ (3.4-3.8)
% Запуск у MATLAB: test_moisture_model

clear;
clc;
cfg = monitor_settings();

%% Перевірка розчинності з температурою

Csat = water_solubility([20;40;70],cfg);
assert(all(diff(Csat) > 0), ...
    'Розчинність води має зростати з температурою.');

%% Відомий сигнал датчика: aw = 0.2 при 40 °C

t = (0:cfg.dtH:48)';
data.tH = t;
data.oilTempSensorC = 40*ones(size(t));
data.waterActivity = 0.2*ones(size(t));

result = model_moisture(data,cfg);

assert(all(abs(result.relativeSaturationPct-20) < 1e-10), ...
    'Неправильний розрахунок відносного насичення.');
assert(all(abs(result.waterPPM-0.2*Csat(2)) < 1e-10), ...
    'Неправильний перерахунок активності води у мг/кг.');

%% Для усереднення потрібні 24 год, для зміни - 48 год

assert(all(isnan(result.average24PPM(t < 24))), ...
    'Середнє з’являється раніше 24 годин.');
assert(all(isnan(result.dailyChangePPMperDay(t < 48))), ...
    'Добова зміна з’являється раніше 48 годин.');

assert(isfinite(result.average24PPM(end)) && ...
       abs(result.dailyChangePPMperDay(end)) < 1e-10, ...
    'Для постійної вологості добова зміна має бути нульовою.');

%% Температура змінюється, але концентрація води постійна

data.oilTempSensorC = 60+10*sin(2*pi*t/24);
data.waterActivity = 20./water_solubility(data.oilTempSensorC,cfg);

constantWater = model_moisture(data,cfg);

assert(max(abs(constantWater.waterPPM-20)) < 1e-10, ...
    'Концентрація води повинна залишатися незмінною.');
assert(abs(constantWater.dailyChangePPMperDay(end)) < 1e-10, ...
    'Температурні коливання створили штучну добову зміну.');

%% Порівняння двох сценаріїв синтетичних вимірювань

cfg.scenario = 1;
normalData = generate_demo_data(cfg);
normal = model_moisture(normalData,cfg);
assert(~any(normal.warning), ...
    'Нормальний сценарій не повинен давати тривоги вологості.');

cfg.scenario = 3;
faultData = generate_demo_data(cfg);
fault = model_moisture(faultData,cfg);
assert(any(fault.warning), ...
    'Підвищення вологовмісту не було виявлено.');
assert(fault.dailyChangePPMperDay(end) > ...
    normal.dailyChangePPMperDay(end), ...
    'Добова зміна не відображає підвищення вологовмісту.');

fprintf('\nУСІ ПЕРЕВІРКИ МОДЕЛІ ВОЛОГОВМІСТУ ПРОЙДЕНО.\n');
fprintf('Добова зміна для сценарію з підвищенням: %.2f мг/кг за добу\n', ...
    fault.dailyChangePPMperDay(end));
