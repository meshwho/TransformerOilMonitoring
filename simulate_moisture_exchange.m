function waterPPM = simulate_moisture_exchange(t,thermal,cfg,moistureFault)
% НАБЛИЖЕНА МОДЕЛЬ ОБМІНУ ВОДОЮ МІЖ МАСЛОМ І ПАПЕРОМ
% Використовується лише для генерації синтетичних вимірювань.
%
% При справному баку загальна маса води зберігається.
% При пошкодженні додається задане надходження води ззовні.
% Тепло прискорює перехід води з паперу в масло;
% повернення до паперу відбувається повільніше.
%
% Це модель із зосередженими параметрами, а не розв'язок
% дифузії в реальній геометрії трансформатора.

p = cfg.moisture;

%% Температура прилеглої до обмоток ізоляції
% Вона вища за температуру верхніх шарів масла, але нижча
% за температуру найгарячішої точки обмотки.
Tpaper = thermal.topOilC + p.paperTemperatureFactor.* ...
    (thermal.hotSpotC-thermal.topOilC);

%% Початкові маси води в маслі та паперовій ізоляції
oilWaterKg = p.oilMassKg*p.initialOilPPM*1e-6;
paperWaterKg = p.paperMassKg*p.initialPaperWaterPct/100;
initialPaperWaterKg = paperWaterKg;

% Початковий рівноважний стан за обраною температурою.
paperActivityRef = p.initialOilPPM/ ...
    water_solubility(Tpaper(1),cfg);

waterPPM = zeros(size(t));
waterPPM(1) = p.initialOilPPM;

%% Розрахунок обміну на кожному часовому кроці
for k = 2:numel(t)

    dt = t(k)-t(k-1);
    TpaperNow = (Tpaper(k-1)+Tpaper(k))/2;

    % Наближена ізотерма целюлози з урахуванням її вологовмісту.
    paperActivity = paperActivityRef* ...
        (paperWaterKg/initialPaperWaterKg)^p.paperSorptionExponent;

    % Концентрація, до якої прямує масло за наявної температури.
    equilibriumPPM = paperActivity*water_solubility(TpaperNow,cfg);
    currentPPM = oilWaterKg/p.oilMassKg*1e6;

    % Різні сталі часу при віддачі та поглинанні води.
    if equilibriumPPM > currentPPM
        tauH = p.desorptionTauH;
    else
        tauH = p.absorptionTauH;
    end

    % Перенесена маса води із закону першого порядку.
    exchangeKg = (equilibriumPPM-currentPPM)* ...
        p.oilMassKg*1e-6*(1-exp(-dt/tauH));

    % Перенесення не може перевищувати запас води в джерелі.
    exchangeKg = max(-oilWaterKg,min(paperWaterKg,exchangeKg));
    oilWaterKg = oilWaterKg+exchangeKg;
    paperWaterKg = paperWaterKg-exchangeKg;

    %% Порушення герметичності: зовнішнє надходження води
    if moistureFault
        ingressH = max(0,t(k)-max(t(k-1),p.ingressStartH));
        oilWaterKg = oilWaterKg + p.ingressGperH*1e-3*ingressH;
    end

    waterPPM(k) = oilWaterKg/p.oilMassKg*1e6;
end

end
