
function out = model_thermal(data, cfg)
% МАТЕМАТИЧНА МОДЕЛЬ ТЕПЛОВОГО СТАНУ
%
% Розрахунок температури верхніх шарів масла
% та гарячої точки обмотки трансформатора.

t = data.tH;
K = data.loadPU;
Tamb = data.ambientC;

N = length(t);

R = cfg.thermal.lossRatio;
n = cfg.thermal.n;
m = cfg.thermal.m;

%% Температура верхніх шарів масла

% Усталене перевищення температури
oilRise = cfg.thermal.topOilRiseC .* ...
    ((1 + R*K.^2)/(1 + R)).^n;

topTargetC = Tamb + oilRise;

%% Температура гарячої точки

% Перевищення температури над температурою масла
hotRise = cfg.thermal.hotSpotRiseC .* K.^(2*m);

%% Коефіцієнти теплової інерції

alphaOil = 1 - exp( ...
    -cfg.dtH/cfg.thermal.tauOilH);

alphaHot = 1 - exp( ...
    -cfg.dtH/cfg.thermal.tauHotH);

%% Початкові значення

topOilC = zeros(N,1);
hotGradientC = zeros(N,1);

topOilC(1) = topTargetC(1);
hotGradientC(1) = hotRise(1);

%% Розрахунок зміни температури в часі

for k = 2:N

    topOilC(k) = topOilC(k-1) ...
        + alphaOil*(topTargetC(k)-topOilC(k-1));

    hotGradientC(k) = hotGradientC(k-1) ...
        + alphaHot*(hotRise(k)-hotGradientC(k-1));

end

hotSpotC = topOilC + hotGradientC;

%% Порівняння з виміряною температурою

residualC = nan(N,1);
warning = false(N,1);

if isfield(data,'oilTempSensorC')

    residualC = data.oilTempSensorC - topOilC;

    warning = abs(residualC) > ...
        cfg.limits.thermalResidualC;

end

%% Результати

out.topOilC = topOilC;
out.hotSpotC = hotSpotC;
out.residualC = residualC;
out.warning = warning;

end
