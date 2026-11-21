
function out = model_dga(data, cfg)
% МАТЕМАТИЧНА МОДЕЛЬ ГАЗОВОГО АНАЛІЗУ
%
% Розрахунок сумарної концентрації горючих газів,
% швидкості накопичення водню та співвідношень газів.

t = data.tH;
N = length(t);

%% Сумарна концентрація горючих газів

TDCG = data.h2PPM ...
     + data.ch4PPM ...
     + data.c2h6PPM ...
     + data.c2h4PPM ...
     + data.c2h2PPM ...
     + data.coPPM;

%% Згладжування концентрації водню

h2Smooth = movmean( ...
    data.h2PPM, cfg.dga.smoothSamples);

%% Швидкість накопичення водню

% Кількість кроків у заданому інтервалі
lag = max(1,round( ...
    cfg.dga.rateWindowH/cfg.dtH));

h2Rate = nan(N,1);

for k = lag+1:N

    deltaH2 = h2Smooth(k) - h2Smooth(k-lag);
    deltaT = t(k) - t(k-lag);

    h2Rate(k) = deltaH2/deltaT;

end

%% Діагностичні перевірки

highH2Rate = h2Rate > ...
    cfg.limits.h2RatePPMperH;

highAcetylene = data.c2h2PPM > ...
    cfg.limits.c2h2PPM;

warning = highH2Rate | highAcetylene;

%% Співвідношення концентрацій газів

ratioCH4H2 = data.ch4PPM ./ ...
    max(data.h2PPM,eps);

ratioC2H2C2H4 = data.c2h2PPM ./ ...
    max(data.c2h4PPM,eps);

%% Результати

out.TDCG = TDCG;
out.h2RatePPMperH = h2Rate;

out.ratioCH4H2 = ratioCH4H2;
out.ratioC2H2C2H4 = ratioC2H2C2H4;

out.highH2Rate = highH2Rate;
out.highAcetylene = highAcetylene;
out.warning = warning;

end
