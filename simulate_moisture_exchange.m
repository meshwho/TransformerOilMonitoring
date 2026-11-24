function waterPPM = simulate_moisture_exchange(t,thermal,cfg,moistureFault)
% Використовується лише для генерації синтетичних вимірювань.

p = cfg.moisture;

Tpaper = thermal.topOilC + p.paperTemperatureFactor.* ...
    (thermal.hotSpotC-thermal.topOilC);

oilWaterKg = p.oilMassKg*p.initialOilPPM*1e-6;
paperWaterKg = p.paperMassKg*p.initialPaperWaterPct/100;
initialPaperWaterKg = paperWaterKg;

paperActivityRef = p.initialOilPPM/ ...
    water_solubility(Tpaper(1),cfg);

waterPPM = zeros(size(t));
waterPPM(1) = p.initialOilPPM;

for k = 2:numel(t)

    dt = t(k)-t(k-1);
    TpaperNow = (Tpaper(k-1)+Tpaper(k))/2;

    paperActivity = paperActivityRef* ...
        (paperWaterKg/initialPaperWaterKg)^p.paperSorptionExponent;

    equilibriumPPM = paperActivity*water_solubility(TpaperNow,cfg);
    currentPPM = oilWaterKg/p.oilMassKg*1e6;

    % Різні сталі часу при віддачі та поглинанні води.
    if equilibriumPPM > currentPPM
        tauH = p.desorptionTauH;
    else
        tauH = p.absorptionTauH;
    end

    exchangeKg = (equilibriumPPM-currentPPM)* ...
        p.oilMassKg*1e-6*(1-exp(-dt/tauH));

    % Перенесення не може перевищувати запас води в джерелі.
    exchangeKg = max(-oilWaterKg,min(paperWaterKg,exchangeKg));
    oilWaterKg = oilWaterKg+exchangeKg;
    paperWaterKg = paperWaterKg-exchangeKg;

    if moistureFault
        ingressH = max(0,t(k)-max(t(k-1),p.ingressStartH));
        oilWaterKg = oilWaterKg + p.ingressGperH*1e-3*ingressH;
    end

    waterPPM(k) = oilWaterKg/p.oilMassKg*1e6;
end

end
