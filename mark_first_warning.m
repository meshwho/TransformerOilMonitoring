function mark_first_warning(ax,t,flags,label)
% ВЕРТИКАЛЬНА ЛІНІЯ ПЕРШОГО ВИЯВЛЕНОГО ПЕРЕВИЩЕННЯ
% Відображає момент спрацювання алгоритму, не фізичний початок дефекту.
% Якщо перевищень немає, позначка не додається.

t = t(:);
flags = flags(:);
if numel(t) ~= numel(flags)
    error('Час і маска попереджень мають різну довжину.');
end

idx = find(flags == 1,1,'first');
if isempty(idx)
    return;
end

% Приховуємо службову лінію від легенди графіка.
if isempty(label)
    xline(ax,t(idx),'--','Color',[0.84 0.20 0.20], ...
        'LineWidth',1.4,'HandleVisibility','off');
else
    xline(ax,t(idx),'--',label, ...
        'Color',[0.84 0.20 0.20],'LineWidth',1.4, ...
        'LabelHorizontalAlignment','right', ...
        'LabelVerticalAlignment','top','FontSize',8, ...
        'HandleVisibility','off');
end

end
