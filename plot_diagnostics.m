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
mark_first_warning(gca,t,state.oilWarning, ...
    'Перше перевищення R_{oil}');
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
mark_first_warning(gca,t,state.anyWarning, ...
    'Перше онлайн-попередження');

% Точки окремо вказують перше спрацювання кожного з чотирьох каналів.
alarmFlags = [state.moisture(:),state.dielectric(:), ...
    state.thermal(:),state.dga(:)];
alarmColors = get(gca,'ColorOrder');
for channel = 1:size(alarmFlags,2)
    firstIndex = find(alarmFlags(:,channel),1,'first');
    if ~isempty(firstIndex)
        plot(t(firstIndex),1,'o','MarkerSize',6, ...
            'MarkerFaceColor',alarmColors(channel,:), ...
            'MarkerEdgeColor',alarmColors(channel,:), ...
            'HandleVisibility','off');
    end
end
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
mark_first_warning(gca,t,state.anyWarning,'');

format_time_axes(fig,t,7);

end
