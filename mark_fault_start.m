function mark_fault_start(ax,startHour,label,color)
% НЕ момент перевищення межі та НЕ результат діагностики.

if ~isscalar(startHour) || ~isfinite(startHour)
    return;
end

if isempty(label)
    xline(ax,startHour,'--', 'Color',color, ...
        'LineWidth',1.5,'HandleVisibility','off');
else
    xline(ax,startHour,'--',label,'Color',color, ...
        'LineWidth',1.5,'HandleVisibility','off', ...
        'LabelOrientation','horizontal', ...
        'LabelVerticalAlignment','top', ...
        'LabelHorizontalAlignment','right', ...
        'FontSize',9);
end

end
