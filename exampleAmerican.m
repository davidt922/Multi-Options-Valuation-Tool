examplePath = [1,1.09,1.08,1.34;1,1.16,1.26,1.54;1,1.22,1.07,1.03;1,0.93,0.97,0.92;1,1.11,1.56,1.52;1,0.76,0.77,0.90;1,0.92,0.84,1.01;1,0.88,1.22,1.34];
% American
exerciceFunction_ = @(actualDate, maturityDate, stepSize)   true(size(actualDate));
% NO barrier
barrier_ = @(subyacentPrice) ones(size(subyacentPrice)).*-1;

% Payoff Put strike 1.1

payoff_ = @(subyacentPrice, actualDate, maturityDate) max(1.1 - subyacentPrice, 0);

% Step Datetime array

stepDatetimeArray = [datetime(2021,1,1);datetime(2022,1,1);datetime(2023,1,1);datetime(2024,1,1)];

stepDatetimeArray = repmat(stepDatetimeArray',size(examplePath,1),1);

interestRateArray = ones(size(examplePath)) .*0.06;

maturity = datetime(2024,1,1);

stepSize = years(1);

optionValuation(exerciceFunction_, barrier_, payoff_, examplePath, stepDatetimeArray, interestRateArray, maturity, stepSize)
