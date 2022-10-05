%% Two dimensional aircraft simulation
% Utilizes ode113 with RHS2DAero. Has a built-in demo.
%%  Form:
%   [x,xP,t] = Simulation2DAero( x, t, d, u )
%
%% Inputs
%   x   (3,1) State [r;uR;uT]
%   t   (1,1) Time (s) (unused)
%   d   (.)   Data structure See RHS2DAero
%   u   (2,:) [alpha;thrust]
%
%% Outputs
%   x   (3,1) Final state [r;uR;uT]
%   xP	(3,:) Final state array [r;uR;uT]
%   t   (1,:) Time array (s)s
 
function [x,xP,t] = Simulation2DAero( x, t, d, u )

if( nargin < 1 )
  Demo
  return
end

n       = length(t);
xP      = zeros(3,n);
xP(:,1) = x;

for k = 2:n
  d.alpha   = u(1,k-1);
  d.thrust  = u(2,k-1);
	rHS       = @(t,x,d) RHS2DAero(x,t,d);
  [~, x]    = ode113(rHS, [0, t(k)-t(k-1)], x, [], d );
  x         = x(end,:)';

  xP(:,k)   = x;
  if( x(1) - d.rPlanet <= 0 )
    break;
  end
end

xP = xP(:,1:k);
t  = t(:,1:k);

if( nargout < 1 )
  [t,tL] = TimeLabel(t);
  PlotSet(t,xP,'x label',tL,'y label',d.states,'figure title','Aero Simulation');
  clear x
end

%% Simulation2DAero>Demo
function Demo

d = RHS2DAero;
t = linspace(0,120000,1000);
u = zeros(2,1000);
Simulation2DAero( d.x0, t, d, u );


%% Copyright
% Copyright (c) 2019, 2022 Princeton Satellite Systems, Inc.
% All rights reserved.
