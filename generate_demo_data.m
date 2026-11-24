function data = generate_demo_data(cfg)
% Ці дані не походять від реального трансформатора.

rng(cfg.seed);
t = (0:cfg.dtH:cfg.durationH)';
N = length(t);

loadPU = 0.65+0.10*sin(2*pi*t/24) ...
    +0.10*(t >= 30)+0.07*(t >= 54);
ambientC = 25+4*sin(2*pi*(t-6)/24);

baseData.tH = t;
baseData.loadPU = loadPU;
baseData.ambientC = ambientC;

coolingFault = (cfg.scenario == 2 || cfg.scenario == 5);
moistureFault = (cfg.scenario == 3 || cfg.scenario == 5);
gasFault = (cfg.scenario == 4 || cfg.scenario == 5);

% Несправність змінює теплообмін, а не додає температуру до датчика.
realCfg = cfg;
realCfg.thermal.coolingEfficiency = ones(N,1);

if coolingFault
    reduction = 0.35*min(max((t-cfg.fault.coolingStartH)/8,0),1);
    realCfg.thermal.coolingEfficiency = 1-reduction;
end

realThermal = model_thermal(baseData,realCfg);
oilTempC = realThermal.topOilC+0.25*randn(N,1);

waterTruePPM = simulate_moisture_exchange(t,realThermal,cfg,moistureFault);

% Сигнал aw відповідає фізичній температурі; датчик T має власну похибку.
waterSaturationPPM = water_solubility(realThermal.topOilC,cfg);
waterActivity = waterTruePPM./waterSaturationPPM ...
    +cfg.moisture.sensorNoiseAw*randn(N,1);

waterActivity = min(max(waterActivity,0),0.999);

samplingRatio = cfg.dga.measurementIntervalH/cfg.dtH;
samplingStep = round(samplingRatio);
if samplingStep < 1 || abs(samplingRatio-samplingStep) > 1e-8
    error('Крок газоаналізатора має бути кратним часовому кроку.');
end

gasMeasurementMask = false(N,1);
gasMeasurementMask(1:samplingStep:end) = true;
tGas = t(gasMeasurementMask);
ramp = gasFault*max(tGas-cfg.fault.gasStartH,0);

% Умовний фоновий газовий склад і його зміна після 50-ї години.
gasReadings = [35+0.06*tGas+3.3*ramp, ...
               10+0.025*tGas+1.0*ramp, ...
               4+0.01*tGas+0.5*ramp, ...
               5+0.02*tGas+1.2*ramp, ...
               0.2+gasFault*0.35*max(tGas-60,0), ...
               180+0.1*tGas+gasFault*2.5*max(tGas-55,0), ...
               1800+tGas+gasFault*6.0*max(tGas-55,0)];

sensorNoise = [0.4 0.2 0.10 0.15 0.02 1.2 4];
gasReadings = max(gasReadings + ...
    randn(numel(tGas),7).*sensorNoise,0);

% На сітці 15 хв утримується останнє показання газоаналізатора.
% Воно не вважається новим вимірюванням у розрахунку середнього.
lastGasIndex = floor(((1:N)'-1)/samplingStep)+1;
gasHeld = gasReadings(lastGasIndex,:);

data.tH = t;

% Задаються сценарієм, а не діагностичними попередженнями.
% Для неактивних несправностей залишається NaN.
data.faultStartH.cooling = nan;
data.faultStartH.moisture = nan;
data.faultStartH.gas = nan;
data.faultStartH.dielectric = nan;
if coolingFault
    data.faultStartH.cooling = cfg.fault.coolingStartH;
end
if moistureFault
    data.faultStartH.moisture = cfg.moisture.ingressStartH;
end
if gasFault
    data.faultStartH.gas = cfg.fault.gasStartH;
end
if cfg.scenario == 5 || cfg.scenario == 6
    data.faultStartH.dielectric = cfg.oilProperties.changeStartH;
end
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

% Зміна стану (сценарії 5 і 6) НЕ є моделлю хімічного старіння.
diel = cfg.oilProperties;
epsilon0 = 8.8541878128e-12;   % Ф/м
kB = 8.617333262e-5;         % еВ/К

dielectricChange = (cfg.scenario == 5 || cfg.scenario == 6);
changeProgress = min(max((t-diel.changeStartH)/ ...
    diel.changeDurationH,0),1);
conditionFactor = 1+dielectricChange*diel.changeRelative*changeProgress;

sigmaReference = diel.initialConductivitySperM*conditionFactor;

temperatureTrueK = realThermal.topOilC+273.15;
temperatureRefK = diel.refTempC+273.15;
sigmaTrue = sigmaReference.*exp(-diel.activationEnergyEV/kB.* ...
    (1./temperatureTrueK-1/temperatureRefK));

epsilonRelativeTrue = diel.initialPermittivity+ ...
    diel.permittivityTempSlopePerC.* ...
    (realThermal.topOilC-diel.refTempC);

% Калібрувальна ємність порожньої комірки Cvac = epsilon0*A/d.
% Ефективна провідність G = sigma*A/d, ємність C = epsr*Cvac.
oilConductanceS = sigmaTrue*diel.vacuumCapacitanceF/epsilon0;
oilCapacitanceF = epsilonRelativeTrue*diel.vacuumCapacitanceF;

oilConductanceS = oilConductanceS.* ...
    (1+diel.conductanceNoiseRelative*randn(N,1));
oilCapacitanceF = oilCapacitanceF.* ...
    (1+diel.capacitanceNoiseRelative*randn(N,1));

data.oilConductanceS = oilConductanceS;
data.oilCapacitanceF = oilCapacitanceF;
end
