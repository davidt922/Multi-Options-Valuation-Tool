StartDate  = 'Jan-1-2016';
EndDate = 'jan-1-2018';
Basis = 1;
Compounding = -1;
Rates = 0.00001;

RateSpec = intenvset('ValuationDate',StartDate,'StartDate',StartDate,'EndDate',EndDate, ...
'Rates',Rates,'Basis',Basis,'Compounding',Compounding);

AssetPrice = 125;
Volatility = 0.14;

StockSpec = stockspec(Volatility,AssetPrice);

OptSpec = 'call';
Strike = 120;
Settle = 'Jan-1-2016';
Maturity = 'jan-1-2018';

OutSpec = {'price';'delta';'theta'};

[Price,Delta,Theta] = optstocksensbybaw(RateSpec,StockSpec,Settle,Maturity,OptSpec,Strike,'OutSpec',OutSpec)