function format_time_axes(fig,t,tickCount)
% ОДНАКОВІ МЕЖІ ОСІ ЧАСУ ДЛЯ ВСІХ ГРАФІКІВ
% Лінії завершуються на останньому вимірюванні,
% а не перед додатковим порожнім інтервалом.

if nargin < 3
    tickCount = 7;
end

if numel(t) < 2 || t(1) >= t(end)
    error('Для осі часу потрібні щонайменше два різні моменти.');
end

axesList = findall(fig,'Type','axes');

for k = 1:numel(axesList)
    xlim(axesList(k),[t(1),t(end)]);
    xticks(axesList(k),linspace(t(1),t(end),tickCount));
end

end
