function fig = plot_moisture(data,moisture,cfg)
% ГРАФІКИ ТЕМПЕРАТУРИ ТА ВОЛОГОВМІСТУ МАСЛА

t = data.tH;
fig = figure('Name','Вологовміст масла','Color','w', ...
    'Position',[100 80 900 780]);

%% Температура масла
subplot(4,1,1);
plot(t,data.oilTempSensorC,'LineWidth',1.6);
grid on;
xlabel('Час, год');
ylabel('Температура, °C');
title('Температура трансформаторного масла');
mark_first_warning(gca,t,moisture.warning,'');

%% Поточний та середній вологовміст
subplot(4,1,2);
plot(t,moisture.waterPPM,'LineWidth',1.5);
hold on;
plot(t,moisture.average24PPM,'LineWidth',1.8);
plot(t,cfg.limits.waterPPM*ones(size(t)),'--');
grid on;
xlabel('Час, год');
ylabel('Вода, мг/кг');
title('Зміна вологовмісту трансформаторного масла');
mark_first_warning(gca,t,moisture.warning,'Перше попередження вологості');
legend('Поточний вологовміст', ...
       'Середнє за 24 години', ...
       'Умовна межа', ...
       'Location','best');

%% Відносне насичення водою
subplot(4,1,3);
plot(t,moisture.relativeSaturationPct,'LineWidth',1.7);
hold on;
plot(t,cfg.limits.relativeSaturationPct*ones(size(t)),'--');
grid on;
xlabel('Час, год');
ylabel('Насичення, %');
title('Відносне насичення масла водою');
mark_first_warning(gca,t,moisture.warning,'');
legend('Відносне насичення', ...
       'Умовна межа', ...
       'Location','best');

%% Добова зміна
subplot(4,1,4);
plot(t,moisture.dailyChangePPMperDay,'LineWidth',1.7);
hold on;
plot(t,zeros(size(t)),'--');
grid on;
xlabel('Час, год');
ylabel('Зміна, мг/кг/добу');
title('Зміна середнього вологовмісту за добу');
mark_first_warning(gca,t,moisture.warning,'');
legend('Добова зміна', ...
       'Нульова зміна', ...
       'Location','best');

format_time_axes(fig,t,7);

end
