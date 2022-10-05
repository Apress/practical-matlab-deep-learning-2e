function [u,m] = Unit( v )

%% Unitize vectors by column.
% The magnitude is computed internally and available as a second output.
%% Form:
%   [u,m] = Unit( v )
%% Inputs
%   v            (:,n)     Vectors
%
%% Outputs
%   u            (:,n)     Unit vectors
%   m            (:,1)     Vector magnitudes
%

[n,p]  = size(v);

if( n == 1 )
  m = v;
else
  m = sqrt(sum(v.^2));
end

% start with NaN
u = NaN(n,length(m));

% check that magnitudes are not zero
k = find( m > 0 );

if( ~isempty(k) )
  if (p==1)
    % Single column
    u = v/m;
  else
    for j = 1:n
      u(j,k) = v(j,k)./m(k);	
    end 
  end
end

% Copyright (c) 1994, 2022 Princeton Satellite Systems, Inc. 
% All rights reserved.
