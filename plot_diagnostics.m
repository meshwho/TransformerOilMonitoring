function fig = plot_diagnostics(data,state)
% РЕЗУЛЬТАТИ КОМПЛЕКСНОЇ ОНЛАЙН-ДІАГНОСТИКИ (ПІДРОЗДІЛ 3.6)

t = data.tH(:);
fig = figure('Name','Комплексна онлайн-діагностика', ...
    'Color','w','Position',[100 70 940 800]);

%% 1. Нормовані показники стану масла (3.24-3.26)
subplot(3,1,1);
plot(t,state.moistureRatio,'LineWidth',1.3);
hold on;
plot(t,state.dielectricRatio,'LineWidth',1.3);
plot(t,state.oilRatio,'LineWidth',2);
plot(t,ones(size(t)),'k--','LineWidth',1.2);
grid on;
xlabel('Час, год');
ylabel('Відносний показник');
title('Комплексний показник стану масла');
legend('Вологісний стан R_M', ...
    'Діелектричний стан R_E', ...
    'Комплексний показник R_{oil}', ...
    'Умовна межа', 'Location','best');

%% 2. Окремі онлайн-попередження
subplot(3,1,2);
stairs(t,double(state.moisture),'LineWidth',1.4);
hold on;
stairs(t,double(state.dielectric),'LineWidth',1.4);
stairs(t,double(state.thermal),'LineWidth',1.4);
stairs(t,double(state.dga),'LineWidth',1.4);
grid on;
ylim([-0.1 1.2]);
yticks([0 1]);
xlabel('Час, год');
ylabel('Попередження');
title('Причини діагностичних попереджень');
legend('Вологовміст','Діелектричні властивості', ...
    'Тепловий стан','Газовий аналіз', 'Location','best');

%% 3. Кількість активних онлайн-попереджень
subplot(3,1,3);
stairs(t,state.activeWarnings,'LineWidth',1.8);
grid on;
ylim([-0.2 4.3]);
yticks(0:4);
xlabel('Час, год');
ylabel('Кількість');
title('Кількість одночасних онлайн-попереджень');

format_time_axes(fig,t,7);

end
