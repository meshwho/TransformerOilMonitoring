function fig = plot_moisture(data,moisture,cfg)
% ГРАФІКИ ВОЛОГОВМІСТУ ТА ЙОГО ДОБОВОЇ ДИНАМІКИ

t = data.tH;
fig = figure('Name','Вологовміст масла','Color','w');

%% Поточний та середній вологовміст

subplot(3,1,1);
plot(t,moisture.waterPPM,'LineWidth',1.5);
hold on;
plot(t,moisture.average24PPM,'LineWidth',1.8);
plot(t,cfg.limits.waterPPM*ones(size(t)),'--');
grid on;

xlabel('Час, год');
ylabel('Вміст води, мг/кг');
title('Вологовміст трансформаторного масла');
legend('Поточне значення', ...
       'Середнє за 24 години', ...
       'Умовна діагностична межа', ...
       'Location','best');

%% Відносне насичення водою

subplot(3,1,2);
plot(t,moisture.relativeSaturationPct,'LineWidth',1.7);
hold on;
plot(t,cfg.limits.relativeSaturationPct*ones(size(t)),'--');
grid on;

xlabel('Час, год');
ylabel('Насичення, %');
title('Відносне насичення масла водою');
legend('Відносне насичення', ...
       'Умовна діагностична межа', ...
       'Location','best');

%% Добова зміна між двома 24-годинними середніми

subplot(3,1,3);
plot(t,moisture.dailyChangePPMperDay,'LineWidth',1.7);
hold on;
plot(t,zeros(size(t)),'--');
grid on;

xlabel('Час, год');
ylabel('Зміна, мг/кг за добу');
title('Добова зміна середнього вологовмісту');
legend('Добова зміна', ...
       'Нульова зміна', ...
       'Location','best');

%% Ось часу завершується останнім вимірюванням

format_time_axes(fig,t,7);

end
