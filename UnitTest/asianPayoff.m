% For Unit test, the asian option Will do the average from 01/02/2021 till
% 01/03/2021 (Maturity).
%
% Remember, the program is desiged so each input variable is a matrix with
% the following structure:
%
%         step1   step2  step3  step4 ... Last_Step
% Path 1
% Path 2
% Path 3
% ...
% Last_Path
function meanValue = asianPayoff(subyacentPrice, actualDate, maturityDate)
    %lastQuotingValue = actualDate(:,2:end).Day - actualDate(:,1:end-1).Day > 0;
    %lastQuotingValue = [lastQuotingValue, false(size(lastQuotingValue,1),1)];
    %meanValue = (subyacentPrice*lastQuotingValue(1,:)')./sum(lastQuotingValue(1,:));
    
    %meanValue =(subyacentPrice*[actualDate(1,2:end).Day - actualDate(1,1:end-1).Day > 0, false]')./sum(actualDate(1,2:end).Day - actualDate(1,1:end-1).Day > 0);
    %meanValue = [zeros(size(subyacentPrice) - [0,1]), ones(size(subyacentPrice,1),1)].*meanValue;
    
    % 
    meanValue = [zeros(size(subyacentPrice) - [0,1]), ones(size(subyacentPrice,1),1)].*(subyacentPrice*[actualDate(1,2:end).Day - actualDate(1,1:end-1).Day > 0, false]')./sum(actualDate(1,2:end).Day - actualDate(1,1:end-1).Day > 0);
end