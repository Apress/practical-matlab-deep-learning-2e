%% Simulate level flight above Titan
% See also RHS2DAero, Simulation2DAero, fminsearch

%% Constants
rTitan    = 2575;
mu        = 9.142117352579678e+03;
kMToM     = 1000;

%% Get the default data structure
d         = RHS2DAero;

%% Compute the flight conditions and the controls

% Aircraft and flight parameters
d.mass    = 2000; % kg
d.s       = 20; % m^2
altitude  = 100; % km

% Find the equilibrium velocity and control
c         = [400;0.06;0]; % Initial control [thrust;v;alpha]
r         = d.rPlanet + altitude;

% Use a numerical search
Options   = optimset;
fun       = @(c) Cost(c,d,r);
c         = fminsearch( fun, c, Options );

d.thrust  = c(1);
d.alpha   = c(3);

%% Run the simulation
n         = 2000;
t         = linspace(0,3600,n);
x         = [r;0;c(2)];
u         = [d.alpha*ones(1,n);d.thrust*ones(1,n)];
Simulation2DAero( x, t, d, u );
subplot(311)
title(sprintf('Altitude: %g km',altitude))

%% Print out the parameters
fprintf('Angle of attack            %8.2f deg\n',d.alpha*180/pi);
fprintf('Velocity                   %8.2f m/s\n',c(2)*kMToM);
fprintf('Thrust                     %8.2f N\n',d.thrust);
fprintf('Mass                       %8.2f kg\n',d.mass);
fprintf('Wetted area                %8.2f m^2\n',d.s);

%% Cost for fminsearch
function c = Cost( u, d, r )

x(1)      = r;
d.thrust  = u(1);
x(3)      = u(2);
d.alpha   = u(3);

xDot      = RHS2DAero(x,0,d);

c         = vecnorm(xDot);

end


%% Copyright
% Copyright (c) 2019, 2022 Princeton Satellite Systems, Inc.
% All rights reserved.