%% M2NU Computes the true anomaly from the mean anomaly.
%% Form:
%   nu  = M2Nu( e, M, tol, nMax )
%
%% Inputs
%   e               (1,1)  Eccentricity
%   M               (1,:)  Mean anomaly (rad)
%   tol             (1,1)  Tolerance
%   nMax            (1,1)  Maximum number of iterations
%
%% Outputs
%   nu              (1,:)  True anomaly (rad)

function nu = M2Nu( e, M, tol, nMax )

if( nargin < 2 )
  M = linspace(0,2*pi);
end

if( nargin>2 && isempty(tol) )
  tol = 1e-14;
end

if( e ~= 1 )
  if( nargin < 3 )
    E = M2E( e, M );
  elseif( nargin < 4 ) 
    E = M2E( e, M, tol );
  else
    E = M2E( e, M, tol, nMax );
  end
  nu = E2Nu( e, E );
else
  nu = M2NuPb( M ); % not included
end

if( nargout == 0 )
  PlotSet(M,nu,'x label','Mean Anomaly','y label','True Anomaly',...
    'figure title','nu')
  clear nu
end

function eccAnom  = M2E( e, meanAnom, tol, nMax )
% Eccentric anomaly from the mean anomaly and the eccentricity. Only works for
% ellipses.

if( nargin < 2 )
  if( length(e) == 1 )
    meanAnom = linspace(0,2*pi);
  else
    error('PSS:M2E:error','If e is not a scalar you must enter mean anomaly')
  end
end

eccAnom = zeros(size(meanAnom));

k = find(e >= 1); %#ok<EFIND>

if( ~isempty(k) )
  error('Cannot handle eccentricities >= 1');
end

if( nargin < 3 )
	eccAnom = M2EEl(e,meanAnom);
elseif( nargin == 3 )
	eccAnom = M2EEl(e,meanAnom,tol);
elseif( nargin == 4 )
	eccAnom = M2EEl(e,meanAnom,tol,nMax);
end

%% M2Nu>M2EEL
function eccAnom = M2EEl( ecc, meanAnom, tol, nMax )

if( nargin < 3 )
  tol = 1.e-8;
end

% First guess
eccAnom  = M2EApp(ecc,meanAnom);
	
% Iterate
delta = tol + 1; 
n     = 0;
tau   = tol;

while ( max(abs(delta)) > tau )
  dE    	  = (meanAnom - eccAnom + ecc.*sin(eccAnom))./ ...
                   (1 - ecc.*cos(eccAnom));
  eccAnom    = eccAnom + dE;
  n           = n + 1;
  delta       = norm(abs(dE),'inf');
  tau         = tol*max(norm(eccAnom,'inf'),1.0);
  if ( nargin == 4 )
    if ( n == nMax )
      break
    end
  end
end

function eccAnom = M2EApp( e, meanAnom )

eL = length(e);
mL = length(meanAnom);
if( mL ~= eL && eL == 1 )
  e = e*ones(size(mL));
end

if any( e < 0 | e == 1 )
  error('PSS:M2EApp:error','The eccentricity must be > 0, and not == 1');
else 
  eccAnom = zeros(size(meanAnom));
 
  k    = find( meanAnom ~= 0 );
  e    = e(k);
  m    = meanAnom(k);
  i    = find( m > pi ); 
  if( ~isempty(i) )
    m(i) = -m(i);
  end
  
  eA   = zeros(size(m));

  kL = find(e<1);
  kG = find(e>=1);
  
  if( ~isempty(kL) )     % elliptical case.
    sM      = sin(m(kL)); 
    eA(kL) = m(kL) + e(kL).*sM./(1 - sin(m(kL)+e(kL)) + sM);
  end
  
  if( ~isempty(kG) )     % hyperbolic case.
    sM     = sinh(m(kG)./(e(kG)-1));
    eA(kG) = m(kG).^2 ./ (e(kG).*(e(kG)-1).*sM - m(kG));
  end
  
  if( ~isempty(i) )
    eA(i) = -eA(i);
  end
  
  eccAnom(k) = eA;
end

function nu = E2Nu( e, E )
% Computes the true anomaly from the eccentric or hyperbolic anomaly.

k = find( e == 1, 1 );
if( ~isempty(k) )
  error('PSS:E2Nu:error','Eccentric anomaly is not defined for parabolas')
end

if( length(e) == 1 )
  e = e*ones(size(E));
end

nu = zeros(size(E));

k = find( e < 1 );
if( ~isempty(k) )
  nu(k) = 2*atan(sqrt((1+e(k))./(1-e(k))).*tan(0.5*E(k)));
end

k = find( e > 1 );
if( ~isempty(k) )
  nu(k) = 2*atan(sqrt((1+e(k))./(e(k)-1)).*tanh(0.5*E(k)));
end


%% Copyright
% Copyright (c) 1993-2019 Princeton Satellite Systems, Inc.
% All rights reserved.