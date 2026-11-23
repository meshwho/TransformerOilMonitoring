function fig = plot_dielectric_online(data,oil)
% ЧОТИРИ ГРАФІКИ ОБРОБКИ ОНЛАЙН-ДІЕЛЕКТРИЧНИХ ВИМІРЮВАНЬ

t = data.tH(:);
fig = figure('Name','Онлайн-моніторинг діелектричних властивостей', ...
    'Color','w','Position',[100 70 920 780]);

%% 1. Температура масла
subplot(4,1,1);
plot(t,oil.temperatureC,'LineWidth',1.6);
grid on;
xlabel('Час, год');
ylabel('Температура, °C');
title('Температура масла за показаннями датчика');
mark_fault_start(gca,data.faultStartH.dielectric,'',[0.82 0.22 0.24]);

%% 2. Питомa електропровідність
subplot(4,1,2);
plot(t,oil.conductivitySperM*1e12,'LineWidth',1.4);
hold on;
plot(t,oil.conductivityRefSperM*1e12,'LineWidth',1.7);
grid on;
xlabel('Час, год');
ylabel('Провідність, пСм/м');
title('Електропровідність з температурною корекцією');
mark_fault_start(gca,data.faultStartH.dielectric,'Діел.',[0.82 0.22 0.24]);
legend('За поточної температури', ...
       'Приведено до опорної температури', ...
       'Location','best');

%% 3. Тангенс діелектричних втрат
subplot(4,1,3);
plot(t,oil.tanDelta,'LineWidth',1.4);
hold on;
plot(t,oil.tanDeltaRef,'LineWidth',1.7);
grid on;
xlabel('Час, год');
ylabel('tan δ');
title('Діелектричні втрати масла');
mark_fault_start(gca,data.faultStartH.dielectric,'',[0.82 0.22 0.24]);
legend('За поточної температури', ...
       'Приведено до опорної температури', ...
       'Location','best');

%% 4. Відносна зміна приведеної електропровідності
subplot(4,1,4);
plot(t,oil.conditionIndex,'LineWidth',1.7);
hold on;
plot(t,ones(size(t)),'--');
grid on;
xlabel('Час, год');
ylabel('K_\sigma');
title('Відносна зміна електропровідності');
mark_fault_start(gca,data.faultStartH.dielectric,'',[0.82 0.22 0.24]);
legend('K_\sigma', 'Початковий рівень', 'Location','best');

format_time_axes(fig,t,7);

end
