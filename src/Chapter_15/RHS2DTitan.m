%% RHS2DTITAN Two dimensional dynamical model
% This calls a special function for the Titan atmosphere.
%%  Form:
%   d = RHS2DTitan;  % data structure
%   [xDot,q] = RHS2DTitan( t, x, d )
%
%% Inputs
%   t (1,1) Time (s) (unused)
%   x	(3,1) State [r;uR;uT]
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
%
%% Outputs
%   xDot	(3,1) State derivative [r;uR;uT]
%   q     (1,1) Dynamic pressure

function [xDot, q] = RHS2DTitan( ~, x, d )

% Constants
rTitan = 2575;
mu     = 9.142117352579678e+03;
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

% Atmospheric density
h       = r - rTitan;
if( h <= 0 )
  h = 0;
end
[rho,~,speedSound] = TitanAtmosphere(h);

% Forces
uRM     = uR*kMToM;
uTM     = uT*kMToM;
w       = uRM^2 + uTM^2;

% Lift and drag
cL      = d.cLAlpha*d.alpha;
eps     = 0.8; % Oswald efficiency
%k       = 1/(pi*d.aR*eps);
mach    = sqrt(w)/speedSound;
k       = InducedDragCoeff( eps, d.aR, mach );
cD      = d.cD0 + k*cL^2;

q       = 0.5*rho*w;

% Direction of the velocity vector
u       = [uRM;uTM]/sqrt(w);
drag    = -cD*q*d.s*u;
lift    =  cL*q*d.s*[0 1;-1 0]*u;
c       = cos(d.alpha);
s       = sin(d.alpha);
thrust  = d.thrust*[c -s;s c]*u;
a       = nToKN*(thrust + drag + lift)/d.mass;

% State derivatives
uRDot   =  uT^2/r - mu/r^2 + a(1);
uTDot   = -uT*uR/r         + a(2);
xDot    = [uR;uRDot;uTDot];


function d = DefaultDataStructure
% Default model data

mu	= 9.142117352579678e+03;
r   = 2875;
d = struct('aR',1.7,'eps',0.9,'s',10,'cD0',0.006,'cLAlpha',2*pi,...
  'mass',2000,'alpha',0,'thrust',0,'x0',[r;0;sqrt(mu/r)],'useHyper',false);
d.states = {'r (km)' 'u_r (km/s)', 'u_t (km/s)'};


%% Copyright
% Copyright (c) 2019, 2022 Princeton Satellite Systems, Inc.
% All rights reserved.
