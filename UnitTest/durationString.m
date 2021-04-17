function outputValue = durationString(durationVariable)
year = 0;
day = 0;
hour = 0;
minute = 0;
second = 0;
    while durationVariable > 0
        if (years(durationVariable) >= 1)
            durationVariable = durationVariable - years(1);
            year = year + 1;
        elseif (days(durationVariable) >= 1)
            durationVariable = durationVariable - days(1);
            day = day + 1;
        elseif (hours(durationVariable) >= 1)
            durationVariable = durationVariable - hours(1);
            hour = hour + 1;
        elseif (minutes(durationVariable) >= 1)
            durationVariable = durationVariable - minutes(1);
            minute = minute + 1;
        else 
            durationVariable = durationVariable - seconds(1);
            second = second + 1;
        end
    end
outputValue = "";
    if year > 0
        outputValue = outputValue +year+" years.";
    end
    if day > 0
        outputValue = outputValue +day+" days.";
    end
    if hour > 0
        outputValue = outputValue +hour+" hours.";
    end
    if minute > 0
        outputValue = outputValue +minute+" minutes.";
    end
    if second > 0
        outputValue = outputValue +second+" seconds.";
    end
    outputValue = char(outputValue);
    outputValue = outputValue(1:end-1);
    lastPos = strfind(outputValue, '.');
    if (~isempty(lastPos))
        outputValue(lastPos(end)) = ',';
        outputValue = string(outputValue);
        outputValue = strrep(outputValue,","," and ");
        outputValue = strrep(outputValue,".",", ");    
    else
        outputValue = string(outputValue);
    end
    
end