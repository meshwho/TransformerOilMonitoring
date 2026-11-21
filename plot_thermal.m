
function fig = plot_thermal(data, thermal, cfg)
% ПОБУДОВА ГРАФІКІВ ТЕПЛОВОГО СТАНУ

t = data.tH;

fig = figure('Name','Тепловий стан','Color','w');

%% Температура масла та гарячої точки

subplot(2,1,1);

plot(t,thermal.topOilC,'LineWidth',1.8);
hold on;

plot(t,data.oilTempSensorC,'LineWidth',1.2);
plot(t,thermal.hotSpotC,'LineWidth',1.6);

grid on;

xlabel('Час, год');
ylabel('Температура, °C');
title('Температурний режим трансформатора');

legend('Розрахункова температура масла', ...
       'Виміряна температура масла', ...
       'Температура гарячої точки', ...
       'Location','best');

%% Відхилення температури від моделі

subplot(2,1,2);

plot(t,thermal.residualC,'LineWidth',1.6);
hold on;

limit = cfg.limits.thermalResidualC;

plot(t,limit*ones(size(t)),'--');
plot(t,-limit*ones(size(t)),'--');

grid on;

xlabel('Час, год');
ylabel('Відхилення, °C');
title('Відхилення виміряної температури від розрахункової');

legend('Відхилення температури', ...
       'Верхня умовна межа', ...
       'Нижня умовна межа', ...
       'Location','best');

end
