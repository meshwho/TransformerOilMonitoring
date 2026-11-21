
function state = evaluate_state(thermal, moisture, dga, quality)
% КОМПЛЕКСНА ОЦІНКА СТАНУ МАСЛА ТА ТРАНСФОРМАТОРА

%% Результати окремих моделей

state.thermal = thermal.warning;
state.moisture = moisture.warning;
state.dga = dga.warning;

% Остання лабораторна оцінка якості масла
state.quality = repmat( ...
    quality.warning, size(moisture.warning));

%% Оцінка стану трансформаторного масла

state.oilWarning = state.moisture | state.quality;

%% Ознаки можливих несправностей трансформатора

state.equipmentWarning = ...
    state.thermal | state.dga;

%% Загальне діагностичне попередження

state.anyWarning = ...
    state.oilWarning | state.equipmentWarning;

%% Кількість активних попереджень

state.activeWarnings = ...
    double(state.thermal) ...
    + double(state.moisture) ...
    + double(state.dga) ...
    + double(state.quality);

end
