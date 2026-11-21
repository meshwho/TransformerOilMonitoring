
function oil = model_oil_properties(data, cfg)
% МАТЕМАТИЧНА МОДЕЛЬ ВЛАСТИВОСТЕЙ МАСЛА
%
% Розрахунок теплофізичних та електричних
% характеристик масла залежно від температури.
%
% Теплофізичні дані взято з таблиць МАН.
% Електричні характеристики розраховуються
% за спрощеною моделлю Арреніуса.

%% 1. Температура масла

T = data.oilTempSensorC;

%% 2. Табличні дані з МАН

% Температура, °C
temp = [-15 -5 5 15 25 35 45 55 65 75 85 100];

% Густина, кг/м^3
density = [902 896 890 884 879 873 ...
           867 861 855 849 844 835];

% Питома теплоємність, Дж/(кг·К)
heatCapacity = [1700 1740 1785 1825 ...
                1870 1910 1950 1995 ...
                2040 2080 2120 2180];

% Теплопровідність, Вт/(м·К)
conductivity = [0.1341 0.1333 0.1326 0.1318 ...
                0.1310 0.1303 0.1295 0.1287 ...
                0.1280 0.1272 0.1264 0.1253];

% Коефіцієнт об'ємного розширення, 1/К
expansion = [6.2 6.4 6.7 6.9 7.15 7.4 ...
             7.65 7.8 7.9 7.95 8 8]*1e-4;

% В'язкість (значення з таблиці МАН)
viscosity = [0.0694 0.0463 0.0318 0.0224 ...
             0.0162 0.0119 0.0089 0.0068 ...
             0.0053 0.0042 0.0033 0.0024];

%% 3. Перевірка температурного діапазону

if any(T < min(temp)) || any(T > max(temp))

    warning(['Температура виходить за межі таблиці. ', ...
             'Використовуються крайні значення.']);

end

% Обмеження температури діапазоном таблиці
T = max(min(T,max(temp)),min(temp));

%% 4. Розрахунок теплофізичних характеристик

% Інтерполяція між табличними значеннями
oil.density = interp1(temp,density,T,'pchip');

oil.heatCapacity = interp1( ...
    temp,heatCapacity,T,'pchip');

oil.conductivity = interp1( ...
    temp,conductivity,T,'pchip');

oil.expansion = interp1( ...
    temp,expansion,T,'pchip');

oil.viscosity = interp1( ...
    temp,viscosity,T,'pchip');

%% 5. Відносна в'язкість

% В'язкість за температури 40 °C
viscosity40 = interp1(temp,viscosity,40,'pchip');

oil.viscosityRelative = ...
    oil.viscosity ./ viscosity40;

%% 6. Питомий електричний опір

% Температура в кельвінах
T_K = T + 273.15;

% Опорна температура
Tref_K = cfg.oilProperties.refTempC + 273.15;

% Стала Больцмана, еВ/К
kB = 8.617333262e-5;

% Енергія активації, еВ
Ea = cfg.oilProperties.activationEnergyEV;

% Питомий опір за опорної температури
rhoRef = cfg.oilProperties.resistivityRefOhmM;

% Температурна залежність за Арреніусом
oil.resistivity = rhoRef .* exp( ...
    (Ea/kB) .* (1./T_K - 1/Tref_K));

%% 7. Тангенс діелектричних втрат

% Опорне значення tg delta
tanDeltaRef = cfg.oilProperties.tanDeltaRef;

% За наявності лабораторних даних
% використовуємо останній результат
if isfield(data,'lab')

    if isfield(data.lab,'tanDelta')

        if ~isempty(data.lab.tanDelta)
            tanDeltaRef = data.lab.tanDelta(end);
        end

    end

end

% Спрощена залежність для провідникових втрат
% Припускаємо незмінний склад масла та
% домінування провідникових втрат.

oil.tanDelta = tanDeltaRef .* ...
    rhoRef ./ oil.resistivity;

%% 8. Додаткові результати

oil.temperatureC = T;
oil.referenceTempC = cfg.oilProperties.refTempC;

oil.resistivityRef = rhoRef;
oil.tanDeltaRef = tanDeltaRef;

end
