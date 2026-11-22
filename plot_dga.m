function fig = plot_dga(data,dga,cfg)
% ГРАФІКИ ОБРОБКИ ПОКАЗАНЬ ОНЛАЙН-ГАЗОАНАЛІЗАТОРА

t = data.tH(:);
fig = figure('Name','Газовий аналіз','Color','w', ...
    'Position',[100 80 900 700]);

%% Виміряні концентрації основних газів
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
title('Показання газоаналізатора');
legend('Водень (H₂)','Метан (CH₄)','Етан (C₂H₆)', ...
       'Етилен (C₂H₄)','Ацетилен (C₂H₂)', ...
       'Location','best');

%% Загальна концентрація горючих газів
subplot(3,1,2);
plot(t,dga.TDCG,'LineWidth',1.3);
hold on;
plot(t,dga.averageTDCGPPM,'LineWidth',1.8);
grid on;
xlabel('Час, год');
ylabel('TDCG, ppm');
title('Сумарна концентрація горючих газів');
legend('За показаннями','Середнє за 24 години', ...
       'Location','best');

%% Швидкість зміни усередненої концентрації водню
subplot(3,1,3);
plot(t,dga.h2RatePPMperH,'LineWidth',1.6);
hold on;
plot(t,cfg.limits.h2RatePPMperH*ones(size(t)),'--');
plot(t,zeros(size(t)),':');
grid on;
xlabel('Час, год');
ylabel('Зміна H₂, ppm/год');
title('Швидкість зміни концентрації водню за добу');
legend('Швидкість зміни','Умовна межа','Нульова зміна', ...
       'Location','best');

format_time_axes(fig,t,7);

end
