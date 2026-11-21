
function cfg = monitor_settings()
% НАЛАШТУВАННЯ СИСТЕМИ МОНІТОРИНГУ


%% Параметри моделювання

% Сценарії:
% 1 - Нормальна робота
% 2 - Порушення охолодження
% 3 - Збільшення вмісту вологи
% 4 - Аномальне накопичення газів
% 5 - Одночасне виникнення несправностей
% 6 - Погіршення якості масла

cfg.scenario = 5;

cfg.seed = 7;             % Початкове значення генератора
cfg.durationH = 72;       % Тривалість, год
cfg.dtH = 0.25;           % Крок розрахунку, год

cfg.savePlots = false;    % Збереження графіків

%% Параметри теплової моделі

cfg.thermal.lossRatio = 5;

% Номінальні перевищення температури, °C
cfg.thermal.topOilRiseC = 55;
cfg.thermal.hotSpotRiseC = 25;

% Показники степеня
cfg.thermal.n = 0.8;
cfg.thermal.m = 0.8;

% Сталі часу, год
cfg.thermal.tauOilH = 2.5;
cfg.thermal.tauHotH = 0.5;

%% Параметри моделі вологості

% Умовні коефіцієнти розчинності води
cfg.moisture.satAtRefPPM = 85;
cfg.moisture.refTempC = 40;
cfg.moisture.betaPerC = 0.028;

%% Параметри аналізу газів

cfg.dga.rateWindowH = 4;
cfg.dga.smoothSamples = 5;

%% Діагностичні пороги (умовні)

cfg.limits.thermalResidualC = 5;

cfg.limits.waterPPM = 35;
cfg.limits.relativeSaturationPct = 30;

cfg.limits.h2RatePPMperH = 1.5;
cfg.limits.c2h2PPM = 3;


%% Оцінювання якості трансформаторного масла

% Умовні діагностичні межі для демонстрації.
% Для реальних трансформаторів необхідно
% використовувати критерії відповідного обладнання.

cfg.oilQuality.acidMax = 0.10;       % мг КОН/г
cfg.oilQuality.breakdownMin = 50;    % кВ
cfg.oilQuality.tanDeltaMax = 0.010;  % Безрозмірна величина
cfg.oilQuality.iftMin = 25;          % мН/м


%% Температурно-залежні властивості масла

% Температура, за якої відомі електричні характеристики
cfg.oilProperties.refTempC = 90;

% Енергія активації електропровідності, еВ
% Приклад для сухого мінерального масла з наукової статті
cfg.oilProperties.activationEnergyEV = 0.466;

% Умовний питомий електричний опір за 90 °C, Ом·м
cfg.oilProperties.resistivityRefOhmM = 1e11;

% Умовний тангенс діелектричних втрат за 90 °C
cfg.oilProperties.tanDeltaRef = 0.0025;


end
