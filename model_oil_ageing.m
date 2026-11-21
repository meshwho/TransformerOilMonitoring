
function out = model_oil_ageing(data)
% МАТЕМАТИЧНА МОДЕЛЬ АНАЛІЗУ СТАРІННЯ МАСЛА
%
% Розрахунок швидкості зміни характеристик
% між двома останніми лабораторними дослідженнями.

lab = data.lab;

%% Час між останніми вимірюваннями

N = length(lab.month);

deltaT = lab.month(N) - lab.month(N-1);

%% Швидкість зміни кислотного числа

acidRate = ...
    (lab.acid(N) - lab.acid(N-1)) / deltaT;

%% Швидкість зміни пробивної напруги

breakdownRate = ...
    (lab.breakdownKV(N) - lab.breakdownKV(N-1)) / deltaT;

%% Швидкість зміни діелектричних втрат

tanDeltaRate = ...
    (lab.tanDelta(N) - lab.tanDelta(N-1)) / deltaT;

%% Швидкість зміни міжфазного натягу

iftRate = ...
    (lab.ift(N) - lab.ift(N-1)) / deltaT;

%% Результати

out.acidRate = acidRate;
out.breakdownRate = breakdownRate;
out.tanDeltaRate = tanDeltaRate;
out.iftRate = iftRate;

end
