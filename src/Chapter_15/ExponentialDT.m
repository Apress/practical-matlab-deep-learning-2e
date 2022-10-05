%% EXPONENTIALDT Exponentially decreasing step size
% Has a demo calling NonuniformSequence
%% Form:
% dT = ExponentialDT(n, f)
%
%% Inputs
%   n   (1,1)   Number of steps
%   f	(1,1)    End value of sequence
%
%% Outputs
%   dT	(1,:)   Steps

function dT = ExponentialDT(n,f)

if( nargin < 1 )
  NonuniformSequence(20,100,@ExponentialDT);
  return
end

if( nargin < 2 )
  f = 4;
end

h   = linspace(0,f,n);
dT  = exp(-h);


%% Copyright
% Copyright (c) 2019, 2022 Princeton Satellite Systems, Inc.
% All rights reserved.
