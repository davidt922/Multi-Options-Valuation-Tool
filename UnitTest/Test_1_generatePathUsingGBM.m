% This test consist to check the correct behavour of the
% generatePathUsingGBM function, we sill check:


%% Test Class Definition
classdef Test_1_generatePathUsingGBM < matlab.unittest.TestCase
    
    methods(TestMethodSetup)
        function setup(testCase)            
            % Install all project functions to get access to it:   
            Installation();
        end
    end
    
    methods (Test)
        % When the volatility = 0, the price path is defined (have no volatility) and have to
        % follow the interest rate.
        % The main purpose of this test is, using a volatility = 0 and a 
        % continiously compounded rate of 5% check if the generated path
        % follows that interest rate
        function testInterestRate(testCase)
            % Import required functions for testing purposes
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.RelativeTolerance;
            
            % Maximum relative tolerance of 1%
            reltol = 0.01;
            
            % Initial subyacent price
            subyacentValue = 100;
            
            % Definition of the interestRate function for an annual continiously compounded interest rate of 5%
            interestRate = @(actualDate) ones(size(actualDate)) .* 0.05;
            
            % Definition of the volatility function for a 0% volatility
            % (and so, get a defined subyacent price path)
            volatility = @(actualDate) ones(size(actualDate)) .* 0; 
            
            % define the step size as 1 minute:
            stepSize = seconds(60);
            
            % Define the valuation date and the maturity to have a 10 year
            % price path
            valuationDate = datetime(2021,01,01);
            maturity = datetime(2031,01,01);
            
            % Generate only one path
            numberOfPaths = 1;
            
            [pricePath, stepDatetimeArray, interestRateArray] = generatePathUsingGBM(subyacentValue, interestRate, volatility, stepSize, valuationDate, maturity, numberOfPaths);

            lastPriceValue = pricePath(1,end);
            expectedValue = subyacentValue*exp(0.05*3652/365); % As we are using ACT/365
            fprintf("lastPriceValue %f, expectedValue %f\n",lastPriceValue, expectedValue)
            testCase.verifyThat(lastPriceValue, IsEqualTo(expectedValue, 'Within', RelativeTolerance(reltol)));
            
            % Check for interest rate = 20%
            interestRate = @(actualDate) ones(size(actualDate)) .* 0.20;
            [pricePath, stepDatetimeArray, interestRateArray] = generatePathUsingGBM(subyacentValue, interestRate, volatility, stepSize, valuationDate, maturity, numberOfPaths);

            lastPriceValue = pricePath(1,end);
            expectedValue = subyacentValue*exp(0.20*3652/365); % As we are using ACT/365
            fprintf("lastPriceValue %f, expectedValue %f\n",lastPriceValue, expectedValue)
            testCase.verifyThat(lastPriceValue, IsEqualTo(expectedValue, 'Within', RelativeTolerance(reltol)));
        end
        
        % This function is used to test if our Geometric Brownian motion
        % path generator generates paths with the input volatility. For
        % that, what we will do is to generate several paths and check, for
        % each path the standar deviation of its logaritmic rentabilities
        % (That will give us the volatility) and compare it with the setted
        % volatility
        function testVolatility(testCase)
            % Import required functions for testing purposes
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.RelativeTolerance;
            
            % Maximum relative tolerance of 1%
            reltol = 0.01;
            
             % Initial subyacent price
            subyacentValue = 100;
            
            % Definition of the interestRate function for an annual continiously compounded interest rate of 0%
            interestRate = @(actualDate) ones(size(actualDate)) .* 0.5;
            
            % Definition of the volatility function for a 20% volatility
            volatility = @(actualDate) ones(size(actualDate)) .* 0.20; 
            
            % define the step size as 1 hour:
            stepSize = hours(1);
            
            anualizationCoefficient = years(1)/stepSize; 
            
            % Define the valuation date and the maturity to have a 10 year
            % price path
            valuationDate = datetime(2021,01,01);
            maturity = datetime(2031,01,01);
            
            % Generate 500 path to make an average of the volatility of all
            % the paths
            numberOfPaths = 500;
            
            [pricePath, stepDatetimeArray, interestRateArray] = generatePathUsingGBM(subyacentValue, interestRate, volatility, stepSize, valuationDate, maturity, numberOfPaths);

            logRentEachPath = log(pricePath(:,2:end)./pricePath(:,1:end-1));
            
            % Standard deviation along 2º dimension
            pathsVolatility = std(logRentEachPath, 0, 2);
            % As the step size is 1 day, the volatility is daily so we have
            % to annualized:
            pathsVolatility = pathsVolatility .*sqrt(anualizationCoefficient);
            
            meanVolatility = mean(pathsVolatility);
            
            fprintf("meanVolatility %f, volatility %f\n",meanVolatility, 0.2)
            testCase.verifyThat(meanVolatility, IsEqualTo(0.2, 'Within', RelativeTolerance(reltol)));
            
            
            % Second test with 10% volatility:
            volatility = @(actualDate) ones(size(actualDate)) .* 0.10; 
            
            [pricePath, stepDatetimeArray, interestRateArray] = generatePathUsingGBM(subyacentValue, interestRate, volatility, stepSize, valuationDate, maturity, numberOfPaths);

            logRentEachPath = log(pricePath(:,2:end)./pricePath(:,1:end-1));
            
            % Standard deviation along 2º dimension
            pathsVolatility = std(logRentEachPath, 0, 2);
            % As the step size is 1 day, the volatility is daily so we have
            % to annualized:
            pathsVolatility = pathsVolatility .*sqrt(anualizationCoefficient);
            
            meanVolatility = mean(pathsVolatility);
            
            fprintf("meanVolatility %f, volatility %f\n",meanVolatility, 0.1)
            testCase.verifyThat(meanVolatility, IsEqualTo(0.1, 'Within', RelativeTolerance(reltol)));   
        end
        
        % This unit test is used to check if the time step setted as input
        % is the timestep used
        function testTimeStep(testCase)
             % Import required functions for testing purposes
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.RelativeTolerance;
            
            % Maximum relative tolerance of 1%
            reltol = 0.01;
            
            % Initial subyacent price
            subyacentValue = 100;
            
            % Definition of the interestRate function for an annual continiously compounded interest rate of 0%
            interestRate = @(actualDate) ones(size(actualDate)) .* 0;
            
            % Definition of the volatility function for a 20% volatility
            volatility = @(actualDate) ones(size(actualDate)) .* 0; 
            
            % define the step size as 1 hour:
            stepSize = hours(1);
            
            %anualizationCoefficient = years(1)/stepSize;
            
            % Define the valuation date and the maturity to have a 10 year
            % price path
            valuationDate = datetime(2021,01,01);
            maturity = datetime(2031,01,01);
            
            % Generate 1 path to make an average of the volatility of all
            % the paths
            numberOfPaths = 1;
            
            [pricePath, stepDatetimeArray, interestRateArray] = generatePathUsingGBM(subyacentValue, interestRate, volatility, stepSize, valuationDate, maturity, numberOfPaths);
            
            fprintf("Valuation date %s, first step date %s\n", stepDatetimeArray(1), stepDatetimeArray(2));
            fprintf("Real time step: %s\n", durationString(stepSize));
            fprintf("Time between steps: %s\n", durationString(stepDatetimeArray(2)- stepDatetimeArray(1)));
            
            % The time between the valuation date and the first step
            % should be equal to 1 step size:
            
            testCase.verifyThat(stepDatetimeArray(2) -  stepDatetimeArray(1), IsEqualTo(stepSize, 'Within', RelativeTolerance(reltol)));   
            %---------------------------------------
            % Now changing the time step to 1 year:
            %---------------------------------------
            stepSize = days(1);
            
            [pricePath, stepDatetimeArray, interestRateArray] = generatePathUsingGBM(subyacentValue, interestRate, volatility, stepSize, valuationDate, maturity, numberOfPaths);
            
            fprintf("Valuation date %s, first step date %s\n", stepDatetimeArray(1), stepDatetimeArray(2));
            fprintf("Real time step: %s\n", durationString(stepSize));
            fprintf("Time between steps: %s\n", durationString(stepDatetimeArray(2)- stepDatetimeArray(1)));
            
            % The time between the valuation date and the first step
            % should be equal to 1 step size:
            
            testCase.verifyThat(stepDatetimeArray(2) -  stepDatetimeArray(1), IsEqualTo(stepSize, 'Within', RelativeTolerance(reltol)));   
            
        end
        
    end
    
end