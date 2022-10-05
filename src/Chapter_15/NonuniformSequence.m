%% NONUNIFORMSEQUENCE Nonlinear sequence
%% Form:
%   t = NonuniformSequence(tEnd,n,dTFun)
%
%% Inputs
%   tEnd     (1,1) End value for t
%   n        (1,1) Number of step
%   dTFun    (1,1) Pointer to a time step function
%
%% Outputs
%   t    (1,n)   Sequence

function t =  NonuniformSequence(tEnd,n,dTFun)

if( nargin < 1 )
   NonuniformSequence(60*20,50,@Linear)
   return
end

if( nargin < 3 )
  dTFun = @Linear;
end

dT = dTFun(n);

% Scale
s  = tEnd/sum(dT);

t  = zeros(1,n);
for k = 2:n
  t(k) = t(k-1) + s*dT(k-1);
end

if( nargout < 1 )
  PlotSet(1:n,t,'x label','step','y label','Value','figure title','Non-uniform distribution');
  clear t
end

%% NonuniformSequence>Linear
function dT = Linear(n)

dT = linspace(1,0.1,n-1);


%% Copyright
% Copyright (c) 2019, 2022 Princeton Satellite Systems, Inc.
% All rights reserved.
