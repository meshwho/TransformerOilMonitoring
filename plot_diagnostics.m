function fig = plot_diagnostics(data,state)
% КОМПЛЕКСНА ОНЛАЙН-ДІАГНОСТИКА (ПІДРОЗДІЛ 3.6)
% Компактне наукове оформлення: чотири панелі та звичайна легенда.
t = data.tH(:);
fig = figure('Name','Комплексний онлайн-моніторинг', ...
    'Color','w','Position',[100 60 800 720]);

%% 1. Відносне насичення за IEC 60422
ax1 = subplot(4,1,1);
h1 = plot(t,state.relativeSaturationPct,'LineWidth',1.5);
hold on;
h2 = yline(state.rsGoodUpperPct,'--','LineWidth',1);
h3 = yline(state.rsFairUpperPct,'--','LineWidth',1);
grid on;
ylabel('RS, %');
title('Відносне насичення водою');
legend([h1 h2 h3],{'RS','10 %','20 %'}, ...
    'Location','northwest','FontSize',9);

%% 2. Зміна температурно-скоригованих втрат
ax2 = subplot(4,1,2);
plot(t,state.deltaTanDeltaRef,'LineWidth',1.5);
hold on;
yline(0,'--','HandleVisibility','off');
grid on;
ylabel('\Delta tg \delta');
title('Зміна скоригованих діелектричних втрат');

%% 3. Приведена електропровідність
ax3 = subplot(4,1,3);
h1 = plot(t,state.kSigma,'LineWidth',1.5);
hold on;
h2 = yline(state.dielectricKLimit,'--','LineWidth',1);
grid on;
ylabel('K_\sigma');
title('Відносна зміна електропровідності');
legend([h1 h2],{'K_\sigma','Умовна межа'}, ...
    'Location','northwest','FontSize',9);

%% 4. Попередження окремих онлайн-каналів
ax4 = subplot(4,1,4);
alarms = double([state.moisture,state.dielectric, ...
    state.thermal,state.dga])';
imagesc(t,1:4,alarms);
axis xy;
colormap(ax4,[0.96 0.96 0.96; 0.85 0.26 0.25]);
caxis(ax4,[0 1]);
yticks(1:4);
yticklabels({'Волога','Діел.','Тепло','DGA'});
xlabel('Час, год');
title('Діагностичні попередження (червоний — активне)');
hold on;

%% Вертикальні пунктири — момент ПОЧАТКУ заданої несправності
% Не слід плутати з часом першого діагностичного попередження.
starts = [data.faultStartH.dielectric,data.faultStartH.cooling, ...
    data.faultStartH.moisture,data.faultStartH.gas];
names = {'Діел. зміни','Охолодження','Волога','Газоутворення'};
colors = [0.82 0.22 0.24; 0.58 0.28 0.73; ...
    0.91 0.49 0.12; 0.17 0.51 0.72];

% Лінії на верхніх панелях приховані від їхніх легенд.
for i = 1:numel(starts)
    if ~isfinite(starts(i))
        continue;
    end
    mark_fault_start(ax1,starts(i),'',colors(i,:));
    mark_fault_start(ax2,starts(i),'',colors(i,:));
    mark_fault_start(ax3,starts(i),'',colors(i,:));
end

% На останній панелі ці самі лінії входять до звичайної легенди MATLAB.
eventHandles = gobjects(0);
eventLabels = {};
for i = 1:numel(starts)
    if isfinite(starts(i))
        h = line(ax4,[starts(i) starts(i)],[0.5 4.5], ...
            'LineStyle','--','LineWidth',1.4,'Color',colors(i,:));
        eventHandles(end+1) = h; %#ok<AGROW>
        eventLabels{end+1} = sprintf('%.0f год — %s', ...
            starts(i),names{i}); %#ok<AGROW>
    end
end

format_time_axes(fig,t,7);
ylim(ax4,[0.5 4.5]);

%% Рівні за розміром панелі; під ними — стандартна легенда.
set([ax1 ax2 ax3 ax4],'FontSize',10);
set(ax1,'Position',[0.13 0.775 0.83 0.16]);
set(ax2,'Position',[0.13 0.58 0.83 0.16]);
set(ax3,'Position',[0.13 0.385 0.83 0.16]);
set(ax4,'Position',[0.13 0.19 0.83 0.16]);

if ~isempty(eventHandles)
    lg = legend(ax4,eventHandles,eventLabels, ...
        'NumColumns',2,'Orientation','horizontal', ...
        'Box','off','FontSize',10);
    set(lg,'Units','normalized','Position',[0.14 0.022 0.81 0.085]);
    % Після створення легенди MATLAB може змінити розмір осі.
    set(ax4,'Position',[0.13 0.19 0.83 0.16]);
end
end
