
function fig = plot_diagnostics(data, state)
% ГРАФІКИ РЕЗУЛЬТАТІВ КОМПЛЕКСНОЇ ДІАГНОСТИКИ

t = data.tH;

fig = figure('Name','Діагностика','Color','w');

%% Результати окремих моделей

subplot(2,1,1);

stairs(t,double(state.thermal),'LineWidth',1.5);
hold on;

stairs(t,double(state.moisture),'LineWidth',1.5);
stairs(t,double(state.dga),'LineWidth',1.5);
stairs(t,double(state.quality),'LineWidth',1.5);

grid on;
ylim([-0.1 1.2]);
yticks([0 1]);

xlabel('Час, год');
ylabel('Попередження');

title('Результати комплексної діагностики');

legend('Тепловий стан', ...
       'Вологовміст', ...
       'Газовий аналіз', ...
       'Лабораторна оцінка якості', ...
       'Location','best');

%% Кількість активних попереджень

subplot(2,1,2);

stairs(t,state.activeWarnings,'LineWidth',1.8);

grid on;
ylim([-0.2 4.3]);
yticks(0:4);

xlabel('Час, год');
ylabel('Кількість попереджень');

title('Кількість одночасних попереджень');

%% Межі осі часу: від першого до останнього вимірювання
format_time_axes(fig,t,7);

end
