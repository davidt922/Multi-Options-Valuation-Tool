exerciceFunction = @(actualDate, maturityDate, stepSize)   true(size(actualDate));
barrier = @(subyacentPrice) true(size(subyacentPrice)).*-1;
payoff = @(subyacentPrice, actualDate, maturityDate) max(subyacentPrice - 10, 0);
path = [10, 15, 12, 17];
stepDatetimeArray = [datetime(2021, 04, 10), datetime(2021, 04, 11), datetime(2021, 04, 12), datetime(2021, 04, 13)];
interestRateArray = [0,0,0,0];
maturity = datetime(2021, 04, 13);
stepSize = seconds(86400);

[meanPayoff, times] = meanPayout(exerciceFunction, barrier, payoff, path, stepDatetimeArray, interestRateArray, maturity, stepSize)