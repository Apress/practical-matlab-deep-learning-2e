%% Induced drag coefficient for all Mach numbers.
% At supersonic speeds provides combined vortex and wave drag. 
% Drag is cD0 + k*cL^2.
%
% This function includes a linear term in the square root for the
% supersonic mach numbers that allows it to match the
% subsonic induced drag at M = 1. Otherwise it would produce a jump in
% the drag at M = 1.
%% Form:
%   k = InducedDragCoeff( e, aR, m )
%% Inputs
%   e              (1,1) Oswald efficiency factor (0 to 1)
%   aR             (1,1) Wing aspect ratio
%   m              (1,:) Mach number
%
%% Outputs
%   k              (1,:) Induced drag coefficient
%% Reference 
% http://adg.stanford.edu/aa241/drag/LiftWaveDrag.html

function k = InducedDragCoeff( e, aR, m )

% Subsonic
kLow	  = 1/(e*pi*aR);
k       = kLow*ones(1,length(m));

% Supersonic
z       = (4*kLow)^2;
j       = find(m >= 1);
k(j)    = 0.25*sqrt(m(j).^2 + z*m(j) - 1);



%% Copyright
% Copyright (c) 2011-2022 Princeton Satellite Systems, Inc.
% All rights reserved.
