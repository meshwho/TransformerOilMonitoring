
function fig = plot_oil_properties(data, oil)
% ГРАФІКИ ТЕМПЕРАТУРНО-ЗАЛЕЖНИХ
% ВЛАСТИВОСТЕЙ ТРАНСФОРМАТОРНОГО МАСЛА

t = data.tH;

fig = figure( ...
    'Name','Властивості трансформаторного масла', ...
    'Color','w');

%% 1. Температура масла

subplot(4,2,1);

plot(t,data.oilTempSensorC,'LineWidth',1.6);

grid on;
xlabel('Час, год');
ylabel('Температура, °C');
title('Температура масла');

%% 2. В'язкість

subplot(4,2,2);

plot(t,oil.viscosityRelative,'LineWidth',1.6);

grid on;
xlabel('Час, год');
ylabel('Відносна в’язкість');
title('В’язкість масла');

%% 3. Густина

subplot(4,2,3);

plot(t,oil.density,'LineWidth',1.6);

grid on;
xlabel('Час, год');
ylabel('Густина, кг/м³');
title('Густина масла');

%% 4. Питома теплоємність

subplot(4,2,4);

plot(t,oil.heatCapacity,'LineWidth',1.6);

grid on;
xlabel('Час, год');
ylabel('Дж/(кг·К)');
title('Питома теплоємність');

%% 5. Теплопровідність

subplot(4,2,5);

plot(t,oil.conductivity,'LineWidth',1.6);

grid on;
xlabel('Час, год');
ylabel('Вт/(м·К)');
title('Теплопровідність');

%% 6. Коефіцієнт об'ємного розширення

subplot(4,2,6);

plot(t,oil.expansion,'LineWidth',1.6);

grid on;
xlabel('Час, год');
ylabel('Коефіцієнт, 1/К');
title('Об’ємне розширення');

%% 7. Питомий електричний опір

subplot(4,2,7);

semilogy(t,oil.resistivity,'LineWidth',1.6);

grid on;
xlabel('Час, год');
ylabel('Питомий опір, Ом·м');
title('Питомий електричний опір');

%% 8. Тангенс діелектричних втрат

subplot(4,2,8);

plot(t,oil.tanDelta,'LineWidth',1.6);

grid on;
xlabel('Час, год');
ylabel('tg δ');
title('Тангенс діелектричних втрат');

%% Межі осі часу: від першого до останнього вимірювання
format_time_axes(fig,t,5);

end
