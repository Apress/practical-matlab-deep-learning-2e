%% RHS2DAERO Two dimensional dynamical model
%
%%  Form:
%   d = RHS2DAero;
%   [xDot,q] = RHS2DAero( x, t, d )
%
%% Inputs
%   x	(3,1) State [r;uR;uT]
%   t (1,1) Time (s) (unused)
%   d (.)   Data structure
%           .aR       (1,1) Aspect ratio
%           .eps      (1,1) Oswald efficiency factor 
%           .s        (1,1) Aerodynamic surface area (m^2)
%           .cD0      (1,1) Zero lift drag coefficient
%           .cLAlpha  (1,1) Lift coefficient
%           .mass     (1,1) Mass (kg)
%           .alpha    (1,1) Angle of attack (rad)
%           .thrust   (1,1) Thrust (N)
%           .x0       (3,1) Default state
%           .states   {3,1} State names
%           .mu       (1,1) Gravitational parameter
%           .rPlanet  (1,1) Radius planet
%           .funAtm    (@)  Pointer to atmospheric function
%
%% Outputs
%   xDot	(3,1) State derivative [r;uR;uT]
%   g     (1,1) Dynamic pressure

function [xDot, q] = RHS2DAero( x, ~, d )

% Constants
kMToM  = 1000;
nToKN  = 0.001;

% Return the default data structure
if( nargin < 1 )
  xDot = DefaultDataStructure;
  return
end

% To clarify the code use local variables
r       = x(1);
uR      = x(2);
uT      = x(3);

% Lift and drag
cL      = d.cLAlpha*d.alpha;
k       = 1/(pi*d.aR*d.eps);
cD      = d.cD0 + k*cL^2;

% Atmospheric density
h       = r - d.rPlanet;
if( h <= 0 )
  h = 0;
end
rho     = d.funAtm(h);

% Forces
uRM     = uR*kMToM;
uTM     = uT*kMToM;
w       = uRM^2 + uTM^2;
qS      = 0.5*rho*w*d.s;
u       = [uRM;uTM]/sqrt(w);
drag    = -cD*qS*u;
lift    =  cL*qS*[u(2);-u(1)];%[0 1;-1 0]*u;
thrust  = d.thrust*[sin(d.alpha);cos(d.alpha)];
a       = nToKN*(thrust + drag + lift)/d.mass;

% State derivatives
uRDot   = uT^2/r - d.mu/r^2 + a(1);
uTDot   = -uT*uR/r + a(2);
xDot    = [uR;uRDot;uTDot];

function d = DefaultDataStructure
% Default model data

mu	= 9.142117352579678e+03;
r   = 2675;
d = struct('aR',1.7,'eps',0.9,'s',10,'cD0',0.006,'cLAlpha',2*pi,...
  'mass',2000,'alpha',0,'thrust',0,'x0',[r;0;sqrt(mu/r)],'mu',9.142117352579678e+03,...
  'rPlanet',2575,'funAtm',@TitanAtmosphere);
d.states = {'r (km)' 'u_r (km/s)', 'u_t (km/s)'};


%% Copyright
% Copyright (c) 2019, 2022 Princeton Satellite Systems, Inc.
% All rights reserved.
