%% TITANATMOSPHERE Titan atmospheric density model.
%
% Type TitanAtmosphere for a demo
%
%%  Form:
%   TitanAtmosphere( h )
%
%% Inputs
%   h   (1,:) Altitude (km)
%
%% Outputs
%   rho	(1,:) Density (kg/m^3)
%   t 	(1,:) Temperature (deg-K)
%   a   (1,:) Speed of sound (m/s)
%
%% Reference
% C.G. Justus and R.D. Braun, "Atmospheric Environments for Entry, Descent
% and Landing (EDL), June 2007.

function [rho, t, a] = TitanAtmosphere( h )

% Demo
if( nargin < 1 )
  TitanAtmosphere(linspace(0,1400));
  return
end

% Altitude
hD    = [0:10:100 150:50:900]; % km

% Density
rhoD	= [   5.270e0  3.467e0  2.144e0  1.233e0  6.731e-1 3.575e-1...
            1.825e-1 8.264e-2 4.788e-2 3.155e-2 2.219e-2 5.024e-3...
            1.393e-3 4.612e-4 1.673e-4 6.282e-5 2.438e-5 9.806e-6...
            4.114e-6 1.718e-6 7.129e-7 2.931e-7 1.173e-7 4.653e-8...
            1.868e-8 7.934e-9 3.404e-9];
 
% Temperature
tD    = [  92.89  83.29  76.44  72.20  70.51  71.16  76.62 103.46...
          122.88 133.97 140.80 159.23 173.76 181.72 181.72 181.72...
          181.72 180.81 173.96 167.06 160.09 153.04 148.62 148.62...
          148.62 148.62 148.62];
  
% Speed of sound
aD    = [ 195.6 185.7 177.7 173.1 171.5 172.5 179.2 208.4 227.1...
          237.1 243.1 258.6 270.1 276.2 276.2 276.2 276.2 275.5...
          270.2 264.8 259.3 253.5 249.8 249.8 249.8 249.8 249.8];
        
rho   = interp1(hD,rhoD,h,'linear'); % Density
t     = interp1(hD,tD,  h,'linear'); % Temperature
a     = interp1(hD,aD,  h,'linear'); % Speed of sound

% Plot
if( nargout == 0 )
  NewFigure('Titan Atmosphere Density and Temperature');
  yyaxis right
  plot(h,t);
  ylabel('Temperature (deg-K)')
  yyaxis left
  semilogy(h,rho);
  ylabel('Density (kg/m^3)');
  xlabel('H (km)');
  title('Titan Atmosphere Density and Temperature');
  grid on
  
  NewFigure('Titan Atmosphere Density and Speed of Sound');
  yyaxis right
  plot(h,a);
  ylabel('Speed of Sound (m/s)')
  yyaxis left
  semilogy(h,rho);
  ylabel('Density (kg/m^3)');
  xlabel('H (km)');
  title('Titan Atmosphere Density and Speed of Sound');
  grid on
  clear rho
end
