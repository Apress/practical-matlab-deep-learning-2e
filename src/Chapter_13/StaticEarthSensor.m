%% STATICEARTHSENSOR Static Earth sensor model
% The boresight is along +z. It will draw a picture if there are no 
% outputs. 
%
% Type StaticEarthSensor for a demo.
%
%% Form:
%   y = StaticEarthSensor(q,r,d)
%
%% Inputs
%  
%   q   (4,1)	ECI to Body
%   r   (3,1)	Vector from planet center to spacecraft
%   d   (.)   Data structure
%             .n              (1,1) Number of segments in the planet circle
%             .p              (2,:) Vertices for the detector
%             .pAng           (2,:) Vertices in angles (deg)
%             .az             (1,n) Azimuth of the detector elements
%             .el             (1,n) Elevation of the detector elements 
%             .rPlanet        (1,1) Planet radius
%             .fL             (1,1) Focal length
%             .qBodyToSensor	(4,1) Quaternion from body to sensor frame
%             .scale          (1,1) Output/detector area intersecting 
%
%% Outputs
%  
%   y   (:,1)	Detector outputs
%

function y = StaticEarthSensor(q,r,d)

% Demo
if( nargin < 1 )
  if( nargout == 0 )
    Demo
  else
    y = DefaultDataStructure;
  end
  return
end

% Quaternion from ECI to the sensor frame
qECIToSensor  = QMult(q,d.qBodyToSensor);

uNadir        = QForm(qECIToSensor,Unit(r));
cEarth        = d.fL*uNadir(1:2);

% Planet angular width
ang           = asin(d.rPlanet/vecnorm(r));
r             = d.fL*sin(ang);

% Cycle through all the elements
nP            = length(d.az);
poly          = cell(1,nP);
a             = zeros(1,nP);

if( d.pAng(1) == 0 )
  p  = d.p;
else
  p  = d.fL*sind(d.pAng);
end

for k = 1:nP
  az              = d.az(k);
  el              = d.el(k);
  rP              = d.fL*[cos(az);sin(az)]*sin(el);
  c               = [cos(az) -sin(az);sin(az) cos(az)];
  pK              = rP + c*p;
  [a(k), poly{k}] = EarthSensorElement(r,d.n,pK,cEarth);
end

% Convert from area to output (linear model)
y = a/d.scale;

% Default output
if( nargout < 1 )
  r      = vecnorm(r);
  a      = linspace(0,2*pi-2*pi/d.n,d.n);
  x      = r*cos(a) + cEarth(1);
  y      = r*sin(a) + cEarth(2);
  planet = polyshape(x,y);

  NewFigure('Earth Sensor');
  plot(planet)
  hold on
  for k = 1:nP
    plot(poly{k})
  end
  grid on
  axis image
end

%% StaticEarthSensor>Demo
function Demo
d   = StaticEarthSensor;
r   = [0;0;42167];
StaticEarthSensor([1;0;0;0],r,d);

%% StaticEarthSensor>DefaultDataStructure
function d = DefaultDataStructure

d.n             = 40;
d.p             = [1 1 -1 -1;1 -1 -1 1];
d.pAng          = zeros(2,4);
d.az            = 0:pi/4:2*pi-pi/4;
d.el            = (pi/20)*ones(1,8);
d.rPlanet       = 6378.165;
d.fL            = 50;
d.qBodyToSensor = [1;0;0;0];
d.scale         = 1;

%% StaticEarthSensor>EarthSensorElement
function [a,poly1] = EarthSensorElement(r,n,p,c)

poly1 = polyshape(p(1,:),p(2,:));
a     = linspace(0,2*pi-2*pi/n,n);

x     = r*cos(a) + c(1);
y     = r*sin(a) + c(2);

poly2 = polyshape(x,y);
poly3 = intersect(poly1,poly2);

a     = area(poly3);


%% Copyright
%   Copyright (c) 2019 Princeton Satellite Systems, Inc.
%   All rights reserved.