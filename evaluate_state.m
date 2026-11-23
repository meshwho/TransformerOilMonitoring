function state = evaluate_state(thermal,moisture,dga,oil,cfg)
% КОМПЛЕКСНА ОЦІНКА СТАНУ МАСЛА ЗА ОНЛАЙН-ВИМІРЮВАННЯМИ
% Формули 3.24-3.28. Лабораторні дані до R_oil не входять.
% Значення R_oil показує перевищення умовних меж, а НЕ % старіння.

water = moisture.waterPPM(:);
saturation = moisture.relativeSaturationPct(:);
tanRef = oil.tanDeltaRef(:);
kSigma = oil.conditionIndex(:);

N = numel(water);
if N < 2 || any([numel(saturation),numel(tanRef),numel(kSigma), ...
        numel(thermal.warning),numel(dga.warning)] ~= N)
    error('Діагностичні показники мають різну довжину.');
end

%% Перевірка демонстраційних меж
lim = cfg.limits;
thresholds = [lim.waterPPM,lim.relativeSaturationPct, ...
    lim.tanDeltaRef,lim.kSigma];
if any(~isfinite(thresholds)) || any(thresholds <= 0)
    error('Усі діагностичні межі мають бути додатними.');
end

%% Нормовані показники вологісного та електричного стану
% R > 1 означає перевищення хоча б однієї встановленої межі.
Rm = max(water/lim.waterPPM, ...
    saturation/lim.relativeSaturationPct);
Re = max(tanRef/lim.tanDeltaRef, ...
    kSigma/lim.kSigma);

%% Комплексний онлайн-показник стану масла (3.26)
% Пропущені чи некоректні вимірювання не трактуємо як норму.
valid = isfinite(water) & water >= 0 & ...
    isfinite(saturation) & saturation >= 0 & ...
    isfinite(tanRef) & tanRef >= 0 & ...
    isfinite(kSigma) & kSigma > 0;
Rm(~valid) = nan;
Re(~valid) = nan;
Roil = max(Rm,Re);

state.moistureRatio = Rm;
state.dielectricRatio = Re;
state.oilRatio = Roil;
state.oilDataAvailable = valid;
state.oilStatus = -ones(N,1);   % -1: недостатньо даних
state.oilStatus(valid & Roil < 1) = 0;    % 0: межі не перевищені
state.oilStatus(valid & Roil >= 1) = 1;   % 1: є перевищення

%% Окремі діагностичні канали
state.moisture = valid & Rm >= 1;
state.dielectric = valid & Re >= 1;
state.thermal = logical(thermal.warning(:));
state.dga = logical(dga.warning(:));

% Температура та DGA свідчать про можливі процеси в обладнанні,
% але НЕ про автоматичну необхідність заміни масла.
state.oilWarning = state.oilStatus == 1;
state.equipmentWarning = state.thermal | state.dga;
state.anyWarning = state.oilWarning | state.equipmentWarning;

%% Кількість одночасних онлайн-попереджень
state.activeWarnings = double(state.moisture) + ...
    double(state.dielectric) + ...
    double(state.thermal) + double(state.dga);

end
