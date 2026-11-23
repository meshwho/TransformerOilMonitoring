
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
mark_fault_start(gca,data.faultStartH.cooling,'Охол.',[0.58 0.28 0.73]);

%% 2. В'язкість

subplot(4,2,2);

plot(t,oil.viscosityRelative,'LineWidth',1.6);

grid on;
xlabel('Час, год');
ylabel('Відносна в’язкість');
title('В’язкість масла');
mark_fault_start(gca,data.faultStartH.cooling,'',[0.58 0.28 0.73]);

%% 3. Густина

subplot(4,2,3);

plot(t,oil.density,'LineWidth',1.6);

grid on;
xlabel('Час, год');
ylabel('Густина, кг/м³');
title('Густина масла');
mark_fault_start(gca,data.faultStartH.cooling,'',[0.58 0.28 0.73]);

%% 4. Питома теплоємність

subplot(4,2,4);

plot(t,oil.heatCapacity,'LineWidth',1.6);

grid on;
xlabel('Час, год');
ylabel('Дж/(кг·К)');
title('Питома теплоємність');
mark_fault_start(gca,data.faultStartH.cooling,'',[0.58 0.28 0.73]);

%% 5. Теплопровідність

subplot(4,2,5);

plot(t,oil.conductivity,'LineWidth',1.6);

grid on;
xlabel('Час, год');
ylabel('Вт/(м·К)');
title('Теплопровідність');
mark_fault_start(gca,data.faultStartH.cooling,'',[0.58 0.28 0.73]);

%% 6. Коефіцієнт об'ємного розширення

subplot(4,2,6);

plot(t,oil.expansion,'LineWidth',1.6);

grid on;
xlabel('Час, год');
ylabel('Коефіцієнт, 1/К');
title('Об’ємне розширення');
mark_fault_start(gca,data.faultStartH.cooling,'',[0.58 0.28 0.73]);

%% 7. Питомий електричний опір

subplot(4,2,7);

semilogy(t,oil.resistivity,'LineWidth',1.6);

grid on;
xlabel('Час, год');
ylabel('Питомий опір, Ом·м');
title('Питомий електричний опір');
mark_fault_start(gca,data.faultStartH.dielectric,'Діел.',[0.82 0.22 0.24]);

%% 8. Тангенс діелектричних втрат

subplot(4,2,8);

plot(t,oil.tanDelta,'LineWidth',1.6);

grid on;
xlabel('Час, год');
ylabel('tg δ');
title('Тангенс діелектричних втрат');
mark_fault_start(gca,data.faultStartH.dielectric,'',[0.82 0.22 0.24]);

%% Межі осі часу: від першого до останнього вимірювання
format_time_axes(fig,t,5);

end
