
function fig = plot_oil_ageing(data)
% ПОБУДОВА ГРАФІКІВ ЗМІНИ ВЛАСТИВОСТЕЙ МАСЛА

lab = data.lab;
t = lab.month;

fig = figure( ...
    'Name','Старіння трансформаторного масла', ...
    'Color','w');

%% Кислотне число

subplot(2,2,1);

plot(t,lab.acid,'-o','LineWidth',1.5);

grid on;
xlabel('Час, міс');
ylabel('Кислотне число, мг КОН/г');
title('Зміна кислотного числа');

%% Пробивна напруга

subplot(2,2,2);

plot(t,lab.breakdownKV,'-o','LineWidth',1.5);

grid on;
xlabel('Час, міс');
ylabel('Напруга, кВ');
title('Зміна пробивної напруги');

%% Діелектричні втрати

subplot(2,2,3);

plot(t,lab.tanDelta,'-o','LineWidth',1.5);

grid on;
xlabel('Час, міс');
ylabel('tg δ');
title('Зміна діелектричних втрат');

%% Міжфазний натяг

subplot(2,2,4);

plot(t,lab.ift,'-o','LineWidth',1.5);

grid on;
xlabel('Час, міс');
ylabel('Міжфазний натяг, мН/м');
title('Зміна міжфазного натягу');

end
