function data = generate_demo_data(cfg)
% ГЕНЕРАЦІЯ СИНТЕТИЧНИХ ВИМІРЮВАНЬ
% Ці дані не походять від реального трансформатора.

rng(cfg.seed);
t = (0:cfg.dtH:cfg.durationH)';
N = length(t);

%% Навантаження та навколишня температура
loadPU = 0.65+0.10*sin(2*pi*t/24) ...
    +0.10*(t >= 30)+0.07*(t >= 54);
ambientC = 25+4*sin(2*pi*(t-6)/24);

baseData.tH = t;
baseData.loadPU = loadPU;
baseData.ambientC = ambientC;

%% Вибір сценарію
coolingFault = (cfg.scenario == 2 || cfg.scenario == 5);
moistureFault = (cfg.scenario == 3 || cfg.scenario == 5);
gasFault = (cfg.scenario == 4 || cfg.scenario == 5);

%% Температура за порушення охолодження
% Несправність змінює теплообмін, а не додає температуру до датчика.
realCfg = cfg;
realCfg.thermal.coolingEfficiency = ones(N,1);

if coolingFault
    reduction = 0.35*min(max((t-40)/8,0),1);
    realCfg.thermal.coolingEfficiency = 1-reduction;
end

realThermal = model_thermal(baseData,realCfg);
oilTempC = realThermal.topOilC+0.25*randn(N,1);

%% Синтетичні показання датчика активності води
% Фізична динаміка враховує тепловий режим і обмін з папером.
% Лише генератор знає про початкову вологість паперової ізоляції.
waterTruePPM = simulate_moisture_exchange(t,realThermal,cfg,moistureFault);

% Імітація датчика: активність води та температура вимірювання.
% Температурна розчинність впливає на показання aw.
% Сигнал aw відповідає фізичній температурі; датчик T має власну похибку.
waterSaturationPPM = water_solubility(realThermal.topOilC,cfg);
waterActivity = waterTruePPM./waterSaturationPPM ...
    +cfg.moisture.sensorNoiseAw*randn(N,1);

waterActivity = min(max(waterActivity,0),0.999);

%% Синтетичні вимірювання онлайн-газоаналізатора
% 1,5 год між вимірюваннями. Вхідні концентрації задані умовно,
% без моделювання хімічного газоутворення в трансформаторі.
samplingRatio = cfg.dga.measurementIntervalH/cfg.dtH;
samplingStep = round(samplingRatio);
if samplingStep < 1 || abs(samplingRatio-samplingStep) > 1e-8
    error('Крок газоаналізатора має бути кратним часовому кроку.');
end

gasMeasurementMask = false(N,1);
gasMeasurementMask(1:samplingStep:end) = true;
tGas = t(gasMeasurementMask);
ramp = gasFault*max(tGas-50,0);

% Умовний фоновий газовий склад і його зміна після 50-ї години.
gasReadings = [35+0.06*tGas+3.3*ramp, ...
               10+0.025*tGas+1.0*ramp, ...
               4+0.01*tGas+0.5*ramp, ...
               5+0.02*tGas+1.2*ramp, ...
               0.2+gasFault*0.35*max(tGas-60,0), ...
               180+0.1*tGas+gasFault*2.5*max(tGas-55,0), ...
               1800+tGas+gasFault*6.0*max(tGas-55,0)];

% Невеликий умовний шум кожного вимірювання.
sensorNoise = [0.4 0.2 0.10 0.15 0.02 1.2 4];
gasReadings = max(gasReadings + ...
    bsxfun(@times,randn(numel(tGas),7),sensorNoise),0);

% На сітці 15 хв утримується останнє показання газоаналізатора.
% Воно не вважається новим вимірюванням у розрахунку середнього.
lastGasIndex = floor(((1:N)'-1)/samplingStep)+1;
gasHeld = gasReadings(lastGasIndex,:);

%% Формування вимірювань
data.tH = t;
data.loadPU = loadPU;
data.ambientC = ambientC;
data.oilTempSensorC = oilTempC;
data.waterActivity = waterActivity;
data.dgaMeasurementMask = gasMeasurementMask;
data.h2PPM = gasHeld(:,1);
data.ch4PPM = gasHeld(:,2);
data.c2h6PPM = gasHeld(:,3);
data.c2h4PPM = gasHeld(:,4);
data.c2h2PPM = gasHeld(:,5);
data.coPPM = gasHeld(:,6);
data.co2PPM = gasHeld(:,7);

%% Лабораторні показники (три окремі аналізи за шість місяців)
data.lab.month = [-6; -3; 0];
oilAgeing = (cfg.scenario == 5 || cfg.scenario == 6);

if oilAgeing
    data.lab.acid = [0.03; 0.06; 0.14];
    data.lab.breakdownKV = [72; 62; 45];
    data.lab.tanDelta = [0.0015; 0.005; 0.012];
    data.lab.ift = [43; 33; 24];
else
    data.lab.acid = [0.03; 0.035; 0.04];
    data.lab.breakdownKV = [72; 70; 68];
    data.lab.tanDelta = [0.0015; 0.002; 0.0025];
    data.lab.ift = [43; 42; 41];
end
end
