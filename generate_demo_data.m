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

%% Вода
waterPPM = 14+0.05*t ...
    +moistureFault*2.1*max(t-46,0)+0.25*randn(N,1);
waterPPM = max(waterPPM,0);

%% Розчинені гази
h2 = 35+0.06*t+gasFault*3.3*max(t-50,0)+0.25*randn(N,1);
ch4 = 10+0.025*t+gasFault*1.0*max(t-50,0);
c2h6 = 4+0.01*t+gasFault*0.5*max(t-50,0);
c2h4 = 5+0.02*t+gasFault*1.2*max(t-50,0);
c2h2 = 0.2+gasFault*0.35*max(t-60,0);
co = 180+0.1*t+gasFault*2.5*max(t-55,0);
co2 = 1800+t+gasFault*6.0*max(t-55,0);

%% Формування вимірювань
data.tH = t;
data.loadPU = loadPU;
data.ambientC = ambientC;
data.oilTempSensorC = oilTempC;
data.waterPPM = waterPPM;
data.h2PPM = max(h2,0);
data.ch4PPM = max(ch4,0);
data.c2h6PPM = max(c2h6,0);
data.c2h4PPM = max(c2h4,0);
data.c2h2PPM = max(c2h2,0);
data.coPPM = max(co,0);
data.co2PPM = max(co2,0);

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
