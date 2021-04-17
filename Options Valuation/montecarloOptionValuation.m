function optionPrice = montecarloOptionValuation(exerciceFunction, payoff, barrier, subyacentValue, interestRate, valuationDate, maturity, volatility, stepSize, numberOfPaths)
% ---------------------------------------------------------------------------
% To compute the value of an option we need, the type of option (european, american) 
% subyacent price, the interest rate, the payoff (this includes the strike), the time to maturity and the volatility.
%
% The target of this function is to give the possibility to valuate a big
% range of options using a montecarlo method. For that we have defined the
% following input parameters:
% 
% - exerciceFunction: a function that returns true at the point in time the
% option could be exerciced. It have 3 inputs, 2 datetime inputs the actualDate and the maturity date
% and the step size
%
% - payoff: is a function that defines the payoff. If it is an asian option
% function is the responsable to compute the average of the subyacent. The
% function have 3 inputs: array of subyacent price, array of dates for the subyacent price and maturity. (Strike if
% exist have to be defined inside the function)
%
% For European style options have to return -1 for all steps prior to
% maturity and the payoff value at maturity.
%
% For American style options have to return at least the possible payoff value at
% each point in time it could be exercised
%
% For asian options the  actualDate will be used for different reasons:
%
% - If the averaging is all busines days between 2 dates we need the
% datetime value
%
% - If the averaging is just a subyacent value in some points in time.
%
% Notice: The function will be executed for each step of the montecarlo method 
%
% - barrier: is a function that gives the possibility to add a barrier, it
% have as input the subyacentPrice, and as output 1 value returning -1 if the barrier has not been crossed 
% or a numeric value (the rebate value) if the barrier is crossed 
% if not and the rebate value (if there is no rebate 0)
%
% - subyacentValue: value of the subyacent at t = 0
%
% - interestRate: function that represents the annual continiously
% compounded risk free rate. as input it have an actual datetime
% representing the position in time of the valuation
%
% - valuationDate: datetime object containing the valuation date
%
% - maturity: datetime object containing the maturity date
%
% - volatility: volatility function that gives a volatility value. It have
% one input a datetime with the actualDate of the step and it has too
% retun the unitary volatility (if volatility is 20% it has to return 0.2)
%
% - stepSize: numbrer of seconds used for each step in the random path
% generated for montecarlo. or a duration object
%
% -numberOfPaths: Optional value to set the number of paths to use
%
%---------------------------------------------------------------------------
sumOfMeans = 0;
numOfMeans = 0;
if class(stepSize)~= "duration"
    stepSize = seconds(stepSize);
end

if nargin ~= 10
    numberOfPaths = 1000; % Default number of paths = 1000
end

beforeMeanOfMeans = 0;
    while true
        %a = tic;
        [path, stepDatetimeArray, interestRateArray] = generatePathUsingGBM(subyacentValue, interestRate, volatility, stepSize, valuationDate, maturity, numberOfPaths);
        %fprintf("Path generation time: ")
        %toc(a)
        %b = tic;
        optionPrice = optionValuation(exerciceFunction, barrier, payoff, path, stepDatetimeArray, interestRateArray, maturity, stepSize);
        %fprintf("\nValuation time: ")
        %toc(b);
        numOfMeans = numOfMeans + 1;
        sumOfMeans = sumOfMeans + optionPrice;
        
        meanOfMeans = sumOfMeans ./ numOfMeans;
        fprintf("Option mean value: %f \n", meanOfMeans);
        fprintf("Option value: %f \n", optionPrice);
        if not(numOfMeans == 1)
            %fprintf("diff: %f\n",abs(meanOfMeans - beforeMeanOfMeans))
            if (abs(meanOfMeans - beforeMeanOfMeans) < 0.0001)
               break; 
            end
            beforeMeanOfMeans = meanOfMeans;
        end
    end
    optionPrice = meanOfMeans;
end

