
function out = model_oil_quality(data, cfg)
% МАТЕМАТИЧНА МОДЕЛЬ ОЦІНЮВАННЯ ЯКОСТІ МАСЛА
%
% Оцінка за останніми лабораторними вимірюваннями.
% Пороги є умовними та не мають нормативного статусу.

lab = data.lab;
limits = cfg.oilQuality;

%% Останні лабораторні показники

acid = lab.acid(end);
breakdown = lab.breakdownKV(end);
tanDelta = lab.tanDelta(end);
ift = lab.ift(end);

%% Перевірка характеристик

highAcid = acid > limits.acidMax;

lowBreakdown = breakdown < limits.breakdownMin;

highTanDelta = tanDelta > limits.tanDeltaMax;

lowIFT = ift < limits.iftMin;

%% Відношення показників до граничних значень
% Значення більше 1 означає порушення умовної межі.

ratio = [
    acid / limits.acidMax
    limits.breakdownMin / breakdown
    tanDelta / limits.tanDeltaMax
    limits.iftMin / ift
];

%% Загальне попередження про якість масла

warning = highAcid | lowBreakdown ...
    | highTanDelta | lowIFT;

%% Результати

out.acid = acid;
out.breakdownKV = breakdown;
out.tanDelta = tanDelta;
out.ift = ift;

out.highAcid = highAcid;
out.lowBreakdown = lowBreakdown;
out.highTanDelta = highTanDelta;
out.lowIFT = lowIFT;

out.ratio = ratio;
out.warning = warning;

end
