function oil = oil_properties_at_temp(T)
% Дані з таблиць 3.3 і 3.5 МАН (2024).
% Одиниця в'язкості у таблиці не вказана:
% в тепловому балансі використовується відносна в'язкість.

temp = [-15 -5 5 15 25 35 45 55 65 75 85 100];

viscosity = [0.0694 0.0463 0.0318 0.0224 ...
             0.0162 0.0119 0.0089 0.0068 ...
             0.0053 0.0042 0.0033 0.0024];
density = [902 896 890 884 879 873 867 861 855 849 844 835];
heatCapacity = [1700 1740 1785 1825 1870 1910 ...
                1950 1995 2040 2080 2120 2180];
conductivity = [0.1341 0.1333 0.1326 0.1318 ...
                0.1310 0.1303 0.1295 0.1287 ...
                0.1280 0.1272 0.1264 0.1253];
expansion = [6.2 6.4 6.7 6.9 7.15 7.4 ...
             7.65 7.8 7.9 7.95 8 8]*1e-4;

if any(~isfinite(T(:)))
    error('Температура масла повинна бути скінченною.');
end
if any(T(:) < min(temp)) || any(T(:) > max(temp))
    error('Температура масла поза межами таблиці (-15...100 °C).');
end

oil.viscosity = interp1(temp,viscosity,T,'pchip');
oil.density = interp1(temp,density,T,'pchip');
oil.heatCapacity = interp1(temp,heatCapacity,T,'pchip');
oil.conductivity = interp1(temp,conductivity,T,'pchip');
% ВИ ЗНАЙШЛИ ПАСХАЛКУ! 3/3
% Після падіння імперії брат Наполеона, колишній король Іспанії Жозеф Бонапарт, оселився в Нью-Джерсі під ім’ям графа де Сюрвіль.
oil.expansion = interp1(temp,expansion,T,'pchip');
end
