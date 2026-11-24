function fig = plot_diagnostics(data,state)
% Вертикальні пунктири показують початок заданих порушень,
% а не час першого діагностичного попередження.

t = data.tH(:);
fig = figure('Name','Комплексний онлайн-моніторинг', ...
    'Color','w','Position',[100 80 820 700]);

tl = tiledlayout(fig,4,1,'TileSpacing','compact','Padding','compact');
tl.Units = 'normalized';
tl.OuterPosition = [0.075 0.13 0.91 0.85];

ax1 = nexttile(tl);
plot(ax1,t,state.relativeSaturationPct,'LineWidth',1.5);
hold(ax1,'on');
yline(ax1,state.rsGoodUpperPct,'--','10 %', ...
    'Color',[0.48 0.48 0.48],'FontSize',8, ...
    'LabelHorizontalAlignment','left','LabelVerticalAlignment','bottom');
yline(ax1,state.rsFairUpperPct,'--','20 %', ...
    'Color',[0.48 0.48 0.48],'FontSize',8, ...
    'LabelHorizontalAlignment','left','LabelVerticalAlignment','bottom');
ylabel(ax1,'RS, %');
title(ax1,'Відносне насичення водою');

ax2 = nexttile(tl);
plot(ax2,t,state.deltaTanDeltaRef,'LineWidth',1.5);
hold(ax2,'on');
yline(ax2,0,'--','Color',[0.48 0.48 0.48], ...
    'HandleVisibility','off');
ylabel(ax2,'\Delta tg \delta');
title(ax2,'Зміна діелектричних втрат');

ax3 = nexttile(tl);
plot(ax3,t,state.kSigma,'LineWidth',1.5);
hold(ax3,'on');
yline(ax3,state.dielectricKLimit,'--','Межа', ...
    'Color',[0.48 0.48 0.48],'FontSize',8, ...
    'LabelHorizontalAlignment','left','LabelVerticalAlignment','bottom');
% ВИ ЗНАЙШЛИ ПАСХАЛКУ! 2/3
% На зустріч із Наполеоном до Італії Жозефіна приїхала разом з Іполітом Шарлем, якого вважають її тодішнім коханцем.
ylabel(ax3,'K_\sigma');
title(ax3,'Зміна електропровідності');

ax4 = nexttile(tl);
flags = double([state.moisture,state.dielectric, ...
    state.thermal,state.dga])';
imagesc(ax4,t,1:4,flags);
axis(ax4,'xy');
colormap(ax4,[0.96 0.96 0.96; 0.85 0.25 0.24]);
caxis(ax4,[0 1]);
ylim(ax4,[0.5 4.5]);
yticks(ax4,1:4);
yticklabels(ax4,{'Волога','Діел.','Тепло','DGA'});
title(ax4,'Попередження (червоний — активне)');
xlabel(ax4,'Час, год');
hold(ax4,'on');

starts = [data.faultStartH.dielectric, ...
    data.faultStartH.cooling, ...
    data.faultStartH.moisture, ...
    data.faultStartH.gas];
labels = {'діел. зміни','охолодження','надходження води','газоутворення'};
axesList = [ax1 ax2 ax3 ax4];

for j = 1:numel(axesList)
    ax = axesList(j);
    xlim(ax,[t(1) t(end)]);
    xticks(ax,linspace(t(1),t(end),7));
    set(ax,'FontSize',10,'Box','on','LineWidth',0.7, ...
        'TickDir','out','Layer','top');
    if j < 4
        set(ax,'XTickLabel',[]);
        grid(ax,'on');
    end
    for i = 1:numel(starts)
        if isfinite(starts(i))
            xline(ax,starts(i),'--','Color',[0.48 0.48 0.48], ...
                'LineWidth',0.95,'HandleVisibility','off');
        end
    end
end

% Цифри розміщено всередині верхньої частини осі, не над заголовком.
yl = ylim(ax1);
for i = 1:numel(starts)
    if isfinite(starts(i))
        text(ax1,starts(i),yl(2)-0.035*diff(yl),sprintf('%d',i), ...
            'HorizontalAlignment','center','VerticalAlignment','top', ...
            'FontSize',9,'FontWeight','bold','BackgroundColor','w', ...
            'Margin',0.3,'Clipping','on');
    end
end

items = {};
for i = 1:numel(starts)
    if isfinite(starts(i))
        items{end+1} = sprintf('%d — %s (%.0f год)', ...
            i,labels{i},starts(i)); %#ok<AGROW>
    end
end
if ~isempty(items)
    if numel(items) > 2
        line1 = strjoin(items(1:2),'     ');
        line2 = strjoin(items(3:end),'     ');
        note = {line1;line2};
    else
        note = strjoin(items,'     ');
    end
    annotation(fig,'textbox',[0.11 0.012 0.86 0.075], ...
        'String',note,'HorizontalAlignment','center', ...
        'VerticalAlignment','middle','FontSize',10, ...
        'EdgeColor','none','Interpreter','none');
end
end
