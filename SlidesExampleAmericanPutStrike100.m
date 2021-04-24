Installation();
tic
warning('off','all')
% American Style option (as stepsize == 1 day everyting ok)
exerciceFunction_ = @(actualDate, maturityDate, stepSize)   true(size(actualDate));

% NO barrier
barrier_ = @(subyacentPrice) ones(size(subyacentPrice)).*-1;

subyacentValue_ = 100;

% Interest rate 4% per annum (continiously compounded), divident 2% ->
% final interest rate 2%
interestRate_ = @(actualDate) ones(size(actualDate)) .* 0.02;

valuationDate_ = datetime(2016,01,01);

maturity_ = datetime(2017,01,01);

volatility_ = @(actualDate) ones(size(actualDate)).*0.3; % 0.3

stepSize_ = hours(1); % 1 day
% ACT/365
price = montecarloOptionValuation(exerciceFunction_, @payoff_, barrier_, subyacentValue_, interestRate_, valuationDate_, maturity_, volatility_, stepSize_); % valor real 33.155, any normal 33.1529, any bisiesto: 33.1620 Media ponderada 33.155

toc
warning('on','all')
%         step1   step2  step3  step4
% Path 1
% Path 2
% Path 3

% Payoff call strike = 120
function pay = payoff_(subyacentPrice, actualDate, maturityDate)
    
    strike = 100;
    %pay = zeros(size(subyacentPrice));
    %pay(:,end) = max(subyacentPrice(:,end) - strike, 0);
    pay = max(strike - subyacentPrice, 0);
end