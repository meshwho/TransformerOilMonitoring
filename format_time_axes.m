function format_time_axes(fig,t,tickCount)
% МЕЖІ ОСІ ЧАСУ ТА ВІДСТУПИ ДЛЯ ГРАФІКІВ
% Вісь X закінчується останнім вимірюванням.
% Вісь Y має запас, щоб лінії не торкалися рамки.

if nargin < 3
    tickCount = 7;
end

if numel(t) < 2 || t(1) >= t(end)
    error('Для осі часу потрібні щонайменше два різні моменти.');
end

axesList = findall(fig,'Type','axes');

for k = 1:numel(axesList)
    ax = axesList(k);

    % Межі по часу без порожньої ділянки справа.
    xlim(ax,[t(1),t(end)]);
    xticks(ax,linspace(t(1),t(end),tickCount));

    % Відступи для всіх кривих, включно з умовними межами.
    limits = ylim(ax);

    if strcmp(get(ax,'YScale'),'log')
        % Логарифмічна вісь не допускає від'ємних значень.
        factor = (limits(2)/limits(1))^0.08;
        ylim(ax,[limits(1)/factor,limits(2)*factor]);
    else
        margin = 0.08*(limits(2)-limits(1));
        ylim(ax,[limits(1)-margin,limits(2)+margin]);
    end
end

end
