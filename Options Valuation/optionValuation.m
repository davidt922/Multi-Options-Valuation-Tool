function meanPayoutValue = optionValuation(exerciceFunction, barrierFunction, payoffFunction, randomPathMatrix, stepDatetimeMatrix, interestRateMatrix, maturity, stepSize)
    
    % Apply payoff function for all path steps
    payOffValues = payoffFunction(randomPathMatrix, stepDatetimeMatrix, maturity);
    
    % Modify this payoff with the barrier (if barrier returns always false
    % the payoff will not be modified
    [payOffValuesWithBarrier, presentValueRedemtion] = payoffWithBarrier(randomPathMatrix, barrierFunction, payOffValues, interestRateMatrix, stepSize);
    
    if isequal(payOffValues, payOffValuesWithBarrier)
       %fprintf("No Barrier is executed in any path\n") 
    end
    
    payOffValues = payOffValuesWithBarrier;
    
    exerciceFilter = exerciceFunction(stepDatetimeMatrix, maturity, stepSize);
    
    datetimeExerciceArray = stepDatetimeMatrix(:, exerciceFilter(1,:) == true);
    pathExerciceArray = randomPathMatrix(:, exerciceFilter(1,:) == true);
    actualPayoff = payOffValues(:, exerciceFilter(1,:) == true);
    
    stepSizeInYears = computeStepSizeInYears(stepSize);
    
    %exercice = false(size(actualPayoff));
    
    
    if size(actualPayoff,2) == 1
        discountFactor = exp(sum(-interestRateMatrix.*stepSizeInYears, 2)); %dim = 2 as we want to sum each path
        
        payoutValue = max(payOffValues(:,end).*discountFactor, presentValueRedemtion);
        meanPayoutValue = mean(payoutValue);
    else    
        % Create a vectical vector of Discounted cashflows with the same size as
        % the path matrix
        discountedCashFlow = zeros(size(randomPathMatrix,1),1);
        
        % For each time step and starting from the last one (maturity), this array will hold the cashflows for each
        % path.
        cashflowArray = actualPayoff(:,end);
        
        % interest will hold a matrix, each row of the matrix represents a
        % path and each columns represents a time step. 
        interest = interestRateMatrix(:, stepDatetimeMatrix(1,:)>datetimeExerciceArray(1,1));
        
        % The discounted cashflow is a columns array that have, for each
        % path the discount factor between two time steps
        discountedCashFlow(:) = cashflowArray.* exp(sum(-interest.*stepSizeInYears, 2));
        
        discountedFutureMaxPayoff = zeros(size(randomPathMatrix,1),1);
        
        for i = size(actualPayoff,2):-1:3 % ??2?
            % We are iterating at t(i) and we are calculating for each path 
            % if at t(i-1) the american option should be exercited.
            
            % We find the paths that are in the money at t(i-1)
            inTheMoneyTminusOne = actualPayoff(:,i-1) > 0;
            
            % We calculate the interest between the times t(i-1) and t(i)
            % and its discount factor
            interestBetweenExercices = interestRateMatrix(inTheMoneyTminusOne, stepDatetimeMatrix(1,:)< datetimeExerciceArray(1,i) & stepDatetimeMatrix(1,:)>=datetimeExerciceArray(1,i-1));
            discountFactor = exp(sum(-interestBetweenExercices.*stepSizeInYears, 2));
            
            % Using the actualPayoff(i) (Possible payoff at t(i), we
            % discount in time to calculate this cashflow value at t(i-1) 
            V = actualPayoff(inTheMoneyTminusOne,i).*discountFactor;
            
            % We have to take in account this as if not, V will only
            % represent the present value of the next step, but we will
            % lose the vision of the future steps until maturity.
            V = max(discountedFutureMaxPayoff(inTheMoneyTminusOne),V); 
            
            % As the target is to calculate if we have to execute or not
            % the option at t-1, we will only check the execution for paths
            % that are in the money at t(i-1), as for the rest we will not execute 
            % as we don't have anything to loose and maybe in the future
            % will enter in the money.
            %V = Vtmp(inTheMoneyTminusOne);
            
            % For the same filtered paths, we get the subyacent value at
            % t(i-1) as will be used to estimate the conditional
            % expectation.
            Sfiltered = pathExerciceArray(inTheMoneyTminusOne,i-1);
            
            % The conditional expectation is a method that, using the
            % values from t(i) and t(i-1), it makes a Regression using Laguerre
            % polynomials in order to know (using all the paths) the
            % expectation of increment or decrement of the subyacent value
            % from t(i-1) to t(i).
            
            % For a call, we should exercice the paths that the expected subyacent value
            % increases in the future less than the interest rate, as if we
            % execute, we instantly get the option payoff and we could
            % inmediately invest it at the risk free rate getting more
            % money that if holoding the option.
            
            % Using the Laguerre polynomials, the regression that we will do is the following:
            % Vexp = 1 * A + (1-S(t(i-1))) * B + 1/2*(2 - 4 * S(t(i-1)) + (S(t(i-1)))^2) * C
                        
            A = [ones(size(Sfiltered)), (1-Sfiltered), 1/2.*(2-4.*Sfiltered - Sfiltered.^2)];
            
            % A = [ones(size(Sfiltered)), Sfiltered, Sfiltered.^2];
            
            x = A\V; % Linear regression (Getting the A,B and C regression coeficients) 
            
            % We apply the regression coeficients to the lagrange
            % polynomials to get the expected payoff at t(i-1) for each path if we
            % hold the option to the next time step.
            Vexp = A*x; % Expected cashflow discounted up to today if we hold the option to the next timestep 
            
            % We create a double array with the same size as the number of
            % paths, with 1 if at t(i-1) the option is in the money and
            % with 0 if at t(i-1) the option is out of the money
            % NOTICE: the number of ones that will have the array will be
            % equal to the size of the Vexp array, as for the Vexp array we
            % only use the paths with options at the money
            AllVexp = double(inTheMoneyTminusOne);
            
            % We set to values with 1 in the AllVexp array the expected
            % value of the option if we hold it to the next time step, in
            % this way, the AllVexp array will have 0 in the positions
            % where the option is out of the money at t(i-1) and if it is
            % in the money, the expected value if we hold it for the next
            % time step
            AllVexp(AllVexp>0) = AllVexp(AllVexp>0).*Vexp;
            
            % At this point, we find the price paths that we should
            % exercice the option, this paths will be the ones where the
            % actualPayoff that the american option give at this point in
            % time is bigger than the expected payoff that the option will
            % offer if we hold it to the next execution step.
            
            
            payoffAtTMinusOne = actualPayoff(:,i-1);
            exercice = payoffAtTMinusOne > AllVexp; % true means we should exercice as inmediate exercice is better than predicted cashflow
            
            % For the paths that the option is exerciced, we find its
            % payoff value.
            pay = exercice .* payoffAtTMinusOne;  
            
            
            % From here, what we will do is to find the actual value of
            % this payoff:
            % First, we find the interest values from t(i-1) to t = 0
            interest = interestRateMatrix(:, stepDatetimeMatrix(1,:) < datetimeExerciceArray(1,i-1));
            
            % Then in the discountedCashFlow matrix we set the possible payoff (if exist) in this step from
            % this point to t = 0. This matrix have as rows each path and
            % as columns each time step, for each path and starting from
            % the end for a time step t(i-1) we will set the discounted value of the payoff from this point in time to
            % t=0. 
            discountedCashflowOfPayoff = pay.* exp(sum(-interest.*stepSizeInYears, 2));
            
            discountedCashflowOfPayoff = discountedCashflowOfPayoff(exercice);
            
            discountedCashFlow(exercice) = discountedCashflowOfPayoff;
            
            % We compute the maximum of the payoff of the step (t-1)
            % and the discountedFutureMaxPayoff that are the payoff of the
            % furder steps discounted up to (t-1(
            % and we discount the result to the step (t-2) 
            % to have it Ready for the next iteration
            interestBetweenExercices = interestRateMatrix(:, stepDatetimeMatrix(1,:)< datetimeExerciceArray(1,i-1) & stepDatetimeMatrix(1,:)>=datetimeExerciceArray(1,i-2));
            discountFactor2 = exp(sum(-interestBetweenExercices.*stepSizeInYears, 2));            
            discountedFutureMaxPayoff = max(discountedFutureMaxPayoff, pay).* discountFactor2;
        end 
        % Compute the mean payoff that will be the mean of the payoff for
        % each path 
        payoutValue = max(discountedCashFlow, presentValueRedemtion);
        meanPayoutValue = mean(payoutValue);
    end
    
end


function [barrierpayoff, presentValueRedemtion] = payoffWithBarrier(path, barrier, payoff, interestRateMatrix, stepSize)
    barrierValues = barrier(path);
    %memBarrier = ones(size(payoff,1),1).* -1;
    payoffCoeficient = ones(size(payoff,1),1);
    presentValueRedemtion = zeros(size(payoff,1),1);
    
    stepSizeInYears = years(stepSize);
    
    for i = 1:size(payoff,2)
        % For a specific time step obtain the payoff values for all the path
        stepPayoff = payoff(:,i);
        
        % For a specific time step, obtain the barrier values (-1 if not  or
        % redemption value if the subyacent surpases a certain value)
        stepBarrier = barrierValues(:,i);
        
        % From Valuation Date to Step Interest rate matrix:
        stepInterestRate = interestRateMatrix(:,1:i);
        
        % Apply the payoffCoeficient of the previous path to the stepBarrier as,
        % even if some of the paths have suprased the barrier if they have 
        % been surpased in the past the redemtion for those paths in this step have to be
        % 0.
        stepBarrier = stepBarrier .* payoffCoeficient;

        % For the paths that the barrier is supased, the option becomes
        % desactivated so for that paths the actual payoff will be equal to
        % the redemtion value and the future payoff will be equal to 0 so:
        payoffCoeficient(not(stepBarrier == -1)) = 0;
        
        % Set the values of the payoff or 0 if barrier have surpased in
        % this step or in previous steps
        stepPayoff = stepPayoff .* payoffCoeficient; 
        
        % Set the stepPayoff to the payoff matrix:
        payoff(:,i) =  stepPayoff; 
        
        % For the paths that have surpased the barrier in this step compute
        % the present value of the redemtion given at this point
        surpasedInThisStep = barrierValues(:,i);
        stepInterestRate = stepInterestRate(not(surpasedInThisStep == -1),:);
        presentValueRedemtion(not(surpasedInThisStep == -1)) = surpasedInThisStep(not(surpasedInThisStep == -1)).* exp(sum(-stepInterestRate.*stepSizeInYears, 2));
              
    end  
    barrierpayoff = payoff;
end