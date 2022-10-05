%% SEGMENTEDEARTHSENSOR Earth sensor model
% The boresight is along +z. It will draw a picture if there are no 
% outputs. 
%
% Type SegmentedEarthSensor for a demo.
%
%% Form:
%   y = SegmentedEarthSensor(q,r,d)
%
%% Inputs
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
%   y   (:,1)	Detector outputs
%

function y = SegmentedEarthSensor(q,r,d)

% Demo
if( nargin < 1 )
  if( nargout == 0 )
    Demo
  else
    y = DefaultDataStructure;
  end
  return
end

qECIToSensor  = QMult(q,d.qBodyToSensor);

uNadir        = QForm(qECIToSensor,Unit(r));
cEarth        = d.fL*uNadir(1:2);

% Planet angular width
ang           = asin(d.rPlanet/vecnorm(r));
r             = d.fL*sin(ang);

% Cycle through all the elements
nP            = length(d.az);
poly          = cell(1,nP);
y             = zeros(1,nP);

for k = 1:nP
  az              = d.az(k);
  el              = d.el(k);
  rP              = [cos(az);sin(az)]*el;
  c               = [cos(az) -sin(az);sin(az) cos(az)];
  pK              = rP + c*d.p;
  [y(k), poly{k}] = EarthSensorElement(r,d.n,pK,cEarth);
end

y(y > 0) = 1;

% Default output
if( nargout < 1 )
  r       = vecnorm(r);
	a       = linspace(0,2*pi-2*pi/d.n,d.n);
  x       = r*cos(a) + cEarth(1);
  y       = r*sin(a) + cEarth(2);
  planet  = polyshape(x,y);

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
d   = SegmentedEarthSensor;
r   = [0;0;6700];
SegmentedEarthSensor([1;0;0;0],r,d);

%% StaticEarthSensor>Default Data Structure
function d = DefaultDataStructure

d.n             = 40;
d.nSeg          = 10;
d.p             = [  1     1    -1    -1
                     1    -1    -1     1];
d.az            = [zeros(1,10) (pi/2)*ones(1,10) pi*ones(1,10), (3*pi/2)*ones(1,10)];
d.fL            = 50;
el              = (0:2:18) + d.fL - 12;
d.el            = [el el el el];
d.rPlanet       = 6378.165;
d.qBodyToSensor = [1;0;0;0];

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