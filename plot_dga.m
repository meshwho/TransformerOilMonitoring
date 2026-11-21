
function fig = plot_dga(data, dga, cfg)
% ПОБУДОВА ГРАФІКІВ АНАЛІЗУ РОЗЧИНЕНИХ ГАЗІВ

t = data.tH;

fig = figure('Name','Газовий аналіз','Color','w');

%% Концентрації водню та вуглеводневих газів

subplot(3,1,1);

plot(t,data.h2PPM,'LineWidth',1.5);
hold on;

plot(t,data.ch4PPM,'LineWidth',1.4);
plot(t,data.c2h6PPM,'LineWidth',1.4);
plot(t,data.c2h4PPM,'LineWidth',1.4);
plot(t,data.c2h2PPM,'LineWidth',1.4);

grid on;

xlabel('Час, год');
ylabel('Концентрація, ppm');
title('Концентрації розчинених газів');

legend('Водень (H₂)', ...
       'Метан (CH₄)', ...
       'Етан (C₂H₆)', ...
       'Етилен (C₂H₄)', ...
       'Ацетилен (C₂H₂)', ...
       'Location','best');

%% Концентрації оксидів вуглецю

subplot(3,1,2);

plot(t,data.coPPM,'LineWidth',1.5);
hold on;

plot(t,data.co2PPM,'LineWidth',1.5);

grid on;

xlabel('Час, год');
ylabel('Концентрація, ppm');
title('Концентрації оксидів вуглецю');

legend('Монооксид вуглецю (CO)', ...
       'Діоксид вуглецю (CO₂)', ...
       'Location','best');

%% Швидкість накопичення водню

subplot(3,1,3);

plot(t,dga.h2RatePPMperH,'LineWidth',1.6);
hold on;

limit = cfg.limits.h2RatePPMperH;
plot(t,limit*ones(size(t)),'--');

grid on;

xlabel('Час, год');
ylabel('Швидкість, ppm/год');
title('Швидкість накопичення водню');

legend('Швидкість накопичення H₂', ...
       'Умовна межа', ...
       'Location','best');

%% Межі осі часу: від першого до останнього вимірювання
format_time_axes(fig,t,7);

end
