function state = evaluate_state(thermal,moisture,dga,oil,cfg)
% КОМПЛЕКСНА ДІАГНОСТИКА ОНЛАЙН-ДАНИХ, ПІДРОЗДІЛ 3.6
% Без інтегрального бала. Чотири окремі діагностичні канали.

rs = moisture.relativeSaturationPct(:);
tanRef = oil.tanDeltaRef(:);
kSigma = oil.conditionIndex(:);
wThermal = logical(thermal.warning(:));
wDGA = logical(dga.warning(:));
n = numel(rs);

if n < 2 || any([numel(tanRef),numel(kSigma),numel(wThermal),numel(wDGA)] ~= n)
    error('Діагностичні часові ряди мають різну довжину.');
end

%% Діапазони відносного насичення водою за IEC 60422:2024, додаток B
goodMax = cfg.referenceRS.goodUpperPct;
fairMax = cfg.referenceRS.fairUpperPct;
if goodMax <= 0 || fairMax <= goodMax
    error('Некоректні межі діапазонів RS.');
end
validRS = isfinite(rs) & rs >= 0 & rs <= 100;
rsBand = zeros(n,1);                 % 0 - даних немає
rsBand(validRS & rs < goodMax) = 1;  % Good: нижче 10 %
rsBand(validRS & rs >= goodMax & rs <= fairMax) = 2; % Fair
rsBand(validRS & rs > fairMax) = 3; % Poor: вище 20 %
% 72 години недостатньо для остаточної класифікації за IEC.

%% Зміна приведеного тангенса втрат (формула 3.24)
validDielectric = isfinite(tanRef) & tanRef >= 0 & ...
    isfinite(kSigma) & kSigma > 0;
deltaTan = nan(n,1);
if validDielectric(1)
    deltaTan(validDielectric) = tanRef(validDielectric)-tanRef(1);
end

%% Окремі порогові попередження
% Межі електричних показників є умовними, НЕ нормами IEC.
if cfg.limits.tanDeltaRef <= 0 || cfg.limits.kSigma <= 0
    error('Демонстраційні діелектричні межі мають бути додатними.');
end
state.moisture = logical(moisture.warning(:)) & validRS;
state.dielectric = validDielectric & ...
    (tanRef > cfg.limits.tanDeltaRef | kSigma > cfg.limits.kSigma);
state.thermal = wThermal;
state.dga = wDGA;
state.equipmentWarning = wThermal | wDGA;
state.anyWarning = state.moisture | state.dielectric | state.equipmentWarning;
state.activeWarnings = double(state.moisture) + double(state.dielectric) + ...
    double(wThermal) + double(wDGA);

%% Дані для підсумкових графіків
state.relativeSaturationPct = rs;
state.rsBand = rsBand;
state.rsGoodUpperPct = goodMax;
state.rsFairUpperPct = fairMax;
state.tanDeltaRef = tanRef;
state.deltaTanDeltaRef = deltaTan;
state.kSigma = kSigma;
state.dielectricKLimit = cfg.limits.kSigma;
state.dataAvailable = validRS & validDielectric;
end
