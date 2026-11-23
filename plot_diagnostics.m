function fig = plot_diagnostics(data,state)
% ФІНАЛЬНА ДІАГНОСТИКА ЗА 3.6 БЕЗ ВЛАСНОГО ІНДЕКСУ СТАРІННЯ
t = data.tH(:);
fig = figure('Name','Комплексний онлайн-моніторинг', ...
    'Color','w','Position',[100 40 980 900]);

%% 1. Відносне насичення та орієнтири IEC 60422
subplot(4,1,1);
h1 = plot(t,state.relativeSaturationPct,'LineWidth',1.6);
hold on;
h2 = yline(state.rsGoodUpperPct,'--','LineWidth',1.0);
h3 = yline(state.rsFairUpperPct,'--','LineWidth',1.0);
grid on;
ylabel('RS, %');
title('Відносне насичення водою');
legend([h1 h2 h3],{'RS','10 %','20 %'},'Location','best');

%% 2. Зміна температурно-скоригованого tg delta
subplot(4,1,2);
plot(t,state.deltaTanDeltaRef,'LineWidth',1.6);
hold on;
yline(0,'--','HandleVisibility','off');
grid on;
ylabel('\Delta tg \delta');
title('Зміна скоригованих діелектричних втрат');

%% 3. Відносна зміна електропровідності з підрозділу 3.5
subplot(4,1,3);
h1 = plot(t,state.kSigma,'LineWidth',1.6);
hold on;
h2 = yline(state.dielectricKLimit,'--','LineWidth',1.0);
grid on;
ylabel('K_\sigma');
title('Зміна приведеної електропровідності');
legend([h1 h2],{'K_\sigma','Умовна межа'},'Location','best');

%% 4. Незалежні діагностичні сигнали
subplot(4,1,4);
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
names = {'Діел.','Охол.','Волога','DGA'};
colors = [0.82 0.22 0.24; 0.58 0.28 0.73; ...
    0.91 0.49 0.12; 0.17 0.51 0.72];

ax = findall(fig,'Type','axes');
for j = 1:numel(ax)
    for i = 1:numel(starts)
        if isfinite(starts(i))
            mark_fault_start(ax(j),starts(i),'',colors(i,:));
        end
    end
end

events = {};
for i = 1:numel(starts)
    if isfinite(starts(i))
        events{end+1} = sprintf('%.0f год: %s',starts(i),names{i}); %#ok<AGROW>
    end
end
if ~isempty(events)
    annotation(fig,'textbox',[0.11 0.006 0.85 0.03], ...
        'String',strjoin(events,'   '), ...
        'EdgeColor','none','HorizontalAlignment','center','FontSize',9);
end

format_time_axes(fig,t,7);
% Не розширюємо категоріальні межі четвертої панелі.
subplot(4,1,4);
ylim([0.5 4.5]);
end
