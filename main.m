clear;
clc;
close all;

cfg = monitor_settings();

data = generate_demo_data(cfg);

thermal = model_thermal(data,cfg);

oil = model_oil_properties(data,cfg);

moisture = model_moisture(data,cfg);

dga = model_dga(data,cfg);

state = evaluate_state(thermal,moisture,dga,oil,cfg);

fprintf('Сценарій %d | %.1f год | крок %.2f год\n', ...
    cfg.scenario,cfg.durationH,cfg.dtH);
fprintf('\nОстанні значення:\n');
fprintf('Температура масла: %.2f °C (розрахункова %.2f °C)\n', ...
    data.oilTempSensorC(end),thermal.topOilC(end));
fprintf('Температура гарячої точки: %.2f °C\n',thermal.hotSpotC(end));
fprintf('Вологовміст: %.2f мг/кг; середнє за 24 год: %.2f мг/кг\n', ...
    moisture.waterPPM(end),moisture.average24PPM(end));
fprintf('Добова зміна вологовмісту: %+.2f мг/кг\n',moisture.dailyChangePPMperDay(end));
fprintf('Активність води: %.4f; розчинність: %.2f мг/кг\n', ...
    moisture.waterActivity(end),moisture.saturationPPM(end));
bands = {'недостатньо даних','Good (<10%)','Fair (10–20%)','Poor (>20%)'};
fprintf('RS: %.2f %% (%s)\n',state.relativeSaturationPct(end),bands{state.rsBand(end)+1});
fprintf('Для оцінювання RS за IEC 60422 потрібен щонайменше один місяць.\n');

fprintf('\nГазовий аналіз:\n');
fprintf('H2: %.2f ppm; TDCG: %.2f ppm\n',data.h2PPM(end),dga.TDCG(end));
fprintf('Середнє TDCG за 24 год: %.2f ppm; добова зміна: %+.2f ppm\n', ...
    dga.averageTDCGPPM(end),dga.dailyChangeTDCGPPM(end));
fprintf('Швидкість зміни H2: %+.2f ppm/год\n',dga.h2RatePPMperH(end));
fprintf('CH4/H2: %.3f; C2H2/C2H4: %.3f; C2H4/C2H6: %.3f\n', ...
    dga.ratioCH4H2(end),dga.ratioC2H2C2H4(end),dga.ratioC2H4C2H6(end));

fprintf('\nВластивості масла:\n');
fprintf('Відносна в’язкість: %.3f\n',oil.viscosityRelative(end));
fprintf('Густина: %.2f кг/м³\n',oil.density(end));
fprintf('Теплоємність: %.2f Дж/(кг·К)\n',oil.heatCapacity(end));
fprintf('Теплопровідність: %.4f Вт/(м·К)\n',oil.conductivity(end));
fprintf('Об’ємне розширення: %.6f 1/К\n',oil.expansion(end));
fprintf('Питомий опір: %.3e Ом·м\n',oil.resistivity(end));
fprintf('Діелектрична проникність: %.4f\n',oil.permittivityRelative(end));
fprintf('tg delta: %.5f; приведене значення: %.5f\n',oil.tanDelta(end),oil.tanDeltaRef(end));
fprintf('Електропровідність: %.3f пСм/м (при %.0f °C: %.3f пСм/м)\n', ...
    oil.conductivitySperM(end)*1e12,oil.referenceTempC,oil.conductivityRefSperM(end)*1e12);
fprintf('Зміна приведеного tg delta: %+.6f; K_sigma: %.3f\n', ...
    state.deltaTanDeltaRef(end),state.kSigma(end));
fprintf('NaN — недостатньо даних для розрахунку.\n');

fprintf('\nПопередження:\n');
names = {'Вологовміст','Діелектричні властивості', ...
         'Тепловий стан','Газовий аналіз'};
flags = [state.moisture,state.dielectric,state.thermal,state.dga];

for j = 1:numel(names)
    firstWarning = find(flags(:,j),1,'first');
    if isempty(firstWarning)
        fprintf('%s: попередження немає\n',names{j});
    else
        fprintf('%s: перше попередження з %.2f год\n', ...
            names{j},data.tH(firstWarning));
    end
end

fprintf('\nДІАГНОСТИЧНИЙ ВИСНОВОК\n');
if ~state.dataAvailable(end)
    fprintf('Недостатньо достовірних онлайн-даних.\n');
elseif state.moisture(end) && state.dielectric(end)
    fprintf('Є відхилення вологісних та електричних характеристик.\n');
    fprintf('Потрібна перевірка впливу води й можливих забруднень.\n');
elseif state.moisture(end)
    fprintf('Є відхилення вологісних характеристик масла.\n');
    fprintf('Рекомендовано перевірити вологісний стан ізоляції.\n');
elseif state.dielectric(end)
    fprintf('Є відхилення діелектричних характеристик масла.\n');
    fprintf('Рекомендовано додаткові випробування масла.\n');
else
    fprintf('Демонстраційні межі масла не перевищені.\n');
end

if state.thermal(end)
    fprintf('Окремо потрібно перевірити охолодження трансформатора.\n');
end
if state.dga(end)
    fprintf('Окремо потрібно дослідити причини газоутворення.\n');
end
fprintf('Рішення про заміну масла автоматично не приймається.\n');
fprintf('Усі показання синтетичні, пороги тривог умовні.\n\n');

f1 = plot_thermal(data,thermal,cfg);
f2 = plot_moisture(data,moisture,cfg);
f3 = plot_dga(data,dga,cfg);
f4 = plot_diagnostics(data,state);

fProperties = plot_oil_properties(data,oil);
fDielectric = plot_dielectric_online(data,oil);

if cfg.savePlots

    if ~exist('figures','dir')
        mkdir('figures');
    end

    saveas(f1,'figures/01_thermal.png');
    saveas(f2,'figures/02_moisture.png');
    saveas(f3,'figures/03_dga.png');
    print(f4,'figures/04_diagnostics.png','-dpng','-r300');
    saveas(fProperties,'figures/07_oil_properties.png');
    saveas(fDielectric,'figures/08_dielectric_online.png');

end
