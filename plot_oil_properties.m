
function fig = plot_oil_properties(data, oil, state)
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
mark_first_warning(gca,t,state.thermal,'Перше теплове попередження');

%% 2. В'язкість

subplot(4,2,2);

plot(t,oil.viscosityRelative,'LineWidth',1.6);

grid on;
xlabel('Час, год');
ylabel('Відносна в’язкість');
title('В’язкість масла');
mark_first_warning(gca,t,state.thermal,'');

%% 3. Густина

subplot(4,2,3);

plot(t,oil.density,'LineWidth',1.6);

grid on;
xlabel('Час, год');
ylabel('Густина, кг/м³');
title('Густина масла');
mark_first_warning(gca,t,state.thermal,'');

%% 4. Питома теплоємність

subplot(4,2,4);

plot(t,oil.heatCapacity,'LineWidth',1.6);

grid on;
xlabel('Час, год');
ylabel('Дж/(кг·К)');
title('Питома теплоємність');
mark_first_warning(gca,t,state.thermal,'');

%% 5. Теплопровідність

subplot(4,2,5);

plot(t,oil.conductivity,'LineWidth',1.6);

grid on;
xlabel('Час, год');
ylabel('Вт/(м·К)');
title('Теплопровідність');
mark_first_warning(gca,t,state.thermal,'');

%% 6. Коефіцієнт об'ємного розширення

subplot(4,2,6);

plot(t,oil.expansion,'LineWidth',1.6);

grid on;
xlabel('Час, год');
ylabel('Коефіцієнт, 1/К');
title('Об’ємне розширення');
mark_first_warning(gca,t,state.thermal,'');

%% 7. Питомий електричний опір

subplot(4,2,7);

semilogy(t,oil.resistivity,'LineWidth',1.6);

grid on;
xlabel('Час, год');
ylabel('Питомий опір, Ом·м');
title('Питомий електричний опір');
mark_first_warning(gca,t,state.dielectric,'');

%% 8. Тангенс діелектричних втрат

subplot(4,2,8);

plot(t,oil.tanDelta,'LineWidth',1.6);

grid on;
xlabel('Час, год');
ylabel('tg δ');
title('Тангенс діелектричних втрат');
mark_first_warning(gca,t,state.dielectric,'Перше діелектричне попередження');

%% Межі осі часу: від першого до останнього вимірювання
format_time_axes(fig,t,5);

end
