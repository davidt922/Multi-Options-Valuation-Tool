Installation()

% Initial subyacent price
subyacentValue = 100;

% Definition of the interestRate function for an annual continiously compounded interest rate of 0%
interestRate = @(actualDate) ones(size(actualDate)) .* 0.5;

% Definition of the volatility function for a 20% volatility
vol = 0.2;
volatility = @(actualDate) ones(size(actualDate)) .* vol; 

stepSizeHoursRange = 1:1:1440;

volatilityRelativeError =[];
usedStepSize = [];

for i = stepSizeHoursRange
    % define the step size as 1 hour:
    stepSize = minutes(i);

    anualizationCoefficient = years(1)/years(computeStepSizeInYears(stepSize)); 

    % Define the valuation date and the maturity to have a 10 year
    % price path
    valuationDate = datetime(2021,01,01);
    maturity = datetime(2031,01,01);
    
    if floor((maturity - valuationDate)./stepSize) ~=(maturity - valuationDate)./stepSize
       continue; 
    end

    % Generate 500 path to make an average of the volatility of all
    % the paths
    numberOfPaths = 100;

    [pricePath, stepDatetimeArray, interestRateArray] = generatePathUsingWienerProcess(subyacentValue, interestRate, volatility, stepSize, valuationDate, maturity, numberOfPaths);

    logRentEachPath = log(pricePath(:,2:end)./pricePath(:,1:end-1));

    % Standard deviation along 2º dimension
    pathsVolatility = std(logRentEachPath, 0, 2);
    % As the step size is 1 day, the volatility is daily so we have
    % to annualized:
    pathsVolatility = pathsVolatility .*sqrt(anualizationCoefficient);

    meanVolatility = mean(pathsVolatility);

    fprintf("Mean Volatility of the generated paths: %f, input volatility: %f\n",meanVolatility, vol)
    volatilityRelativeError(end+1) = abs(meanVolatility - vol)./vol.*100;
    usedStepSize(end+1) = i;
end

plot(usedStepSize, volatilityRelativeError)
title('Error relativo de la volatilidad en función del tamaño de paso')
ylabel('Error relativo de la volatilidad [%]')
xlabel('Tamaño de paso [minutos]')