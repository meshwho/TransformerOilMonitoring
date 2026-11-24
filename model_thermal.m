function out = model_thermal(data, cfg)
% Гаряча точка: двокомпонентна модель IEC 60076-7.
% Параметри поки демонстраційні, не калібровані за вимірюваннями.

t = data.tH(:);
K = data.loadPU(:);
Tamb = data.ambientC(:);
p = cfg.thermal;
N = length(t);

if N < 2 || length(K) ~= N || length(Tamb) ~= N
    error('Неправильна довжина вхідних масивів.');
end
if any(diff(t) <= 0) || any(~isfinite([t; K; Tamb])) || any(K < 0)
    error('Некоректні вхідні дані теплової моделі.');
end

cooling = p.coolingEfficiency;
if isscalar(cooling)
    cooling = cooling*ones(N,1);
else
    cooling = cooling(:);
end
if length(cooling) ~= N || any(~isfinite(cooling)) || ...
        any(cooling <= 0 | cooling > 1)
    error('Ефективність охолодження повинна бути в межах (0; 1].');
end

ratedTemp = p.ratedAmbientC+p.topOilRiseC;
ratedOil = oil_properties_at_temp(ratedTemp);
muRated = ratedOil.viscosity;

balance0 = @(T) oil_heat_balance( ...
    T,K(1),Tamb(1),cooling(1),p,muRated);

if Tamb(1) < -15 || Tamb(1) >= 100 || balance0(100) > 0
    error('Початковий тепловий стан поза температурною таблицею.');
end
T0 = fzero(balance0,[Tamb(1),100]);

hotRise0 = p.hotSpotRiseC*K(1)^p.hotSpotExponent;
h1_0 = p.k21*hotRise0;
h2_0 = (p.k21-1)*hotRise0;
Y0 = [T0; h1_0; h2_0];

maxStep = min(min(diff(t))/2,p.tauWindingH/2);
options = odeset('RelTol',1e-7,'AbsTol',1e-8,'MaxStep',maxStep);

[~,Y] = ode45(@(time,Y) thermal_equations( ...
    time,Y,t,K,Tamb,cooling,p,muRated),t,Y0,options);

topOilC = Y(:,1);
hotSpotC = topOilC+Y(:,2)-Y(:,3);

oil = oil_properties_at_temp(topOilC);
viscosityRelative = oil.viscosity/muRated;

residualC = nan(N,1);
warning = false(N,1);
measuredViscosityRelative = nan(N,1);

if isfield(data,'oilTempSensorC')
    measured = data.oilTempSensorC(:);
    if length(measured) ~= N
        error('Неправильна кількість показань температурного датчика.');
    end
    residualC = measured-topOilC;
    warning = abs(residualC) > cfg.limits.thermalResidualC;
    measuredOil = oil_properties_at_temp(measured);
    measuredViscosityRelative = measuredOil.viscosity/muRated;
end

out.topOilC = topOilC;
out.hotSpotC = hotSpotC;
out.residualC = residualC;
out.warning = warning;
out.viscosityRelative = viscosityRelative;
out.measuredViscosityRelative = measuredViscosityRelative;
out.oilProperties = oil;
end

function dY = thermal_equations(time,Y,t,K,Tamb,cooling,p,muRated)
loadNow = interp1(t,K,time,'linear');
ambientNow = interp1(t,Tamb,time,'linear');
coolingNow = interp1(t,cooling,time,'linear');

dOil = oil_heat_balance( ...
    Y(1),loadNow,ambientNow,coolingNow,p,muRated)/p.tauOilH;

targetRise = p.hotSpotRiseC*loadNow^p.hotSpotExponent;
dH1 = (p.k21*targetRise-Y(2))/(p.k22*p.tauWindingH);
dH2 = ((p.k21-1)*targetRise-Y(3))/(p.tauOilH/p.k22);

dY = [dOil; dH1; dH2];
end

function balance = oil_heat_balance(Toil,K,Tamb,cooling,p,muRated)
oil = oil_properties_at_temp(Toil);
muPU = oil.viscosity/muRated;

R = p.lossRatio;
deltaRated = p.topOilRiseC;
n = p.n;

heatInput = deltaRated*(1+R*K^2)/(1+R);
deltaT = Toil-Tamb;
heatOutput = cooling*sign(deltaT)* ...
    abs(deltaT)^(1+n)/(muPU*deltaRated)^n;

balance = heatInput-heatOutput;
end
