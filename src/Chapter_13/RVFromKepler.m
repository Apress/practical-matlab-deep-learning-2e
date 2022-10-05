function [r, v, t] = RVFromKepler( elI, t, mu, tol )

%% Generate an orbit by propagating Keplerian elements.
% If t is not entered it will plot one orbit. Only handles elliptical orbits.
%--------------------------------------------------------------------------
%   Form:
%   [r, v, t] = RVFromKepler( elI, t, mu, tol )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   elI        (1,6) Elements vector [a,i,W,w,e,M] or structure
%   t          (1,:) Times from 0 to ƒ (sec)
%   mu         (1,1) Gravitational parameter
%   tol        (1,1) Orbit propagation tolerance
%
%   -------
%   Outputs
%   -------
%   r          (3,:) Position vectors for times t
%   v          (3,:) Velocity vectors for times t
%   t          (1,:) Times at which r and v are calculated
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%	 Copyright (c) 1995-1998 Princeton Satellite Systems, Inc.
%    All rights reserved.
%--------------------------------------------------------------------------

if( nargin < 4 )
  tol = [];
end

if( nargin < 3 )
  mu = [];
end

if( nargin < 2 )
  t = [];
end

if( nargin < 1 )
  i    = 23*pi/180;
  e    = 0.71525616775479;
  a    = 2.458350000000000e+04;
  elI  = [a,i,pi,0,e,0];
  tol  = 1e-8;
end

if( isstruct(elI) )
  el(1) = elI.a;
  el(2) = elI.i;
  el(3) = elI.W;
  el(4) = elI.w;
  el(5) = elI.e;
  el(6) = elI.M;
else
	el    = elI;
end

a = el(1);
e = el(5);

if( isempty(tol) )
  tol = 1e-8;
end

if( isempty(mu) )
  mu = 3.98600436e5;
end

wo = sqrt(mu/abs(a)^3);

if( isempty(t) )
  t = linspace(0,2*pi/wo);
end

% Transforms from the perifocal frame to the inertial frame
%----------------------------------------------------------
c      = CP2I( el(2), el(3), el(4) );
							 
% Mean anomaly
%-------------
M      = wo*t + el(6);

E      = M2E( e, M, tol );
theta  = 2*atan(sqrt((1+e)/(1-e))*tan(0.5*E));
cTheta = cos( theta );
sTheta = sin( theta );

p      = a*(1-e^2);

rMag   = p./(1 + e*cTheta); 

r      = c*[rMag.*cTheta;rMag.*sTheta;zeros(size(t))];
v      = sqrt(mu/p)*c*[-sTheta;e+cTheta;zeros(size(t))]; 

if( nargout == 0 )
  NewFigure('RVFromKepler');
  plot3(r(1,:),r(2,:),r(3,:));
  view(150,20)
  grid on
  
  [t,c] = TimeLabel( t );
  NewFigure('Orbital Velocity');
  plot(t,v)
  xlabel(c)
  ylabel('Velocity (km/sec)');
  grid on
	clear r v
end

%-------------------------------------------------------------------------------
%   Converts the transformation matrix from the perifocal frame
%   to the inertial frame
%-------------------------------------------------------------------------------
function c = CP2I( i, L, w )

ci = cos(i);
si = sin(i);

cw = cos(w);
sw = sin(w);

cL = cos(L);
sL = sin(L);

c = [ cL*cw-sL*sw*ci,-cL*sw-sL*cw*ci, sL*si;...
      sL*cw+cL*sw*ci,-sL*sw+cL*cw*ci,-cL*si;...
               sw*si,          cw*si,    ci];


%-------------------------------------------------------------------------------
%   Generate the eccentric anomaly from the mean anomaly
%   and the eccentricity for an ellipse. 
%-------------------------------------------------------------------------------
function E = M2E( e, M, tol )

% First guess
%------------
E  = M;
	
% Iterate
%--------
delta = tol + 1; 
tau   = tol;

while ( max(abs(delta)) > tau )
  dE    = (M - E + e*sin(E))./(1 - e*cos(E));
  E     = E + dE;
  delta = norm(abs(dE),'inf');
  tau   = tol*norm(E);
end


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date$
% $Id: cf67f32bf814b11d39b641f692211d802153abb1 $
