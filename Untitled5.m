payoffCoeficient = [1,1,0,1]';

stepPayoff = [1,2,3,4]';

% For a specific time step, obtain the barrier values (-1 if not  or
% redemption value if the subyacent surpases a certain value)
stepBarrier = [-1,3,4,-1]';

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

% For the paths that have surpased the barrier in this step, set
% the redemtion value.
stepPayoff(not(stepBarrier == -1)) = stepBarrier(not(stepBarrier == -1));

stepPayoff