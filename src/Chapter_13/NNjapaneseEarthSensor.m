%% Demonstrate LEO static segmented Earth Sensor using a neural network.
% The neural network is trained using known roll and pitch.

degToRad    = pi/180;
rE          = 6378.14;
jD0         = 2459855.22759992;
el          = [6796.09601357439 0.901411020464568 2.85901984679868...
               1.64265231211276 0.000612135990692413 -0.986951254735983];
d           = SegmentedEarthSensor;
[r,v,t]     = RVFromKepler(el);
rMean       = mean(vecnorm(r));
qECIToLVLH  = QLVLH(r,v);
n           = 20;
roll        = linspace(-6,6,n);
pitch       = linspace(-6,6,n);
i           = 1;
y           = zeros(40,n*n);
x           = zeros(2,n*n);

SegmentedEarthSensor(qECIToLVLH(:,1),r(:,1),d)

for j = 1:n  
  for k = 1:n
    rJ          = roll(j);
    pK          = pitch(k);
    mRoll       = [1 0 0;0 cosd(rJ) -sind(rJ);0 sind(rJ) cosd(rJ)];
    mPitch      = [cosd(pK) 0 -sind(pK);0 1 0;sind(pK) 0 cosd(pK)];
    qLVLHToBody = Mat2Q(mRoll*mPitch);
    qECIToBody  = QMult(qECIToLVLH(:,1),qLVLHToBody);

    y(:,i)      = SegmentedEarthSensor(qECIToBody,r(:,1),d);
    x(:,i)      = [roll(j);pitch(k)];
    i           = i + 1;
  end
end

% Neural net training data

net       = feedforwardnet(20); 

net       = configure( net, y, x );
net.layers{1}.transferFcn = 'poslin'; % purelin
net.name  = 'Earth Sensor';
net       = train(net,y,x);
c         = sim(net,y);
leg       = {'True' 'Neural Net'};

Plot2D(1:size(c,2),[x;c],'Set',{'Roll' 'Pitch'},'Neural Network',...
        'lin',{'[1 3]' '[2 4]'},[],[],[],[],{leg leg})
    
yS = zeros(4,size(y,2));
for k = 1:4
  j = 10*k-9:10*k;
  yS(k,:) = mean(y(j,:));
end
yL = {'Roll' 'Pitch' 'y_1' 'y_2' 'y_3' 'y_4'};
PlotSet(1:size(c,2),[x;yS],'x label','Set','y label',yL,'figure title','Neural Network Data')
