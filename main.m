
%% СИСТЕМА ОНЛАЙН-МОНІТОРИНГУ ТРАНСФОРМАТОРНОГО МАСЛА

clear;
clc;
close all;

%% 1. Завантаження налаштувань

cfg = monitor_settings();

%% 2. Отримання даних вимірювань

data = generate_demo_data(cfg);

%% 3. Розрахунок математичних моделей

thermal = model_thermal(data,cfg);


%% Розрахунок властивостей трансформаторного масла

oil = model_oil_properties(data,cfg);

moisture = model_moisture(data,cfg);

dga = model_dga(data,cfg);


%% 4. Комплексна оцінка стану

state = evaluate_state(thermal,moisture,dga,oil,cfg);

%% 5. Виведення результатів у консоль

fprintf('\n========================================\n');
fprintf(' СИСТЕМА МОНІТОРИНГУ ТРАНСФОРМАТОРНОГО МАСЛА\n');
fprintf('========================================\n\n');

fprintf('Сценарій: %d\n',cfg.scenario);
fprintf('Тривалість моделювання: %.1f год\n',cfg.durationH);
fprintf('Крок розрахунку: %.2f год\n\n',cfg.dtH);

fprintf('ОСТАННІ ЗНАЧЕННЯ ПОКАЗНИКІВ\n');
fprintf('----------------------------------------\n');

fprintf('Температура масла: %.2f °C\n', ...
    data.oilTempSensorC(end));

fprintf('Розрахункова температура: %.2f °C\n', ...
    thermal.topOilC(end));

fprintf('Температура гарячої точки: %.2f °C\n', ...
    thermal.hotSpotC(end));

fprintf('Вміст води: %.2f мг/кг\n', ...
    moisture.waterPPM(end));

fprintf('Відносне насичення водою: %.2f %%\n', ...
    moisture.relativeSaturationPct(end));

fprintf('Активність води: %.4f\n', ...
    moisture.waterActivity(end));

fprintf('Розчинність води: %.2f мг/кг\n', ...
    moisture.saturationPPM(end));

if isfinite(moisture.average24PPM(end))
    fprintf('Середній вологовміст за 24 год: %.2f мг/кг\n', ...
        moisture.average24PPM(end));
else
    fprintf('Середній вологовміст: ще немає 24 год даних\n');
end

if isfinite(moisture.dailyChangePPMperDay(end))
    fprintf('Добова зміна вологовмісту: %+.2f мг/кг за добу\n', ...
        moisture.dailyChangePPMperDay(end));
else
    fprintf('Добова зміна: ще немає 48 год даних\n');
end

fprintf('\nГАЗОВИЙ АНАЛІЗ (DGA)\n');
fprintf('----------------------------------------\n');
fprintf('Концентрація водню: %.2f ppm\n', ...
    data.h2PPM(end));
fprintf('TDCG: %.2f ppm\n',dga.TDCG(end));

if isfinite(dga.averageTDCGPPM(end))
    fprintf('Середнє TDCG за 24 год: %.2f ppm\n', ...
        dga.averageTDCGPPM(end));
end

if isfinite(dga.dailyChangeTDCGPPM(end))
    fprintf('Добова зміна TDCG: %+.2f ppm\n', ...
        dga.dailyChangeTDCGPPM(end));
    fprintf('Швидкість зміни H2: %+.2f ppm/год\n', ...
        dga.h2RatePPMperH(end));
else
    fprintf('Добова зміна: ще немає 48 год даних\n');
end

fprintf('Відношення CH4/H2: ');
if isfinite(dga.ratioCH4H2(end))
    fprintf('%.3f\n',dga.ratioCH4H2(end));
else
    fprintf('недостатньо достовірних даних\n');
end

fprintf('Відношення C2H2/C2H4: ');
if isfinite(dga.ratioC2H2C2H4(end))
    fprintf('%.3f\n',dga.ratioC2H2C2H4(end));
else
    fprintf('недостатньо достовірних даних\n');
end

fprintf('Відношення C2H4/C2H6: ');
if isfinite(dga.ratioC2H4C2H6(end))
    fprintf('%.3f\n',dga.ratioC2H4C2H6(end));
else
    fprintf('недостатньо достовірних даних\n');
end

fprintf('Попередження DGA: %d\n\n',dga.warning(end));


%% Температурно-залежні властивості масла

fprintf('\nВЛАСТИВОСТІ ТРАНСФОРМАТОРНОГО МАСЛА\n');
fprintf('----------------------------------------\n');

fprintf('Температура масла: %.2f °C\n', ...
    oil.temperatureC(end));

fprintf('Відносна в’язкість: %.3f\n', ...
    oil.viscosityRelative(end));

fprintf('Густина: %.2f кг/м³\n', ...
    oil.density(end));

fprintf('Питома теплоємність: %.2f Дж/(кг·К)\n', ...
    oil.heatCapacity(end));

fprintf('Теплопровідність: %.4f Вт/(м·К)\n', ...
    oil.conductivity(end));

fprintf('Коефіцієнт об’ємного розширення: %.6f 1/К\n', ...
    oil.expansion(end));

fprintf('Питомий електричний опір: %.3e Ом·м\n', ...
    oil.resistivity(end));

fprintf('Тангенс діелектричних втрат: %.5f\n', ...
    oil.tanDelta(end));

fprintf('Діелектрична проникність: %.4f\n', ...
    oil.permittivityRelative(end));

fprintf('Електропровідність: %.3f пСм/м\n', ...
    oil.conductivitySperM(end)*1e12);

fprintf('Електропровідність при %.0f °C: %.3f пСм/м\n', ...
    oil.referenceTempC,oil.conductivityRefSperM(end)*1e12);

fprintf('Відносна зміна K_sigma: %.3f\n', ...
    oil.conditionIndex(end));

fprintf('\nЗМІНА ПОКАЗНИКІВ ЗА 72 ГОДИНИ\n');
fprintf('----------------------------------------\n');

fprintf('Температура: %.2f ... %.2f °C\n', ...
    min(oil.temperatureC),max(oil.temperatureC));

fprintf('Питомий опір: %.3e ... %.3e Ом·м\n', ...
    min(oil.resistivity),max(oil.resistivity));

fprintf('Тангенс втрат: %.5f ... %.5f\n', ...
    min(oil.tanDelta),max(oil.tanDelta));

fprintf('\nЕлектричні характеристики розраховано ');
fprintf('за синтетичними показаннями електричного датчика.\n');

%% 6. Комплексна діагностика за підрозділом 3.6

fprintf('\nКОМПЛЕКСНИЙ ОНЛАЙН-МОНІТОРИНГ\n');
fprintf('----------------------------------------\n');

fprintf('Відносне насичення водою: %.2f %%\n', ...
    state.relativeSaturationPct(end));
if state.rsBand(end) == 1
    fprintf('Поточний діапазон RS: <10 %% (Good)\n');
elseif state.rsBand(end) == 2
    fprintf('Поточний діапазон RS: 10-20 %% (Fair)\n');
elseif state.rsBand(end) == 3
    fprintf('Поточний діапазон RS: >20 %% (Poor)\n');
else
    fprintf('Поточний діапазон RS: недостатньо даних\n');
end
fprintf('Це лише орієнтир IEC 60422; 72 год замало для\n');
fprintf('остаточної оцінки (потрібен щонайменше один місяць).\n');

fprintf('Зміна скоригованого tg delta: %+.6f\n', ...
    state.deltaTanDeltaRef(end));
fprintf('Коефіцієнт K_sigma: %.3f\n',state.kSigma(end));

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

%% 8. Побудова графіків

f1 = plot_thermal(data,thermal,cfg);
f2 = plot_moisture(data,moisture,cfg);
f3 = plot_dga(data,dga,cfg);
f4 = plot_diagnostics(data,state);
% Лабораторні графіки не входять до онлайн-моніторингу.

%% Графіки властивостей масла

fProperties = plot_oil_properties(data,oil);

%% Окремі графіки онлайн-моніторингу діелектричних властивостей
fDielectric = plot_dielectric_online(data,oil);

%% 9. Збереження графіків

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
