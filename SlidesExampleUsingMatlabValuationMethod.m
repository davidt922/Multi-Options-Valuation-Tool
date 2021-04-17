StartDate  = 'Jan-1-2016';
EndDate = 'Jan-1-2017';
Basis = 1;
Compounding = -1;
Rates = 0.02;

RateSpec = intenvset('ValuationDate',StartDate,'StartDate',StartDate,'EndDate',EndDate, ...
'Rates',Rates,'Basis',Basis,'Compounding',Compounding);

AssetPrice = 100;
Volatility = 0.3;

StockSpec = stockspec(Volatility,AssetPrice);

OptSpec = 'put';
Strike = 100;
Settle = 'Jan-1-2016';
Maturity = 'Jan-1-2017';

OutSpec = {'price';'delta';'theta'};

[Price,Delta,Theta] = optstocksensbybaw(RateSpec,StockSpec,Settle,Maturity,OptSpec,Strike,'OutSpec',OutSpec)