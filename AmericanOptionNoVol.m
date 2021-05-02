% American Style option (as stepsize == 1 day everyting ok)
%exerciceFunction_ = @(actualDate, maturityDate, stepSize)   true(size(actualDate));
exerciceFunction_ = @(datetimeArray, maturityDatetime, stepSize) repmat([zeros(1,size(datetimeArray,2)-2),1,1],size(datetimeArray,1),1);

% NO barrier
barrier_ = @(subyacentPrice) ones(size(subyacentPrice)).*-1;

subyacentValue_ = 100;

% Interest rate 4% per annum (continiously compounded), divident 2% ->
% final interest rate 2%
interestRate_ = @(actualDate) ones(size(actualDate)) .* 0.00001;

valuationDate_ = datetime(2016,01,01);

maturity_ = datetime(2017,01,01);

volatility_ = @(actualDate) ones(size(actualDate)).*0.2;

stepSize_ = hours(24); % 1 day
% ACT/365
price = montecarloOptionValuation(exerciceFunction_, @payoff_, barrier_, subyacentValue_, interestRate_, valuationDate_, maturity_, volatility_, stepSize_); % valor real 33.155, any normal 33.1529, any bisiesto: 33.1620 Media ponderada 33.155

%         step1   step2  step3  step4
% Path 1
% Path 2
% Path 3

% Payoff call strike = 120
function pay = payoff_(subyacentPrice, actualDate, maturityDate)
    
    strike = 100;
    %pay = zeros(size(subyacentPrice));
    %pay(:,end) = max(subyacentPrice(:,end) - strike, 0);
    pay = max( subyacentPrice - strike, 0);
end