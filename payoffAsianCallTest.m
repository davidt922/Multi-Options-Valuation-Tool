function a = payoffAsianCallTest(subyacentPrice, maturity) 
    persistent accumulatedValue
    persistent numberOfValues
    
    strike = 20;
    
     if isempty(accumulatedValue)
          accumulatedValue = 0;
     end
     
     if isempty(numberOfValues)
          numberOfValues = 0;
     end
     
     accumulatedValue = accumulatedValue +  subyacentPrice;
     numberOfValues = numberOfValues + 1;

    if maturity == true
        meanSubyacent = accumulatedValue./numberOfValues;
        payoff = max(meanSubyacent - strike, 0);
    else
        payoff = -1;
    end
end