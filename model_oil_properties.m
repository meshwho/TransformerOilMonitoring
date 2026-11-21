function oil = model_oil_properties(data, cfg)
% ТЕМПЕРАТУРНО-ЗАЛЕЖНІ ВЛАСТИВОСТІ МАСЛА
% Теплофізичні дані з МАН; електричні значення демонстраційні.

T = data.oilTempSensorC(:);

%% Єдина таблиця теплофізичних властивостей
properties = oil_properties_at_temp(T);
oil.viscosity = properties.viscosity;
oil.density = properties.density;
oil.heatCapacity = properties.heatCapacity;
oil.conductivity = properties.conductivity;
oil.expansion = properties.expansion;

oil40 = oil_properties_at_temp(40);
oil.viscosityRelative = oil.viscosity/oil40.viscosity;

%% Питомий електричний опір за спрощеним законом Арреніуса
T_K = T+273.15;
Tref_K = cfg.oilProperties.refTempC+273.15;
kB = 8.617333262e-5;   % еВ/К
Ea = cfg.oilProperties.activationEnergyEV;
rhoRef = cfg.oilProperties.resistivityRefOhmM;

oil.resistivity = rhoRef.*exp( ...
    (Ea/kB).*(1./T_K-1/Tref_K));

%% Тангенс втрат за припущення домінування провідності
tanDeltaRef = cfg.oilProperties.tanDeltaRef;

% Результат лабораторії має бути отриманий при опорній температурі.
if isfield(data,'lab') && isfield(data.lab,'tanDelta')
    if ~isempty(data.lab.tanDelta)
        tanDeltaRef = data.lab.tanDelta(end);
    end
end

oil.tanDelta = tanDeltaRef.*rhoRef./oil.resistivity;
oil.temperatureC = T;
oil.referenceTempC = cfg.oilProperties.refTempC;
oil.resistivityRef = rhoRef;
oil.tanDeltaRef = tanDeltaRef;
end
