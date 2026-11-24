function out = model_dga(data,cfg)

t = data.tH(:);
N = numel(t);
gasFields = {'h2PPM','ch4PPM','c2h6PPM','c2h4PPM', ...
             'c2h2PPM','coPPM','co2PPM'};
gasNames = {'H2','CH4','C2H6','C2H4','C2H2','CO','CO2'};
nGases = numel(gasFields);

if N < 2 || any(~isfinite(t)) || any(diff(t) <= 0)
    error('Некоректний часовий ряд газового аналізу.');
end

measured = zeros(N,nGases);
for i = 1:nGases
    values = data.(gasFields{i})(:);
    if numel(values) ~= N
        error('Кількість вимірювань газів не відповідає часу.');
    end
    measured(:,i) = values;
end

% Маска відокремлює реальні цикли газоаналізатора від утриманих
% показань на проміжній часовій сітці інших моделей.
if isfield(data,'dgaMeasurementMask')
    mask = logical(data.dgaMeasurementMask(:));
    if numel(mask) ~= N
        error('Некоректна маска вимірювань газоаналізатора.');
    end
else
    mask = true(N,1);
end

sampleIndex = find(mask);
if numel(sampleIndex) < 2 || sampleIndex(1) ~= 1
    error('Недостатньо показань газоаналізатора.');
end

tGas = t(sampleIndex);
C = measured(sampleIndex,:);
C(~isfinite(C) | C < 0) = nan;
M = numel(tGas);

% Сума шести горючих газів: CO2 не враховується
TDCG = nan(M,1);
validTDCG = all(isfinite(C(:,1:6)),2);
TDCG(validTDCG) = sum(C(validTDCG,1:6),2);

windowH = cfg.dga.averageWindowH;
lagH = cfg.dga.dailyLagH;
minSamples = cfg.dga.minReliableSamples;

average = nan(M,nGases);
averageTDCG = nan(M,1);

for k = 1:M
    if tGas(k)-tGas(1) < windowH-1e-8
        continue;
    end

    inWindow = tGas > tGas(k)-windowH+1e-8 & ...
               tGas <= tGas(k)+1e-8;

    for i = 1:nGases
        values = C(inWindow,i);
        values = values(isfinite(values));
        if numel(values) >= minSamples
            average(k,i) = mean(values);
        end
    end

    values = TDCG(inWindow);
    values = values(isfinite(values));
    if numel(values) >= minSamples
        averageTDCG(k) = mean(values);
    end
end

dailyChange = nan(M,nGases);
rate = nan(M,nGases);
dailyChangeTDCG = nan(M,1);
rateTDCG = nan(M,1);

for k = 1:M
    previousTime = tGas(k)-lagH;
    previous = find(tGas <= previousTime+1e-8,1,'last');

    % Для реальних нерівномірних вимірювань потрібна точка
    % достатньо близько до попереднього моменту часу.
    if isempty(previous) || ...
            abs(tGas(previous)-previousTime) > ...
            0.5*median(diff(tGas))
        continue;
    end

    dailyChange(k,:) = average(k,:)-average(previous,:);
    rate(k,:) = dailyChange(k,:)/lagH;

    dailyChangeTDCG(k) = averageTDCG(k)-averageTDCG(previous);
    rateTDCG(k) = dailyChangeTDCG(k)/lagH;
end

% Індекси: 1-H2, 2-CH4, 3-C2H6, 4-C2H4, 5-C2H2.
% Якщо хоча б один газ нижче умовної межі достовірності,
% співвідношення не інтерпретуємо.
ratios = nan(M,3);
pairs = [2 1; 5 4; 4 3];
ratioMin = cfg.dga.ratioMinimumPPM(:)';

for j = 1:3
    numerator = pairs(j,1);
    denominator = pairs(j,2);

    reliable = isfinite(average(:,numerator)) & ...
               isfinite(average(:,denominator)) & ...
               average(:,numerator) >= ratioMin(numerator) & ...
               average(:,denominator) >= ratioMin(denominator) & ...
               average(:,denominator) > 0;

    ratios(reliable,j) = average(reliable,numerator) ./ ...
                         average(reliable,denominator);
end

% Межі демонстраційні, а не нормативні.
concentrationLimit = cfg.limits.dgaConcentrationPPM(:)';
rateLimit = cfg.limits.dgaRatePPMperH(:)';

if numel(concentrationLimit) ~= nGases || numel(rateLimit) ~= nGases
    error('Потрібно задати межі для семи газів.');
end

highConcentration = average > concentrationLimit;
highRate = rate > rateLimit;
warningAtSample = any(highConcentration | highRate,2);

% Утримання останнього результату між циклами вимірювання
lastSample = zeros(N,1);
lastSample(sampleIndex) = 1:M;
lastSample = cummax(lastSample);

out.gasNames = gasNames;
out.measurementMask = mask;
out.TDCG = TDCG(lastSample);
out.average24PPM = average(lastSample,:);
out.averageTDCGPPM = averageTDCG(lastSample);
out.dailyChangePPM = dailyChange(lastSample,:);
out.dailyChangeTDCGPPM = dailyChangeTDCG(lastSample);
out.ratePPMperH = rate(lastSample,:);
out.h2RatePPMperH = rate(lastSample,1);
out.tdcgRatePPMperH = rateTDCG(lastSample);
out.ratioCH4H2 = ratios(lastSample,1);
out.ratioC2H2C2H4 = ratios(lastSample,2);
out.ratioC2H4C2H6 = ratios(lastSample,3);

out.highConcentration = highConcentration(lastSample,:);
out.highRate = highRate(lastSample,:);
out.highH2Rate = highRate(lastSample,1);
out.highAcetylene = highConcentration(lastSample,5);
out.warning = warningAtSample(lastSample);

end
