
%exerciceFunction_ = @(actualDate, maturityDate, stepSize)   isbetween(actualDate,maturityDate - stepSize/2, maturityDate + stepSize/2) | isbetween(actualDate,maturityDate - stepSize/2-1, maturityDate + stepSize/2-1) | isbetween(actualDate,actualDate(1,1) - stepSize/2+1, actualDate(1,1) + stepSize/2+1);
exerciceFunction_ = @(actualDate, maturityDate, stepSize)   isbetween(actualDate,maturityDate - stepSize/2, maturityDate + stepSize/2) | isbetween(actualDate,actualDate(1,1) - stepSize/2+1, actualDate(1,1) + stepSize/2+1);

%payoff_ = @(subyacentPrice, actualDate, maturityDate, stepSize) max(subyacentPrice - 30, 0); % Payoff of an european call option with strika at 30.

%barrier_ = @(subyacentPrice) (subyacentPrice >=1140)*3 + (subyacentPrice < 1140)*(-1);
barrier_ = @(subyacentPrice) ones(size(subyacentPrice)).*-1;

subyacentValue_ = 30;

interestRate_ = @(actualDate) ones(size(actualDate)) .* 0.0000001;

valuationDate_ = datetime(2022,01,01);

maturity_ = datetime(2023,01,01);

volatility_ = @(actualDate) ones(size(actualDate)).*0.1;

stepSize_ = 86400; % 1 day
% ACT/365
tic
iter = 1;
price = zeros(1,length(1:iter));
for i = 1:iter
    price(i) = montecarloOptionValuation(exerciceFunction_, @payoff_, barrier_, subyacentValue_, interestRate_, valuationDate_, maturity_, volatility_, stepSize_); % valor real 33.155, any normal 33.1529, any bisiesto: 33.1620 Media ponderada 33.155
end
toc
mean(price)
%         step1   step2  step3  step4
% Path 1
% Path 2
% Path 3

% Payoff european call strike = 30
function pay = payoff_(subyacentPrice, actualDate, maturityDate)
    
    strike = 30;
    %pay = zeros(size(subyacentPrice));
    %pay(:,end) = max(subyacentPrice(:,end) - strike, 0);
    pay = max(subyacentPrice - strike, 0);
end