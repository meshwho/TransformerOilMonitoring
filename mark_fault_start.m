function mark_fault_start(ax,startHour,label,color)
% ПОЧАТОК ШТУЧНО ЗАДАНОЇ НЕСПРАВНОСТІ У НАВЧАЛЬНОМУ СЦЕНАРІЇ.
% НЕ момент перевищення межі та НЕ результат діагностики.
% Позначка показує відоме лише генератору даних втручання.

if ~isscalar(startHour) || ~isfinite(startHour)
    return;
end

% Мітка належить лише часовому вікну поточного графіка.
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
