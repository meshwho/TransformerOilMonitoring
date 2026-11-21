
function fig = plot_moisture(data, moisture, cfg)
% ПОБУДОВА ГРАФІКІВ ВОЛОГОВМІСТУ

t = data.tH;

fig = figure('Name','Вологовміст масла','Color','w');

%% Концентрація води

subplot(2,1,1);

plot(t,moisture.waterPPM,'LineWidth',1.7);
hold on;

limit = cfg.limits.waterPPM;
plot(t,limit*ones(size(t)),'--');

grid on;

xlabel('Час, год');
ylabel('Вміст води, мг/кг');
title('Зміна вмісту води в трансформаторному маслі');

legend('Вміст води', ...
       'Умовна межа', ...
       'Location','best');

%% Відносне насичення масла водою

subplot(2,1,2);

plot(t,moisture.relativeSaturationPct, ...
    'LineWidth',1.7);
hold on;

limit = cfg.limits.relativeSaturationPct;
plot(t,limit*ones(size(t)),'--');

grid on;

xlabel('Час, год');
ylabel('Відносне насичення, %');
title('Відносне насичення масла водою');

legend('Відносне насичення', ...
       'Умовна межа', ...
       'Location','best');

end
