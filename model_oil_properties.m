function oil = model_oil_properties(data,cfg)

T = data.oilTempSensorC(:);
G = data.oilConductanceS(:);
C = data.oilCapacitanceF(:);
N = numel(T);
if N < 2 || numel(G) ~= N || numel(C) ~= N || ...
        any(~isfinite([T;G;C])) || any(G <= 0) || any(C <= 0)
    error('Некоректні показання діелектричного датчика.');
end

properties = oil_properties_at_temp(T);
oil.viscosity = properties.viscosity;
oil.density = properties.density;
oil.heatCapacity = properties.heatCapacity;
oil.conductivity = properties.conductivity;
oil.expansion = properties.expansion;

oil40 = oil_properties_at_temp(40);
oil.viscosityRelative = oil.viscosity/oil40.viscosity;

p = cfg.oilProperties;
epsilon0 = 8.8541878128e-12;    % Ф/м
Cvac = p.vacuumCapacitanceF;     % Ф, калібрувальна ємність
frequency = p.frequencyHz;       % Гц
if ~isfinite(Cvac) || ~isfinite(frequency) || ...
        Cvac <= 0 || frequency <= 0
    error('Некоректні параметри вимірювальної комірки.');
end

% Cvac = epsilon0*A/d. Отже d/A = epsilon0/Cvac.
epsilonRelative = C/Cvac;
sigma = G*epsilon0/Cvac;
tanDelta = G./(2*pi*frequency*C);

% Поправка Арреніуса є наближеною та потребує калібрування.
TK = T+273.15;
TrefK = p.refTempC+273.15;
kB = 8.617333262e-5;           % еВ/К
Ea = p.activationEnergyEV;

if any(TK <= 0) || TrefK <= 0 || ~isfinite(Ea) || Ea <= 0
    error('Некоректні температурні параметри.');
end

sigmaRef = sigma.*exp((Ea/kB).*(1./TK-1/TrefK));
epsilonRef = epsilonRelative- ...
    p.permittivityTempSlopePerC.*(T-p.refTempC);

if any(epsilonRef <= 0)
    error('Некоректна скоригована діелектрична проникність.');
end

tanDeltaRef = sigmaRef./(2*pi*frequency*epsilon0*epsilonRef);

conditionIndex = sigmaRef/sigmaRef(1);

oil.temperatureC = T;
oil.conductanceS = G;
oil.capacitanceF = C;
oil.conductivitySperM = sigma;
oil.conductivityRefSperM = sigmaRef;
oil.permittivityRelative = epsilonRelative;
oil.permittivityRef = epsilonRef;
oil.tanDelta = tanDelta;
oil.tanDeltaRef = tanDeltaRef;
oil.conditionIndex = conditionIndex;
oil.resistivity = 1./sigma;
oil.resistivityRef = 1./sigmaRef;
oil.referenceTempC = p.refTempC;

end
