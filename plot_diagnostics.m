function fig = plot_diagnostics(data,state)
% ФІНАЛЬНА ДІАГНОСТИКА ЗА 3.6 БЕЗ ВЛАСНОГО ІНДЕКСУ СТАРІННЯ
t = data.tH(:);
fig = figure('Name','Комплексний онлайн-моніторинг', ...
    'Color','w','Position',[100 40 980 900]);

%% 1. Відносне насичення та орієнтири IEC 60422
ax1 = subplot(4,1,1);
h1 = plot(t,state.relativeSaturationPct,'LineWidth',1.6);
hold on;
h2 = yline(state.rsGoodUpperPct,'--','LineWidth',1.0);
h3 = yline(state.rsFairUpperPct,'--','LineWidth',1.0);
grid on;
ylabel('RS, %');
title('Відносне насичення водою');
legend([h1 h2 h3],{'RS','10 %','20 %'},'Location','best');

%% 2. Зміна температурно-скоригованого tg delta
ax2 = subplot(4,1,2);
plot(t,state.deltaTanDeltaRef,'LineWidth',1.6);
hold on;
yline(0,'--','HandleVisibility','off');
grid on;
ylabel('\Delta tg \delta');
title('Зміна скоригованих діелектричних втрат');

%% 3. Відносна зміна електропровідності з підрозділу 3.5
ax3 = subplot(4,1,3);
h1 = plot(t,state.kSigma,'LineWidth',1.6);
hold on;
h2 = yline(state.dielectricKLimit,'--','LineWidth',1.0);
grid on;
ylabel('K_\sigma');
title('Зміна приведеної електропровідності');
legend([h1 h2],{'K_\sigma','Умовна межа'},'Location','best');

%% 4. Незалежні діагностичні сигнали
ax4 = subplot(4,1,4);
alarms = double([state.moisture,state.dielectric, ...
    state.thermal,state.dga])';
imagesc(t,1:4,alarms);
axis xy;
colormap(gca,[0.96 0.96 0.96; 0.85 0.26 0.25]);
caxis([0 1]);
yticks(1:4);
yticklabels({'Волога','Діел.','Тепло','DGA'});
xlabel('Час, год');
title('Попередження (червоний — активне)');

%% Мітки фізичного початку заданих подій, а не тривог
starts = [data.faultStartH.dielectric,data.faultStartH.cooling, ...
    data.faultStartH.moisture,data.faultStartH.gas];
names = {'Зміна електричних властивостей', ...
    'Порушення охолодження', 'Надходження води', ...
    'Початок газоутворення'};
colors = [0.82 0.22 0.24; 0.58 0.28 0.73; ...
    0.91 0.49 0.12; 0.17 0.51 0.72];

axesList = [ax1 ax2 ax3 ax4];
for j = 1:numel(axesList)
    for i = 1:numel(starts)
        if isfinite(starts(i))
            mark_fault_start(axesList(j),starts(i),'',colors(i,:));
        end
    end
end

format_time_axes(fig,t,7);
% Для категоріальної панелі зберігаємо її точні межі.
ylim(ax4,[0.5 4.5]);

%% Окреме місце під графіками для зрозумілої легенди
% Не накладаємо підписи на часові ряди та вісь часу.
set(ax1,'Position',[0.115 0.765 0.82 0.16]);
set(ax2,'Position',[0.115 0.575 0.82 0.15]);
set(ax3,'Position',[0.115 0.385 0.82 0.15]);
set(ax4,'Position',[0.115 0.215 0.82 0.12]);

if any(isfinite(starts))
    annotation(fig,'textbox',[0.12 0.133 0.83 0.027], ...
        'String','Початок змодельованих порушень:', ...
        'FontWeight','bold','FontSize',11, ...
        'EdgeColor','none','Interpreter','none');

    activeEvents = find(isfinite(starts));
    for k = 1:numel(activeEvents)
        i = activeEvents(k);
        column = mod(k-1,2);
        row = floor((k-1)/2);
        x = 0.12 + 0.43*column;
        y = 0.108 - 0.044*row;

        % Зразок пунктиру того самого кольору, що й лінія на графіку.
        annotation(fig,'line',[x x+0.035],[y y], ...
            'Color',colors(i,:),'LineStyle','--','LineWidth',2);
        annotation(fig,'textbox',[x+0.045 y-0.016 0.37 0.033], ...
            'String',sprintf('%.0f год — %s',starts(i),names{i}), ...
            'EdgeColor','none','FontSize',11,'Interpreter','none');
    end
end
end
