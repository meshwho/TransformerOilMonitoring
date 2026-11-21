
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

state = evaluate_state(thermal,moisture,dga,quality);

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

fprintf('Концентрація водню: %.2f ppm\n', ...
    data.h2PPM(end));

fprintf('Швидкість накопичення H2: %.2f ppm/год\n\n', ...
    dga.h2RatePPMperH(end));


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

fprintf('\nЗМІНА ПОКАЗНИКІВ ЗА 72 ГОДИНИ\n');
fprintf('----------------------------------------\n');

fprintf('Температура: %.2f ... %.2f °C\n', ...
    min(oil.temperatureC),max(oil.temperatureC));

fprintf('Питомий опір: %.3e ... %.3e Ом·м\n', ...
    min(oil.resistivity),max(oil.resistivity));

fprintf('Тангенс втрат: %.5f ... %.5f\n', ...
    min(oil.tanDelta),max(oil.tanDelta));

fprintf('\nЕлектричні характеристики розраховано ');
fprintf('за спрощеною температурною моделлю.\n');

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



%% 6. Діагностичні попередження

fprintf('РЕЗУЛЬТАТИ ДІАГНОСТИКИ\n');
fprintf('----------------------------------------\n');

% Назви математичних моделей
names = {'Тепловий стан', ...
         'Вологовміст', ...
         'Газовий аналіз'};

% Результати перевірок
flags = [state.thermal, ...
         state.moisture, ...
         state.dga];

% Визначення першого моменту появи попередження
for j = 1:3

    firstWarning = find(flags(:,j),1,'first');

    if isempty(firstWarning)

        fprintf('%s: відхилень не виявлено\n',names{j});

    else

        warningTime = data.tH(firstWarning);

        fprintf('%s: попередження з %.2f год\n', ...
            names{j},warningTime);

    end

end

%% 7. Загальний результат

fprintf('\n----------------------------------------\n');

if state.anyWarning(end)

    fprintf('Стан на кінець моделювання: ');
    fprintf('ВИЯВЛЕНО ВІДХИЛЕННЯ\n');

else

    fprintf('Стан на кінець моделювання: ');
    fprintf('ВІДХИЛЕНЬ НЕ ВИЯВЛЕНО\n');

end

fprintf('Активних попереджень: %d\n', ...
    state.activeWarnings(end));

fprintf('\nУВАГА: використано синтетичні дані ');
fprintf('та умовні діагностичні пороги.\n');

fprintf('Система не призначена для ');
fprintf('промислової діагностики.\n\n');

%% 8. Побудова графіків

f1 = plot_thermal(data,thermal,cfg);
f2 = plot_moisture(data,moisture,cfg);
f3 = plot_dga(data,dga,cfg);
f4 = plot_diagnostics(data,state);
f5 = plot_oil_quality(quality);
f6 = plot_oil_ageing(data);

%% Графіки властивостей масла

fProperties = plot_oil_properties(data,oil);

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

end
