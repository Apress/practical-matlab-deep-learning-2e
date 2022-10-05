%% Demo of StockPrice
% See also StockPrice, PlotStock

tEnd  = 5.75;
n     = 1448;
s0    = 8242.38;
r     = 0.1682262;
sigma = 0.1722922;

s1 = StockPrice( s0, r, sigma, tEnd, n );

sigma = 0;
[s2,t] = StockPrice( s0, r, sigma, tEnd, n );

PlotStock(t,[s1;s2],{});
legend('Wilshire 5000','Zero Volatility');


%% Copyright
% Copyright (c) 2019, 2022 Princeton Satellite Systems, Inc.
% All rights reserved.
