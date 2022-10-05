%% Demonstrate LEO static Earth Sensor using a neural network.
% The neural network is trained using known roll and pitch.

degToRad    = pi/180;
rE          = 6378.14;
jD0         = 2459855.22759992;
el          = [6796.09601357439 0.901411020464568 2.85901984679868...
               1.64265231211276 0.000612135990692413 -0.986951254735983];
d           = StaticEarthSensor;
[r,v,t]     = RVFromKepler(el);
rMean       = mean(vecnorm(r));
qECIToLVLH  = QLVLH(r,v);
d.el        = 64*ones(1,4)*degToRad;
d.az        = [0 pi/2 pi 3*pi/2] + pi/4;
d.pAng      = 4*[  1     1    -1    -1
                   1    -1    -1     1];

n           = 20;
roll        = linspace(-6,6,n);
pitch       = linspace(-6,6,n);
i           = 1;
y           = zeros(4,n*n);
x           = zeros(2,n*n);

StaticEarthSensor(qECIToLVLH(:,1),r(:,1),d)

for j = 1:n  
  for k = 1:n
    rJ          = roll(j);
    pK          = pitch(k);
    mRoll       = [1 0 0;0 cosd(rJ) -sind(rJ);0 sind(rJ) cosd(rJ)];
    mPitch      = [cosd(pK) 0 -sind(pK);0 1 0;sind(pK) 0 cosd(pK)];
    qLVLHToBody = Mat2Q(mRoll*mPitch);
    qECIToBody  = QMult(qECIToLVLH(:,1),qLVLHToBody);

    y(:,i)      = StaticEarthSensor(qECIToBody,r(:,1),d);
    x(:,i)      = [roll(j);pitch(k)];
    i           = i + 1;
  end
end

% Neural net training 
net = feedforwardnet(20); % Geneate the neural net structure
net = configure( net, y, x ); % Configure based on inputs and outputs

net.layers{1}.transferFcn = 'poslin'; % Set as purelin
net.name  = 'Earth Sensor';
net       = train(net,y,x); % Train the network
c         = sim(net,y); % Simulate the neural network
leg       = {'True' 'Neural Net'};

PlotSet(1:size(c,2),[x;c],'x label','Set',...
  'y label',{'Roll' 'Pitch'},'figure title','Neural Network',...
  'plot set',{[1 3],[2 4]},'legend',{leg leg});
  
yL = {'Roll' 'Pitch' 'y_1' 'y_2' 'y_3' 'y_4'};
PlotSet(1:size(c,2),[x;y],'x label','Set','y label',yL,'Neural Network Data')

%% Testing
n     = length(t);
roll  = 2;
pitch = 0;
c     = zeros(2,n);
for k = 1:n
  rJ          = roll;
  pK          = pitch;
  mRoll       = [1 0 0;0 cosd(rJ) -sind(rJ);0 sind(rJ) cosd(rJ)];
  mPitch      = [cosd(pK) 0 -sind(pK);0 1 0;sind(pK) 0 cosd(pK)];
  qLVLHToBody = Mat2Q(mRoll*mPitch);
  qECIToBody  = QMult(qECIToLVLH(:,k),qLVLHToBody);
  y           = StaticEarthSensor(qECIToBody,r(:,k),d);
  c(:,k)    	= sim(net,y');
end

[t,tL]  = TimeLabel(t);
s       = sprintf('Roll = %8.2f deg Pitch = %8.2f deg',roll,pitch);

PlotSet(t,c,'x label',tL,'y label', {'Roll' 'Pitch'},'figure title',s)


%% Copyright
%   Copyright (c) 2019 Princeton Satellite Systems, Inc.
%   All rights reserved.