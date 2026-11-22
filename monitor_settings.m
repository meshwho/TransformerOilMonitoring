function cfg = monitor_settings()
% НАЛАШТУВАННЯ СИСТЕМИ МОНІТОРИНГУ

%% Моделювання
% Сценарії: 1 - норма; 2 - охолодження; 3 - волога;
% 4 - гази; 5 - усі несправності; 6 - старіння масла.
cfg.scenario = 5;
cfg.seed = 7;
cfg.durationH = 72;     % год
cfg.dtH = 0.25;         % год
cfg.savePlots = false;

%% Нелінійна теплова модель масла (МАН, 3.13)
% Коефіцієнти демонстраційні, не визначені за паспортом трансформатора.
cfg.thermal.lossRatio = 5;
cfg.thermal.topOilRiseC = 55;
cfg.thermal.ratedAmbientC = 20;
cfg.thermal.n = 0.8;                % ONAN
cfg.thermal.tauOilH = 2.5;
cfg.thermal.coolingEfficiency = 1; % 1 - справне охолодження

%% Динамічна модель гарячої точки (IEC 60076-7)
cfg.thermal.hotSpotRiseC = 25;
cfg.thermal.hotSpotExponent = 1.6;
cfg.thermal.k21 = 1.3;
cfg.thermal.k22 = 2;
cfg.thermal.tauWindingH = 0.12;

%% Модель вологовмісту (формули 3.4-3.8)
% Розчинність для одного зразка мінерального масла, CIGRE 349.
cfg.moisture.solubilityC0PPM = 16.97e6;  % мг/кг
cfg.moisture.solubilityBK = 3777;        % К

% Умовний трансформатор та початковий стан
cfg.moisture.oilMassKg = 10000;          % Маса масла, кг
cfg.moisture.paperMassKg = 1000;         % Маса сухої целюлози, кг
cfg.moisture.initialOilPPM = 16;         % Початковий вміст води, мг/кг
cfg.moisture.initialPaperWaterPct = 2;   % Частка води від сухої маси паперу, %

% Наближена динаміка обміну вологою між маслом і целюлозою
% Параметри умовні; потрібна калібровка за вимірюваннями.
cfg.moisture.paperTemperatureFactor = 0.25;
cfg.moisture.paperSorptionExponent = 2;
cfg.moisture.desorptionTauH = 4;         % Віддача води папером, год
cfg.moisture.absorptionTauH = 12;        % Поглинання води папером, год

% Додаткове надходження води при порушенні герметичності (сценарії 3 і 5)
cfg.moisture.ingressStartH = 46;         % Початок несправності, год
cfg.moisture.ingressGperH = 15;          % Умовний сильний витік, г/год

% Обробка показань та умовний шум датчика
cfg.moisture.averageWindowH = 24;
cfg.moisture.dailyLagH = 24;
cfg.moisture.sensorNoiseAw = 0.001;

%% Аналіз газів
cfg.dga.rateWindowH = 4;
cfg.dga.smoothSamples = 5;

%% Демонстраційні пороги, не нормативні значення
cfg.limits.thermalResidualC = 5;
cfg.limits.waterPPM = 35;
cfg.limits.relativeSaturationPct = 30;
cfg.limits.h2RatePPMperH = 1.5;
cfg.limits.c2h2PPM = 3;

%% Оцінювання якості масла
cfg.oilQuality.acidMax = 0.10;
cfg.oilQuality.breakdownMin = 50;
cfg.oilQuality.tanDeltaMax = 0.010;
cfg.oilQuality.iftMin = 25;

%% Електричні характеристики (умовні коефіцієнти)
cfg.oilProperties.refTempC = 90;
cfg.oilProperties.activationEnergyEV = 0.466;
cfg.oilProperties.resistivityRefOhmM = 1e11;
cfg.oilProperties.tanDeltaRef = 0.0025;
end
