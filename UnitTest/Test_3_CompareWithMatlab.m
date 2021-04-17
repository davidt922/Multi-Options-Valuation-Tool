% This test consist to check the correct behavour of the
% generatePathUsingGBM function, we sill check:


%% Test Class Definition
classdef Test_3_CompareWithMatlab < matlab.unittest.TestCase

    methods(TestMethodSetup)
        function setup(testCase)
            % Install all project functions to get access to it:
            Installation();
        end
    end

    methods (Test)
        % We are using a montecarlo method to valuate options that consist
        % of generate several subyacent price paths. Check, for each path,
        % the payout that the option will give and finally find the mean of
        % all the discounted payouts to find the actual value of the option.

        % In this tests we will test the montecarloOptionValuation that joins the
        % generatePathUsingGBM and the optionValuation functions to valuate
        % any type of options.
        
        % The first test consist of valuating a Call European option with the following definition:
        % Subyacent value of 100, Strike of 100, maturity 1 year,
        % Volatility 20%, interest rate 0%
        function testEuropeanOptionValuation(testCase)
            % Import required functions for testing purposes
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.RelativeTolerance;

            % Maximum relative tolerance of 3%
            reltol = 0.03;
            
            % Define the valuation date and the maturity (from
            % stepDatetimeArray)
            valuationDate = datetime(2021,1,1);
            maturity = datetime(2027,1,1);
            
            
            subyacentValue = 100;
            strikeValue = 100;
            interestRate = 0;
            time = years(maturity-valuationDate);
            volatility = 0.2;
            
            % European Option that can only be exercited at maturity so:
            exerciceFunction_ = @(actualDate, maturityDate, stepSize)  zeros(1,size(actualDate,2))+[zeros(1,size(actualDate,2)-1),1];

            % This option don't have a barrier so:
            barrier_ = @(subyacentPrice) ones(size(subyacentPrice)).*-1;


            % Definition of the payoff of a Call option
            payoff_ = @(subyacentPrice, actualDate, maturityDate)  max(subyacentPrice - strikeValue, 0);


            % Definition of the interest rate function that, for each
            % date and path gives the annual continiously compounded
            % interest rate. In our case the interest rate is 0% so:
            interestRate_ = @(actualDate) ones(size(actualDate)) .* interestRate;

            % Define the step size as 1 day, this will be used to generate
            % the paths
            stepSize = days(1);
            %numberOfSteps = 40000;
            %stepSize = (maturity - valuationDate)/numberOfSteps;
            
            % Define the number of paths to use:
            numberOfPaths = 500;
            
            % Volatility defined as a function. We use the stocastic
            % diferential equation instead of the exact solution of the
            % equation to give to the user the possibility to define non
            % constant interest rates and volatilities (slides-Monte.pdf
            % page 15).
            
            % In our case for this example we have a constant 20% volatility
            volatility_ = @(actualDate) ones(size(actualDate)).*volatility;


            optionValue = montecarloOptionValuationAutoPathSize(exerciceFunction_, payoff_, barrier_, subyacentValue, interestRate_, valuationDate, maturity, volatility_, stepSize, numberOfPaths);
            fprintf("Valuated European Option Value %f\n", optionValue)
            
            %optionValue = montecarloOptionValuationAutoPaths(exerciceFunction_, payoff_, barrier_, subyacentValue, interestRate_, valuationDate, maturity, volatility_, stepSize);
            %fprintf("Valuated European Option Value %f\n", optionValue)
            
            [Call,Put] = blsprice(subyacentValue, strikeValue, interestRate, time,volatility);

            fprintf("Black-Scholes European Option Value %f\n", Call)
            fprintf("Valuated European Option Value %f\n", optionValue)
            fprintf("Error of our Montecarlo Method %f %%\n\n", abs(Call - optionValue)./Call.*100)
            testCase.verifyThat(optionValue, IsEqualTo(Call, 'Within', RelativeTolerance(reltol)));
            
        end
        
        function testAmericanOptionValuation(testCase)
            % Import required functions for testing purposes
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.RelativeTolerance;

            % Maximum relative tolerance of 3%
            reltol = 0.03;
            
            % Define the valuation date and the maturity (from
            % stepDatetimeArray)
            valuationDate = datetime(2021,1,1);
            maturity = datetime(2027,1,1);
            
            
            subyacentValue = 100;
            strikeValue = 100;
            interestRate = 0;
            %time = years(maturity-valuationDate);
            volatility = 0.2;
            
            % European Option that can only be exercited at maturity so:
            exerciceFunction_ = @(actualDate, maturityDate, stepSize)  true(size(actualDate));

            % This option don't have a barrier so:
            barrier_ = @(subyacentPrice) ones(size(subyacentPrice)).*-1;


            % Definition of the payoff of a Call option
            payoff_ = @(subyacentPrice, actualDate, maturityDate)  max(subyacentPrice - strikeValue, 0);


            % Definition of the interest rate function that, for each
            % date and path gives the annual continiously compounded
            % interest rate. In our case the interest rate is 0% so:
            interestRate_ = @(actualDate) ones(size(actualDate)) .* interestRate;

            % Define the step size as 1 day, this will be used to generate
            % the paths
            stepSize = days(1);
            %numberOfSteps = 40000;
            %stepSize = (maturity - valuationDate)/numberOfSteps;
            
            % Define the number of paths to use:
            numberOfPaths = 500;
            
            % Volatility defined as a function. We use the stocastic
            % diferential equation instead of the exact solution of the
            % equation to give to the user the possibility to define non
            % constant interest rates and volatilities (slides-Monte.pdf
            % page 15).
            
            % In our case for this example we have a constant 20% volatility
            volatility_ = @(actualDate) ones(size(actualDate)).*volatility;


            optionValue = montecarloOptionValuationAutoPathSize(exerciceFunction_, payoff_, barrier_, subyacentValue, interestRate_, valuationDate, maturity, volatility_, stepSize, numberOfPaths);
            fprintf("Valuated American Option Value %f\n", optionValue)
            
            RateSpec = intenvset('ValuationDate',valuationDate,'StartDate',valuationDate,'EndDate',maturity, ...
                'Rates',interestRate,'Basis',3,'Compounding',-1); % Basis: Act/365 continiously compounded
            
            StockSpec = stockspec(volatility,subyacentValue);
            

            Call = optstocksensbybaw(RateSpec,StockSpec,valuationDate,maturity,'call',strikeValue);

            fprintf("Matlab American Option using Barone-Adesi and Whaley option pricing model Value %f\n", Call)
            fprintf("Valuated American Option Value %f\n", optionValue)
            fprintf("Error of our Montecarlo Method %f %%\n\n", abs(Call - optionValue)./Call.*100)
            testCase.verifyThat(optionValue, IsEqualTo(Call, 'Within', RelativeTolerance(reltol)));            
            
        end
        
        
        % Before valuating an Asian Option, as it payoff function is
        % complex we will Firstly check if it has a correct behavour.
        %
        % The payoff function is inlined in this test, if wanted to check 
        % a detailed description of how it works check asianPayoff.m function.  
        function testCheckAsianPayoff(testCase)
            % Import required functions for testing purposes
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.RelativeTolerance;

            % Maximum relative tolerance of 3%
            reltol = 0.03;
            
            % We set the strike value at 100
            strikeValue = 100;
            
            % First create the 3 arrays that the function have as an input:
            
            % Datetime Array:
            dateTimeArray = datetime({});
            baseDatetime = datetime(2021,1,1);
            % Time step will be 4 hours, there will be 10 steps and we will create 4 paths so:
            for i = 1:11
                dateTimeArray([1:4],i) = baseDatetime + hours(6.*(i-1));
            end
            % As What we want with the asian option is to use as the
            % average the last quoting value of the subyacent price, this
            % will be the 5º and the 10º column.
            
            % Starting price of the subyacent will be 100
            % Now we will set random variables to all the matrix of subyacent prices
            % except for the 4º and the 8º columns as this columns are the ones that
            % have to be used for the asian function for the averaging.
            
            subyacentPrice = rand(4,11).*120;
            subyacentPrice(:,1) = 100;
            subyacentPrice(:,4) = [120;100;50;75];
            subyacentPrice(:,8) = [110;130;150;25];
            
            % So the averaging result of the function should be: 
            finalResult = mean([subyacentPrice(:,4), subyacentPrice(:,8)],2);
            
            % So the payoff for a call is:
            finalResult = max(finalResult - strikeValue,0);
            display(finalResult)
            
            asianPayoff_ = @(subyacentPrice, actualDate, maturityDate)...
                max(... % Asian Payoff will be the maximum of
                [zeros(size(subyacentPrice) - [0,1]), ones(size(subyacentPrice,1),1)].*... % As it can only be executet at maturity we will only set the payoff value for the last step.
                (subyacentPrice*[abs(actualDate(1,2:end).Day - actualDate(1,1:end-1).Day) > 0, false]')./sum(abs(actualDate(1,2:end).Day - actualDate(1,1:end-1).Day) > 0)... % This last value will be the sum of the last quotation values of each day, so we check a day change using the datetime array and for those changes we do the average.
                - strikeValue, 0);% For those values we compute the asian payoff (Maximum between the computet values minus the strike and 0.
            
            payoff = asianPayoff_(subyacentPrice, dateTimeArray, dateTimeArray(:,end));
            
            finalPayoff = payoff(:,end);
            
            
            testCase.verifyThat(finalPayoff, IsEqualTo(finalResult, 'Within', RelativeTolerance(reltol)));
            
            
            % Change las quoting value and perform a second check
            subyacentPrice(:,4) = [111;157;63;181];
            subyacentPrice(:,8) = [113;127;102;27];
            
            % So the averaging result of the function should be: 
            finalResult = mean([subyacentPrice(:,4), subyacentPrice(:,8)],2);
            % And the payoff for a call is:
            finalResult = max(finalResult - strikeValue,0);
            
            payoff = asianPayoff_(subyacentPrice, dateTimeArray, dateTimeArray(:,end));
            
            finalPayoff = payoff(:,end);
            
            testCase.verifyThat(finalPayoff, IsEqualTo(finalResult, 'Within', RelativeTolerance(reltol)));
            
        end
        
        % This will be the last test case, we will valuate an Asian Option
        % with an averaging period of 1 month, that is, the final payment
        % will be the average value of the daily settlement from the first 
        % till the last day of month.
        % In our example we will valuate a Call Asian Option with a Strip date 
        % (Date that starts the averaging) 01-02-2021 (This will be the same date
        % that we will valuate the option) and maturity date
        % 01-03-2021. The Strike of the Option will be 100 and the Subyacent will
        % have a volatility of 20% and its Spot Value will also be 100.
        % We will use, for this case, a continious compounded interest rate of 5%
        %
        % We will check the result with the value given by the Turnbull-Wakeman
        % Method.
        function testAsianOptionValuation(testCase)
            % Import required functions for testing purposes
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.RelativeTolerance;
            
            % Maximum relative tolerance of 3%
            reltol = 0.03;
            
            % Option Definition
            stripDate = datetime(2021,2,1);
            maturityDate = datetime(2021,3,1);
            valuationDate = stripDate;
            volatility = 0.2;
            subyacentValue = 100;
            interestRate = 0.05;
            strikeValue = 100;
            
            % Define the step size
            stepSize = minutes(1);
            
            % Define the number of paths to use:
            numberOfPaths = 500;
            
            % In our case for this example we have a constant 20% volatility
            volatility_ = @(actualDate) ones(size(actualDate)).*volatility;
            
            % Definition of the interest rate function that, for each
            % date and path gives the annual continiously compounded
            % interest rate. In our case the interest rate is 0% so:
            interestRate_ = @(actualDate) ones(size(actualDate)) .* interestRate;
            
            % This Asian Style Option can only be exercised at Maturity 
            exerciceFunction_ = @(actualDate, maturityDate, stepSize)  zeros(1,size(actualDate,2))+[zeros(1,size(actualDate,2)-1),1];
            
            % This option don't have a barrier so:
            barrier_ = @(subyacentPrice) ones(size(subyacentPrice)).*-1;
            
            % Definition of the payoff of an asianCallOption.
            asianPayoff_ = @(subyacentPrice, actualDate, maturityDate)...
                max(... % Asian Payoff will be the maximum of
                [zeros(size(subyacentPrice) - [0,1]), ones(size(subyacentPrice,1),1)].*... % As it can only be executet at maturity we will only set the payoff value for the last step.
                (subyacentPrice*[abs(actualDate(1,2:end).Day - actualDate(1,1:end-1).Day) > 0, false]')./sum(abs(actualDate(1,2:end).Day - actualDate(1,1:end-1).Day) > 0)... % This last value will be the sum of the last quotation values of each day, so we check a day change using the datetime array and for those changes we do the average.
                - strikeValue, 0);% For those values we compute the asian payoff (Maximum between the computet values minus the strike and 0.
            
            asianPayoff_ = @(subyacentPrice, actualDate, maturityDate)...
            max(cumsum(subyacentPrice,2)./(1:numel(subyacentPrice(1,:))) - strikeValue, 0);
            
            optionValue = montecarloOptionValuationAutoPathSize(exerciceFunction_, asianPayoff_, barrier_, subyacentValue, interestRate_, valuationDate, maturityDate, volatility_, stepSize, numberOfPaths);
            fprintf("Valuated Asian Option Value %f\n", optionValue);

            
            % Pricing the Asian Option using Turnbull-Wakeman approximation (Method Provided by Matlab) 
            Compounding = -1;
            Basis = 1;
            OptSpec = 'call';
            StockSpec = stockspec(volatility, subyacentValue);
            RateSpec = intenvset('ValuationDate', valuationDate, 'StartDates', valuationDate, ...
                'EndDates', maturityDate, 'Rates', interestRate, 'Compounding', ...
                Compounding, 'Basis', Basis);
            PriceTW = asianbytw(RateSpec, StockSpec, OptSpec, strikeValue, stripDate, maturityDate);
            fprintf("Valuated Asian Option using Turnbull-Wakeman approximation %f\n", PriceTW);
            fprintf("Error of our Montecarlo Method %f %%\n\n", abs(PriceTW - optionValue)./PriceTW.*100)
            
            
        end

    end

end
