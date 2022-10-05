%% Simulate level flight above Titan
% See also RHS2DTitan, Simulation2DTitan, TimeLabel, PlotSet

%% Constants
rTitan      = 2575;
mu          = 9.142117352579678e+03;
kMToM       = 1000;

%% Get the default data structure
d           = RHS2DTitan;

%% Compute the flight conditions and the controls
d.mass      = 2000; % kg
d.s         = 20; % m^2
altitude    = 100; % km
r           = rTitan + altitude;
d.thrust    = 0;
d.alpha     = 0.0;
tEnd        = 20*60;

%% Run the simulation
n           = 2000;
t           = linspace(0,tEnd,n);
x           = [r;0;sqrt(mu/r)];
u           = [d.alpha*ones(1,n);d.thrust*ones(1,n)];
[~,xP,t]    = Simulation2DTitan( x, t, d, u );
[t,tL]      = TimeLabel(t);
d.states{1} = 'Altitude (km)';
xP(1,:)     = xP(1,:) - rTitan;
PlotSet(t,xP,'x label',tL,'y label',d.states,'figure title','Reentry')


%% Copyright
% Copyright (c) 2019, 2022 Princeton Satellite Systems, Inc.
% All rights reserved.
