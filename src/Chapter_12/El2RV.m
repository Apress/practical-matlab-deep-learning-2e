%% EL2RV Converts orbital elements to r and v for an elliptic orbit.
% Type El2RV for a demo.
%
%% Form:
%   [r, v] = El2RV( el, tol, mu )
%
%% Inputs
%   el    (6,:)  Elements vector [a,i,W,w,e,M] (angles in radians)
%   tol   (1,1)* Tolerance for the equation solver. (default = 1e-14)
%   mu    (1,1)* Gravitational constant. (default = 3.98600436e5)
%
%% Outputs
%   r     (3,:)  position vector
%   v     (3,:)  velocity vector
%
%% References:	
% Battin, R.H., An Introduction to the Mathematics and Methods of Astrodynamics,
% p 128.
% Bate, Roger R., Fundamentals of Astrodynamics, Dover Publications, Inc., New
% York, 1971, pp. 82-83.

function [r, v] = El2RV( el, tol, mu )

% Demo
if( nargin < 1 )
  el      = [8000 0.2 3 0.1 0.2 4];
  [r, v]  = El2RV( el );
  disp('Elements')
  disp(el)
  disp('Position')
  disp(r)
  disp('Velocity')
  disp(v)
  clear r
  return
end

[m,n] = size(el);

if( m == 1 && n == 6 )
  el = el';
  n  = 1;
end

if( nargin < 3 )
  mu = 3.98600436e5;
end

if( nargin < 2 )
  tol = 1.e-14;
elseif( isempty(tol) )
  tol = 1.e-14;
end

v = zeros(3,n);
r = v;

for k = 1:n
  e      = el(5,k);
  M      = el(6,k);
  a      = el(1,k);
  f      = M2Nu( e, M, tol, 200 );

  if( e ~= 1 )
    p    = a*(1-e)*(1+e);
  else
    p    = a*(1+e);
  end
  
  cf     = cos(f);
  sf     = sin(f);
   
  rp     = p/(1 + e*cf)*[ cf; sf; 0 ];
  vp     = sqrt(mu/p)*[-sf; e+cf; 0];
 
  c      = CP2I( el(2,k), el(3,k), el(4,k) );

  r(:,k) = c*rp;
  v(:,k) = c*vp;
end


function c = CP2I( i, L, w )
%   c = CP2I( i, L, w )
%
%   i  (3,1) Inclination (rad)
%   L  (3,1) Longitude of the ascending node (rad)
%   w  (3,1) Argument of perigee (rad)
%
%   c   (3,3) Transformation matrix

if( nargin < 3 )
  w = 0;
end

if( nargin < 2 )
  L = 0;
end

if( nargin < 1 )
  i = 0;
end

ci = cos(i);
si = sin(i);

cw = cos(w);
sw = sin(w);

cL = cos(L);
sL = sin(L);

c = [ cL*cw-sL*sw*ci,-cL*sw-sL*cw*ci, sL*si;...
      sL*cw+cL*sw*ci,-sL*sw+cL*cw*ci,-cL*si;...
               sw*si,          cw*si,    ci];




%% Copyright
%   Copyright (c) 2019 Princeton Satellite Systems, Inc.
%   All rights reserved.