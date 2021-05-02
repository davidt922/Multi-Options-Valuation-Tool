valuationDate = datetime(2021,1,1);
maturity = datetime(2022,1,1);
Basis = 1;
Compounding = -1;
Rates = 0.1;
RateSpec = intenvset('ValuationDate',valuationDate,'StartDate',valuationDate,'EndDate',maturity, ...
'Rates',Rates,'Basis',Basis,'Compounding',Compounding);

Dividend = 0;
AssetPrice = 100;
Volatility = 0.2;

StockSpec = stockspec(Volatility,AssetPrice,'Continuous',Dividend);


Strike = 100;

OutSpec = {'price';'delta';'theta'};

[Price,Delta,Theta] = optstocksensbybaw(RateSpec,StockSpec,valuationDate,maturity,'put',Strike,'OutSpec',OutSpec)

[Call,Put] = blsprice(AssetPrice,Strike,Rates,1,Volatility)