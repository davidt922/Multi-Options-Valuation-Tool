function optionPrice = montecarloOptionValuationAutoPathSize(exerciceFunction, payoff, barrier, subyacentValue, interestRate, valuationDate, maturity, volatility, stepSize, numberOfPaths)

    if nargin ~= 10
        fprintf("Starting Autopath finding\n")
        numberOfPaths = 20000;
    end

    if numberOfPaths < 0
        numberOfPaths = 20000;
        stepSize = stepSize.*2;
        optionPrice = montecarloOptionValuationAutoPathSize(exerciceFunction, payoff, barrier, subyacentValue, interestRate, valuationDate, maturity, volatility, stepSize, numberOfPaths);
    else
        try
            fprintf("Trying option valuation with %d paths\n", numberOfPaths)
            optionPrice = montecarloOptionValuation(exerciceFunction, payoff, barrier, subyacentValue, interestRate, valuationDate, maturity, volatility, stepSize, numberOfPaths);
        catch e
            fprintf(2,getReport(e))
            numberOfPaths = numberOfPaths - 100;
            optionPrice = montecarloOptionValuationAutoPathSize(exerciceFunction, payoff, barrier, subyacentValue, interestRate, valuationDate, maturity, volatility, stepSize, numberOfPaths);
        end

    end

end