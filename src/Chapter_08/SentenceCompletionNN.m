%% Train and test the sentence completion neural net
% Loads the Sentences mat-file.
%% See also
% PrepareSequences, sequenceInputLayer, bilstmLayer, fullyConnectedLayer,
% softmaxLayer, classificationLayer, classify

%% Load the data
s = load('Sentences');
n = length(s.c);        % number of sentences

% Make sure the sequences are valid. One in every 5 is complete.
for k = 1:10
  fprintf('Category: %d',s.c(k));
  fprintf('%5d',s.nZ{k})
  fprintf('\n')
  if( mod(k,5) == 0 )
    fprintf('\n')
  end
end

%% Set up the network
numFeatures = 1;
numHiddenUnits = 200;

numClasses = 2;

% Good results with validation frequency of 10 and 200 hidden units
layers = [ ...
    sequenceInputLayer(numFeatures)
    bilstmLayer(numHiddenUnits,'OutputMode','sequence')
    dropoutLayer(0.2)
    bilstmLayer(numHiddenUnits,'OutputMode','last')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];
disp(layers)

%% Train the network
kTrain      = randperm(n,0.85*n);
xTrain      = s.nZ(kTrain);             % sentence indices, in order
yTrain      = categorical(s.c(kTrain)); % complete or not?

% Test this network - results show overfitting
kTest       = setdiff(1:n,kTrain);
xTest       = s.nZ(kTest);
yTest       = categorical(s.c(kTest));
  
options = trainingOptions('adam', ...
    'MaxEpochs',240, ...
    'GradientThreshold',1, ...
    'ValidationData',{xTest,yTest}, ...
    'ValidationFrequency',10, ...
    'Verbose',0, ...
    'Plots','training-progress');
  
disp(options)

net         = trainNetwork(xTrain,yTrain,layers,options);
yPred       = classify(net,xTest);

% Calculate the classification accuracy of the predictions.
acc         = sum(yPred == yTest)./numel(yTest);
disp('All')
disp(acc);

j       = find(yTest == '1');
yPredC  = classify(net,xTest(j));
accC    = sum(yPredC == yTest(j))./numel(yTest(j));
disp('Correct')
disp(accC);



%% Copyright
% Copyright (c) 2019, 2022 Princeton Satellite Systems, Inc.
% All rights reserved.
