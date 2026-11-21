%% ПЕРЕВІРКА НЕЛІНІЙНОЇ ТЕПЛОВОЇ МОДЕЛІ
% Запуск: test_thermal_model

clear;
clc;
cfg = monitor_settings();

%% У номінальному режимі очікуємо 75 °C
rated.tH = [0;0.25];
rated.loadPU = [1;1];
rated.ambientC = [20;20];
ratedResult = model_thermal(rated,cfg);
assert(abs(ratedResult.topOilC(1)-75) < 1e-5, ...
    'Номінальна температура повинна дорівнювати 75 °C.');

%% Нормальна робота
cfg.scenario = 1;
normalData = generate_demo_data(cfg);
normal = model_thermal(normalData,cfg);
assert(all(isfinite(normal.topOilC)), ...
    'Розрахункова температура не є скінченною.');
assert(~any(normal.warning), ...
    'За нормального режиму не має бути теплового попередження.');

%% Порушення охолодження
cfg.scenario = 2;
faultData = generate_demo_data(cfg);
fault = model_thermal(faultData,cfg);
assert(any(fault.warning), ...
    'Не виявлено порушення охолодження.');

firstWarning = find(fault.warning,1,'first');
assert(faultData.tH(firstWarning) > 40, ...
    'Попередження виникло до початку порушення охолодження.');

assert(faultData.oilTempSensorC(end) > ...
    normalData.oilTempSensorC(end)+4, ...
    'Температура не зросла після порушення охолодження.');

%% Прогноз не повинен залежати від показання температурного датчика
changedData = faultData;
changedData.oilTempSensorC = changedData.oilTempSensorC+5;
changed = model_thermal(changedData,cfg);

assert(max(abs(changed.topOilC-fault.topOilC)) < 1e-8, ...
    'Розрахункова температура залежить від показання датчика.');

%% В'язкість повинна зменшуватися при нагріванні
oil = oil_properties_at_temp([35;65]);
assert(oil.viscosity(2) < oil.viscosity(1), ...
    'Неочікувана температурна залежність в’язкості.');

fprintf('\nУСІ ПЕРЕВІРКИ ТЕПЛОВОЇ МОДЕЛІ ПРОЙДЕНО.\n');
fprintf('Перше попередження: %.2f год\n',faultData.tH(firstWarning));
fprintf('Розрахунки виконано з демонстраційними параметрами.\n');
