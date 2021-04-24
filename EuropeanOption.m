% Valuation of an European Call with the following properties:
% - Strike: 100 
% - Valuation Date: 01/01/2021
% - Maturity: 01/01/2022
% - Subyacent Value: 100
% - Subyacent Volatility: 20 %
% - Interest Rate: 0%

% Is European so exercice can only be exercited at maturity (Last Step)
exerciceFunction = @(datetimeArray, maturityDatetime, stepSize)  zeros(1,size(datetimeArray,2))+[zeros(1,size(datetimeArray,2)-1),1];

% It is a call so its payoff definition is max(S - K, 0)
payoffFunction = @(subyacentPriceArray, datetimeArray, maturityDatetime) max(subyacentPriceArray - 100, 0); 

% No Barrier for this option so:
barrierFunction = @(subyacentPriceArray) ones(size(subyacentPriceArray)).*-1;

% Subyacent Value is 100 so:
subyacentValue = 100;

% Interest rate is 0% so:
interestRateFunction = @(datetimeArray) ones(size(datetimeArray)) .* 0;

% Valuation Date is 01/01/2021 so:
valuationDate = datetime(2021,1,1);

% Maturity is 01/021/2022 so:
maturity = datetime(2022,1,1);

% Volatility is constant and equal to 20% so:
volatilityFunction = @(datetimeArray) ones(size(datetimeArray)).*0.2;

% Now we have to define the number of price paths to use and the step size for each path.
stepSize = hours(1);

numberOfPaths = 500;

% Execute Option valuation:
optionPrice = montecarloOptionValuation(exerciceFunction, payoffFunction, barrierFunction, subyacentValue, interestRateFunction, valuationDate, maturity, volatilityFunction, stepSize, numberOfPaths)