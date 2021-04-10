function payoff = payoffEuropeanCallTest(subyacentPrice, maturity) 

strike = 20;
    if maturity == true
        payoff = max(subyacentPrice - strike, 0);
    else
        payoff = -1;
    end
    
end