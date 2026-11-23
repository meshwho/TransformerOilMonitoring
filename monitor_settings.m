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

%% Моменти виникнення штучних несправностей у сценаріях
cfg.fault.coolingStartH = 40;  % Початок порушення охолодження
cfg.fault.gasStartH = 50;      % Початок додаткового газоутворення
% Волога: cfg.moisture.ingressStartH (46 год)
% Електричні властивості: cfg.oilProperties.changeStartH (36 год)

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

%% Аналіз газів: обробка показань онлайн-аналізатора
% Типовий демонстраційний цикл вимірювання 1,5 години.
cfg.dga.measurementIntervalH = 1.5;
cfg.dga.averageWindowH = 24;        % Добове середнє, год
cfg.dga.dailyLagH = 24;             % Порівняння з попередньою добою, год
cfg.dga.minReliableSamples = 5;     % Мінімум вимірювань для середнього
% Умовні мінімальні концентрації для розрахунку газових відношень, ppm_v.
% Порядок: H2, CH4, C2H6, C2H4, C2H2, CO, CO2.
cfg.dga.ratioMinimumPPM = [5 5 5 5 1 20 100];

%% Демонстраційні пороги, не нормативні значення
cfg.limits.thermalResidualC = 5;
cfg.limits.waterPPM = 35;
cfg.limits.relativeSaturationPct = 30;
cfg.limits.h2RatePPMperH = 1.0;
cfg.limits.c2h2PPM = 3;

%% Довідкові діапазони RS за IEC 60422:2024, додаток B
% Good: <10%; Fair: 10-20%; Poor: >20%.
% 72 год недостатньо для остаточного оцінювання (потрібен >= 1 місяць).
cfg.referenceRS.goodUpperPct = 10;
cfg.referenceRS.fairUpperPct = 20;

%% Окремі демонстраційні межі електричних показників
% Вони НЕ є універсальними нормативами IEC.
cfg.limits.tanDeltaRef = 0.004;
cfg.limits.kSigma = 1.5;
% Умовні межі середніх концентрацій і швидкостей їх зміни.
% Порядок: H2, CH4, C2H6, C2H4, C2H2, CO, CO2.
cfg.limits.dgaConcentrationPPM = [70 40 20 25 3 250 5000];
cfg.limits.dgaRatePPMperH = [cfg.limits.h2RatePPMperH ...
    0.35 0.20 0.40 0.08 0.70 2.0];

%% Оцінювання якості масла
cfg.oilQuality.acidMax = 0.10;
cfg.oilQuality.breakdownMin = 50;
cfg.oilQuality.tanDeltaMax = 0.010;
cfg.oilQuality.iftMin = 25;

%% Онлайн-контроль діелектричних властивостей масла (підрозділ 3.5)
% Демонстраційна вимірювальна комірка: G, C та температура T.
% Геометрична стала виводиться з ємності порожньої комірки.
cfg.oilProperties.vacuumCapacitanceF = 100e-12;  % Ф
cfg.oilProperties.frequencyHz = 50;              % Гц
cfg.oilProperties.refTempC = 65;                  % °C
cfg.oilProperties.activationEnergyEV = 0.466;    % умовний параметр
cfg.oilProperties.initialConductivitySperM = 1e-11; % См/м при Tref
cfg.oilProperties.initialPermittivity = 2.2;
cfg.oilProperties.permittivityTempSlopePerC = -0.0015;

% Похибка синтетичних вимірювань (відносна).
cfg.oilProperties.conductanceNoiseRelative = 0.002;
cfg.oilProperties.capacitanceNoiseRelative = 0.0003;

% Штучна прискорена зміна стану масла у сценаріях 5 і 6.
% Це НЕ модель швидкості хімічного окиснення.
cfg.oilProperties.changeStartH = 36;
cfg.oilProperties.changeDurationH = 36;
cfg.oilProperties.changeRelative = 0.60;
end
