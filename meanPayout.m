function [meanPayoff, times] = meanPayout(exerciceFunction, barrier, payoff, path, stepDatetimeArray, interestRateArray, maturity, stepSize)
    % Apply payoff function for all path steps
    payOffValues = payoff(path, stepDatetimeArray, maturity);
    
    % Modify this payoff with the barrier (if barrier returns always false
    % the payoff will not be modified
    payOffValuesWithBarrier = payoffWithBarrier(path, barrier, payOffValues);
    
    if isequal(payOffValues, payOffValuesWithBarrier)
       %fprintf("No Barrier is executed in any path\n") 
    end
    
    payOffValues = payOffValuesWithBarrier;
    
    exerciceFilter = exerciceFunction(stepDatetimeArray, maturity, stepSize);
    
    datetimeExerciceArray = stepDatetimeArray(:, exerciceFilter(1,:) == true);
    pathExerciceArray = path(:, exerciceFilter(1,:) == true);
    possiblePayoff = payOffValues(:, exerciceFilter(1,:) == true);
    
    stepSizeInYears = computeStepSizeInYears(stepSize);
    
    times = 0;
    
    exercice = false(size(possiblePayoff));
    
    discountedCashFlow = zeros(size(path));
    
    if size(possiblePayoff,2) == 1
        discountFactor = exp(sum(-interestRateArray.*stepSizeInYears, 2)); %dim = 2 as we want to sum each path
        meanPayoff = mean(payOffValues(:,end).*discountFactor);
    else    
        % In theory it should be 2
        payoffArray = possiblePayoff(:,end);
        
        interest = interestRateArray(:, stepDatetimeArray(1,:)>datetimeExerciceArray(1,1));
        discountedCashFlow(:,end) = payoffArray.* exp(sum(-interest.*stepSizeInYears, 2));
        
        %
        for i = size(possiblePayoff,2):-1:3
            % We are iterating at t(i) and we are calculating for each path 
            % if at t(i-1) the american option should be exercited.
            
            % We find the paths that are in the money at t(i-1)
            inTheMoneyTminusOne = possiblePayoff(:,i-1) > 0;
            % for these paths assume the approximate relationship 
            % V = a + bS+ cS^2
            interestBetweenExercices = interestRateArray(:, stepDatetimeArray(1,:)< datetimeExerciceArray(1,i) & stepDatetimeArray(1,:)>=datetimeExerciceArray(1,i-1));
            discountFactor = exp(sum(-interestBetweenExercices.*stepSizeInYears, 2));
            Vtmp = payoffArray.*discountFactor;
            
            V = Vtmp(inTheMoneyTminusOne);
            
            Sfiltered = pathExerciceArray(inTheMoneyTminusOne,i-1);
            
            A = [ones(size(Sfiltered)), Sfiltered, Sfiltered.^2];
            
            x = A\V;
            
            Vexp = A*x;
            AllVexp = double(inTheMoneyTminusOne);
            
            AllVexp(AllVexp>0) = AllVexp(AllVexp>0).*Vexp;
            exercice(:,i) = possiblePayoff(:,i-1) > AllVexp; % true means we should exercice
            
            pay = exercice(:,i) .* possiblePayoff(:,i-1);  
        
            % Interest values from t-1 to t = 0
            interest = interestRateArray(:, stepDatetimeArray(1,:) < datetimeExerciceArray(1,i-1));
            % discounting the possible payoff if exist in this step from
            % this point to t = 0
            discountedCashFlow(:,i-1) = pay.* exp(sum(-interest.*stepSizeInYears, 2));
            
            % If it is executed at t it cannot be executed at t+1 and beong
            discountedCashFlow(discountedCashFlow(:,i-1)>0,i:end) = 0;
                        
            payoffArray = pay;

        end      
        meanPayoff = sum(discountedCashFlow(discountedCashFlow>0))./size(path,1);
    end
    
end


function barrierpayoff = payoffWithBarrier(path, barrier, payoff)
    barrierValues = barrier(path);
    memBarrier = ones(size(payoff,1),1).* -1;
    
    for i = 1:size(payoff,2)
        stepPayoff = payoff(:,i);
        stepBarrier = barrierValues(:,i);
        actualBarrier = max(memBarrier, stepBarrier);
        stepPayoff = stepPayoff .* (actualBarrier < 0) + (actualBarrier >= 0) .* actualBarrier; 
        payoff(:,i) = stepPayoff;
    end  
    barrierpayoff = payoff;
end