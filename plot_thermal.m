function fig = plot_thermal(data,thermal,cfg)
% ГРАФІКИ НЕЛІНІЙНОЇ ТЕПЛОВОЇ МОДЕЛІ

t = data.tH;
fig = figure('Name','Нелінійна теплова модель','Color','w');

%% Температури
subplot(3,1,1);
plot(t,thermal.topOilC,'LineWidth',1.8);
hold on;
plot(t,data.oilTempSensorC,'LineWidth',1.2);
plot(t,thermal.hotSpotC,'LineWidth',1.6);
grid on;
xlabel('Час, год');
ylabel('Температура, °C');
title('Температурний режим трансформатора');
mark_fault_start(gca,data.faultStartH.cooling,'Охол.',[0.58 0.28 0.73]);
legend('Розрахункова температура масла', ...
       'Виміряна температура масла', ...
       'Розрахункова гаряча точка', ...
       'Location','best');

%% Відхилення температури
subplot(3,1,2);
plot(t,thermal.residualC,'LineWidth',1.6);
hold on;
limit = cfg.limits.thermalResidualC;
plot(t,limit*ones(size(t)),'--');
plot(t,-limit*ones(size(t)),'--');
grid on;
xlabel('Час, год');
ylabel('Відхилення, °C');
title('Виміряна температура мінус розрахункова');
mark_fault_start(gca,data.faultStartH.cooling,'',[0.58 0.28 0.73]);
legend('Відхилення температури', ...
       'Верхня умовна межа', ...
       'Нижня умовна межа', ...
       'Location','best');

%% В'язкість
subplot(3,1,3);
plot(t,thermal.viscosityRelative,'LineWidth',1.6);
hold on;
plot(t,thermal.measuredViscosityRelative,'LineWidth',1.2);
grid on;
xlabel('Час, год');
ylabel('Відносна в’язкість');
title('Зміна в’язкості масла');
mark_fault_start(gca,data.faultStartH.cooling,'',[0.58 0.28 0.73]);
legend('За розрахунковою температурою', ...
       'За показанням датчика', ...
       'Location','best');

%% Межі осі часу: від першого до останнього вимірювання
format_time_axes(fig,t,7);

end
