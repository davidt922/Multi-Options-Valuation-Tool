% Generate path from a Geometric Brownian Motion
function [pricePath, stepDatetimeArray, interestRateArray] = generatePathUsingGBM(subyacentValue, interestRate, volatility, stepSize, valuationDate, maturity, numberOfPaths)

    numberOfSteps = (maturity - valuationDate)/stepSize; % if step size = 1 day, numberOfSteps = 365 or 366 if year is bisiesto (Converted to Act/365 when using computeStepSizeInYears)
    
    stepDatetimeArray = ((0:numberOfSteps).*stepSize) + valuationDate; % Start from 0 as the first value will be the value at t=0
    interestRateArray = interestRate(stepDatetimeArray);    
    volatilityArray = volatility(stepDatetimeArray);    
    
    stepDatetimeArray = repmat(stepDatetimeArray, numberOfPaths, 1);
    interestRateArray = repmat(interestRateArray, numberOfPaths, 1);
    volatilityArray = repmat(volatilityArray, numberOfPaths, 1);
    
    randomNormalValues = normrnd(0,1,[numberOfPaths, numberOfSteps]);
          
    SInEachStep = zeros(size(stepDatetimeArray));
    
    stepSizeInYears = computeStepSizeInYears(stepSize); % To use ACT/365
    
    SInEachStep(:,1) = subyacentValue;
    for i = 2:(numberOfSteps + 1)
        
        SInEachStep(:,i) = SInEachStep(:,i-1) + ...
            interestRateArray(:,i-1) .* SInEachStep(:,i-1) .* stepSizeInYears + ...
            volatilityArray(:,i-1) .* SInEachStep(:,i-1) .* sqrt(stepSizeInYears) .* randomNormalValues(:,i-1);
            
    end % stepSizeInYears applied numberOfSteps times (2 -> numberOfSteps+1)
    pricePath = SInEachStep;
    
end