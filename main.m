
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


%% Оцінка якості та старіння масла

quality = model_oil_quality(data,cfg);

ageing = model_oil_ageing(data);


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

%% Результати оцінювання якості масла

fprintf('\nЯКІСТЬ ТРАНСФОРМАТОРНОГО МАСЛА\n');
fprintf('----------------------------------------\n');

fprintf('Кислотне число: %.3f мг КОН/г\n', ...
    quality.acid);

fprintf('Пробивна напруга: %.2f кВ\n', ...
    quality.breakdownKV);

fprintf('Тангенс діелектричних втрат: %.4f\n', ...
    quality.tanDelta);

fprintf('Міжфазний натяг: %.2f мН/м\n', ...
    quality.ift);

%% Результати аналізу старіння

fprintf('\nЗМІНА ХАРАКТЕРИСТИК МАСЛА\n');
fprintf('----------------------------------------\n');

fprintf('Зміна кислотного числа: %.4f мг КОН/(г·міс)\n', ...
    ageing.acidRate);

fprintf('Зміна пробивної напруги: %.3f кВ/міс\n', ...
    ageing.breakdownRate);

fprintf('Зміна tg delta: %.5f за місяць\n', ...
    ageing.tanDeltaRate);

fprintf('Зміна міжфазного натягу: %.3f мН/(м·міс)\n', ...
    ageing.iftRate);

if quality.warning
    fprintf('\nЯКІСТЬ МАСЛА: ПОТРЕБУЄ ПЕРЕВІРКИ\n');
else
    fprintf('\nЯКІСТЬ МАСЛА: ВІДХИЛЕНЬ НЕ ВИЯВЛЕНО\n');
end

fprintf('Оцінка виконана за останніми ');
fprintf('умовними лабораторними даними.\n');



%% 6. Діагностичні попередження за онлайн-даними

fprintf('\nРЕЗУЛЬТАТИ ОНЛАЙН-ДІАГНОСТИКИ\n');
fprintf('----------------------------------------\n');

names = {'Тепловий стан', ...
         'Вологовміст', ...
         'Газовий аналіз', ...
         'Діелектричні властивості'};

flags = [state.thermal, state.moisture, ...
         state.dga, state.dielectric];

for j = 1:numel(names)
    firstWarning = find(flags(:,j),1,'first');

    if isempty(firstWarning)
        fprintf('%s: перевищень умовних меж не виявлено\n',names{j});
    else
        fprintf('%s: попередження з %.2f год\n', ...
            names{j},data.tH(firstWarning));
    end
end

%% 7. Комплексний показник стану масла (підрозділ 3.6)

fprintf('\nКОМПЛЕКСНА ОЦІНКА СТАНУ МАСЛА\n');
fprintf('----------------------------------------\n');

if ~state.oilDataAvailable(end)
    fprintf('Стан масла: НЕДОСТАТНЬО ОНЛАЙН-ДАНИХ\n');
    fprintf('Потрібно перевірити показання датчиків.\n');
else
    fprintf('Вологісний показник R_M: %.3f\n', ...
        state.moistureRatio(end));
    fprintf('Діелектричний показник R_E: %.3f\n', ...
        state.dielectricRatio(end));
    fprintf('Комплексний показник R_oil: %.3f\n', ...
        state.oilRatio(end));

    if ~state.oilWarning(end)
        fprintf('Стан масла: умовні межі не перевищені.\n');
        fprintf('Рекомендація: продовжити онлайн-моніторинг.\n');
    elseif state.moisture(end) && state.dielectric(end)
        fprintf('Стан масла: відхилення вологісного та електричного стану.\n');
        fprintf('Рекомендація: перевірити герметичність, дослідити масло\n');
        fprintf('та визначити необхідність осушування або регенерації.\n');
    elseif state.moisture(end)
        fprintf('Стан масла: перевищення показників вологовмісту.\n');
        fprintf('Рекомендація: перевірити герметичність і необхідність осушування.\n');
    else
        fprintf('Стан масла: зміна діелектричних властивостей.\n');
        fprintf('Рекомендація: перевірити причину та провести випробування масла.\n');
    end
end

if state.equipmentWarning(end)
    fprintf('Окремо: виявлено ознаки відхилень у роботі трансформатора.\n');
    if state.thermal(end)
        fprintf('Рекомендація: перевірити тепловий режим і охолодження.\n');
    end
    if state.dga(end)
        fprintf('Рекомендація: перевірити причини газоутворення (DGA).\n');
    end
end

fprintf('\nЗАГАЛЬНИЙ РЕЗУЛЬТАТ\n');
fprintf('----------------------------------------\n');
if ~state.oilDataAvailable(end)
    fprintf('Онлайн-оцінка масла: недостатньо даних.\n');
elseif state.oilWarning(end)
    fprintf('Онлайн-оцінка масла: ВИЯВЛЕНО ВІДХИЛЕННЯ.\n');
else
    fprintf('Онлайн-оцінка масла: ПЕРЕВИЩЕНЬ НЕ ВИЯВЛЕНО.\n');
end

if state.equipmentWarning(end)
    fprintf('Діагностика обладнання: ВИЯВЛЕНО ПОПЕРЕДЖЕННЯ.\n');
else
    fprintf('Діагностика обладнання: попереджень немає.\n');
end

fprintf('Активних онлайн-попереджень: %d\n', ...
    state.activeWarnings(end));
fprintf('Лабораторні показники не входять у R_oil.\n');
fprintf('Значення R_oil не є відсотком старіння масла.\n');
fprintf('Перевищення меж не означає автоматичної заміни масла.\n');

fprintf('\nУВАГА: синтетичні дані та умовні діагностичні пороги.\n');
fprintf('Система не призначена для промислової діагностики.\n\n');

%% 8. Побудова графіків

f1 = plot_thermal(data,thermal,cfg);
f2 = plot_moisture(data,moisture,cfg);
f3 = plot_dga(data,dga,cfg);
f4 = plot_diagnostics(data,state);
f5 = plot_oil_quality(quality);
f6 = plot_oil_ageing(data);

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
    saveas(f4,'figures/04_diagnostics.png');
    saveas(f5,'figures/05_oil_quality.png');
    saveas(f6,'figures/06_oil_ageing.png');
    saveas(fProperties,'figures/07_oil_properties.png');
    saveas(fDielectric,'figures/08_dielectric_online.png');

end
