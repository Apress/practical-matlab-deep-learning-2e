%% TITANLANDINGCOST2D Cost for the landing for a 2D planet problem.
% The cost is the stagnation temperature.
% This is computed from the decision variables and state.
%% Form:
%   cost = TitanLandingCost2D( u, d )
%
%% Inputs
%   u       (2,:)   [alpha;thrust]
%   d        (.)    Data structure describing the aircraft model
%                    .x
%                    .t
%                    .costType
%
%% Outputs
%   cost    (1,1)   Maximum dynamic pressure

function cost = TitanLandingCost2D( u, d )

[~,xP]  = Simulation2DTitan( d.x, d.t, d, u );
cost    = CostCalculation( xP, d.costType );

% Dynamic pressure
function cost = CostCalculation( x, type )

h           = x(1,:)- 2575; % Altitude (km)
j           = h<0;
h(j)        = 0;
[rho, t, a] = TitanAtmosphere(h);
v           = 1e3*sqrt(x(2,:).^2 + x(3,:).^2); % m/s

switch type
  case 'stagnation temperature'
    gamma	= 1.4;
    m   	= v./a;
    r   	= 0.88;
    t0    = t.*(1 + 0.5*r*(gamma - 1).*m.^2);
    cost	= mean(t0);
  case 'heating rate' % p 238 Wiesel
    cost  = mean(sqrt(rho).*v.^3);
  case 'dynamic pressure'
    q     = 0.5*rho.*v.^2;
    cost  = mean(q);
  otherwise
    error('%s not available',type);
end


%% Copyright
% Copyright (c) 2019, 2022 Princeton Satellite Systems, Inc.
% All rights reserved.
