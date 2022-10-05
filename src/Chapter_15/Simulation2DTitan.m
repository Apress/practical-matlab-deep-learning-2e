 function [x,xP,t] = Simulation2DTitan( x, t, d, u )

%% Two dimensional Titan aircraft simulation
% Integrates the RHS2DTitan function using ode113. Has a built-in demo.
%%  Form:
%   [x,xP,t] = Simulation2DTitan( x, t, d, u )
%
%% Inputs
%   x   (3,1) State [r;uR;uT]
%   t   (1,:) Time (s) 
%   d   (.)   Data structure See RHS2DTitan
%   u   (2,:) [alpha;thrust]
%
%% Outputs
%   x   (3,1) Final state [r;uR;uT]
%   xP	(3,:) Final state array [r;uR;uT]
%   t   (1,:) Time array (s)

if( nargin < 1 )
  Demo
  return
end

rTitan  = 2575;

n       = length(t);
xP      = zeros(3,n);
xP(:,1) = x;

for k = 2:n
  d.alpha   = u(1,k-1);
	rHS       = @(t,x,d) RHS2DTitan(t,x,d);
  [~, x]    = ode113(rHS, [0, t(k)-t(k-1)], x, [], d );
  x         = x(end,:)';

  xP(:,k)   = x;
  if( x(1) - rTitan <= 0 )
    break;
  end
end

xP = xP(:,1:k);
t  = t(:,1:k);

if( nargout < 1 )
  [t,tL]  = TimeLabel(t);
  xP(1,:) = xP(1,:) - 2575;
  yL      = {'h (km)' 'u_r (km/s)', 'u_t (km/s)'};
  PlotSet(t,xP,'x label',tL,'y label',yL,'figure title','Titan Simulation');
  clear x
end

%% Simulation2DTitan>Demo
function Demo

d = RHS2DTitan;
t = linspace(0,120000,1000);
u = (pi/12)*[ones(1,12000);...
     0*ones(1,12000)];
Simulation2DTitan( d.x0, t, d, u );


%% Copyright
% Copyright (c) 2019, 2022 Princeton Satellite Systems, Inc.
% All rights reserved.
