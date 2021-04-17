function stepSizeInYears = computeStepSizeInYears(stepSize) % To use ACT/365
    stepSizeInYears = years(stepSize).*365.2425./365;
end