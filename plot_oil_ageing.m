
function fig = plot_oil_ageing(data,cfg)
% ПОБУДОВА ГРАФІКІВ ЗМІНИ ВЛАСТИВОСТЕЙ МАСЛА

lab = data.lab;
t = lab.month;

fig = figure( ...
    'Name','Старіння трансформаторного масла', ...
    'Color','w');

%% Кислотне число

subplot(2,2,1);

plot(t,lab.acid,'-o','LineWidth',1.5);

grid on;
xlabel('Час, міс');
ylabel('Кислотне число, мг КОН/г');
title('Зміна кислотного числа');
hold on;
yline(cfg.oilQuality.acidMax,'k--','HandleVisibility','off');
mark_first_warning(gca,t,lab.acid > cfg.oilQuality.acidMax,'Перше зафіксоване перевищення');

%% Пробивна напруга

subplot(2,2,2);

plot(t,lab.breakdownKV,'-o','LineWidth',1.5);

grid on;
xlabel('Час, міс');
ylabel('Напруга, кВ');
title('Зміна пробивної напруги');
hold on;
yline(cfg.oilQuality.breakdownMin,'k--','HandleVisibility','off');
mark_first_warning(gca,t,lab.breakdownKV < cfg.oilQuality.breakdownMin,'Перше зафіксоване перевищення');

%% Діелектричні втрати

subplot(2,2,3);

plot(t,lab.tanDelta,'-o','LineWidth',1.5);

grid on;
xlabel('Час, міс');
ylabel('tg δ');
title('Зміна діелектричних втрат');
hold on;
yline(cfg.oilQuality.tanDeltaMax,'k--','HandleVisibility','off');
mark_first_warning(gca,t,lab.tanDelta > cfg.oilQuality.tanDeltaMax,'Перше зафіксоване перевищення');

%% Міжфазний натяг

subplot(2,2,4);

plot(t,lab.ift,'-o','LineWidth',1.5);

grid on;
xlabel('Час, міс');
ylabel('Міжфазний натяг, мН/м');
title('Зміна міжфазного натягу');
hold on;
yline(cfg.oilQuality.iftMin,'k--','HandleVisibility','off');
mark_first_warning(gca,t,lab.ift < cfg.oilQuality.iftMin,'Перше зафіксоване перевищення');

%% Межі осі часу: від першого до останнього вимірювання
format_time_axes(fig,t,3);

end
