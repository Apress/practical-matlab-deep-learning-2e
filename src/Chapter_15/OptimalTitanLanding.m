%% Optimal Titan Landing
% This demo requires fmincon from the Optimization Toolbox.
% See also RHS2DTitan, NonuniformSequence

rTitan        = 2575;
mu            = 9.142117352579678e+03;
h             = 300;
dT            = 1;
n             = 100;

d             = RHS2DTitan; % The data structure
d.n           = n; % Number of decision variable increments
d.tEnd        = 2*60*60; % From the Landing script
d.t           = NonuniformSequence(d.tEnd,d.n,@ExponentialDT);
d.costType    = 'heating rate';

% Initial state
r             = rTitan + h;
x             = [r;0;sqrt(mu/r)];
d.x           = x;

% fmincon options
opts          = optimset( 'Display','iter-detailed',...
                          'TolFun',1e-5,...
                          'algorithm','interior-point',...
                          'TolCon',1e-6,...
                          'MaxFunEvals',15000);

% The cost is the time to reach the final state vector
costFun   = @(x) TitanLandingCost2D(x,d);

% The numerical integration of the state is in the constraint function
constFun	= @(x) TitanLandingConst2D(x,d);

% The decision variables is angle of attack
u0        = 0.0001*ones(1,n);

% Lower and upper bounds for the decision variables
oN        = ones(n,1);
lB        = zeros(1,n);
uB        = (pi/12)*oN;

% Find the optimal decision variable
u         = fmincon(costFun,u0,[],[],[],[],lB,uB,constFun,opts);

%% Run the simulation
x           = [r;0;sqrt(mu/r)];
[~,xP,t]    = Simulation2DTitan( x, d.t, d, u );
[t,tL]      = TimeLabel(t);
u           = u(1:length(t));
d.states{1} = 'Altitude (km)';
xP(1,:)     = xP(1,:) - rTitan;
yL          = [d.states(:)' {'\alpha (rad)'} {'M'}];
[~, ~, a]   = TitanAtmosphere( xP(1,:) );
m           = 1000*sqrt(xP(2,:).^2 + xP(3,:).^2)./a;
PlotSet(t,[xP;u;m],'x label',tL,'y label',yL,...
  'figure title','Landing')


%% Copyright
% Copyright (c) 2019, 2022 Princeton Satellite Systems, Inc.
% All rights reserved.

