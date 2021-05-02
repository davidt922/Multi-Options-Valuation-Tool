Installation();

format long g


% Initial subyacent price
S0 = 100;

% Definition of the interestRate function for an annual continiously compounded interest rate of 5%
interestRate = @(actualDate) ones(size(actualDate)) .* 0;

% Definition of the volatility function for a 0% volatility
% (and so, get a defined subyacent price path)
volatility = @(actualDate) ones(size(actualDate)) .* 5; 

% define the step size as 1 minute:
stepSize = days(1);

% Define the valuation date and the maturity to have a 10 year
% price path
valuationDate = datetime(2021,01,01);
maturity = datetime(2021,01,03);

% Generate only one path
numberOfPaths = 1000; % 4

[pricePath, stepDatetimeArray, interestRateArray] = generatePathUsingWienerProcess(S0, interestRate, volatility, stepSize, valuationDate, maturity, numberOfPaths);


% Call with Strike is 100
Strike = 100;

actualPath = pricePath(:,end);

nextPath = pricePath(:,end-1);

% Is a call strike 100 so the paths in the money are:
filter = actualPath > Strike;

% The actual and next paths to make regression are:
actualPath = actualPath(filter);

fprintf("MIN ACTUAL PATH: ")
minValue = min(actualPath);

fprintf("MAX ACTUAL PATH: ")
maxValue = max(actualPath);

nextPath = nextPath(filter);

V = max(nextPath - Strike, 0); % Payout of the next path

% As interest rate = 0, discount factor = 1 so:
%present value of the nextPath = nextPath.


% For matlab, if we have a system of linear equations Ax=b and A is a
% rectangular mxn matrix (m = rows, n=columns) with m>n, then A\b returns
% the least-square solution of the system of linear equations.

%fprintf("S values: ")
%display(actualPath);


A = [ones(size(actualPath)), actualPath, actualPath.^2];


x = A\V;

%fprintf("Coeficient values using the formula of the book: ")
%display(x);

%fprintf("Expected present value of future payoffs using the formula of the book: \n")
%display(A*x);


plotRange = minValue:0.1:maxValue;
plotRange = plotRange(:);

Ap = [ones(size(plotRange)), plotRange, plotRange.^2];

yPlotRange = Ap*x;

figure(1);
plot(plotRange, yPlotRange);


X1 = actualPath./S0;

A = [ones(size(X1)), (1-X1), 1/2.*(2-4.*X1 - X1.^2)];

x = A\V; % Linear regression (Getting the A,B and C regression coeficients) 

%fprintf("Coeficient values using the formula of the paper: ")
%display(x);


%fprintf("Expected present value of future payoffs using the formula of the paper: \n")
%display(A*x);

plotRangeWithStrike = plotRange./Strike;

Ap = [ones(size(plotRangeWithStrike)), (1 - plotRangeWithStrike), 1/2.*(2-4.*plotRangeWithStrike - plotRangeWithStrike.^2)];

yPlotRange = Ap*x;

figure(2);
plot(plotRange, yPlotRange);
