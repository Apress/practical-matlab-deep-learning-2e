%% Music with Long Short-Term Memory (LSTM) layer
% See also Music_LSTM>save_as_midi, Music_LSTM>decode_label, Music_LSTM>generate

% Clear workspace
clear

%% Load and process data
% format: [st, pitch, dur, ks, ts, f]
% st  = start time (ignored)
% dur = duration
% ks  = key signature (ignored)
% ts  = time signature (ignored)
% f   = fermata (ignored)

mats = load('chorales_testmat.mat');
fn = fieldnames(mats);

% Store our data (pitches and durations) in a cell array.
chorale_cell = cell(numel(fn),1);
for k=1:numel(fn)
    chorale_cell{k} = mats.(fn{k})(:,2:3);  % get pitch + duration
end

% Get set of unique pitches and set of unique durations
big_seq = cat(1, chorale_cell{:});
pitch_labels = sort(unique(big_seq(:,1)));
dur_labels = sort(unique(big_seq(:,2)));
dl = length(dur_labels);
np = length(pitch_labels);

% Get indices corresponding to each musical event (pitch, duration)'s
% location in the label arrays.
% Use these indices along with encode_pd to generate a single label for
% each event.
% Label cell contains these "encoded" labels.
label_cell = cell(numel(fn, 1));
for i=1:numel(chorale_cell)
    seq = chorale_cell{i};
    ls = length(seq);
    chorale_labels = zeros(ls,1);
    for j = 1:ls
        pi = find(pitch_labels == seq(j,1));
        di = find(dur_labels == seq(j, 2));
        chorale_labels(j,1) = encode_pd(pi, di, dl);
    end
    label_cell{i} = chorale_labels;
end

% Divide data into input (X) and output (Y), where Y is just
% X shifted by 1 to the future. 
[X, Y] = get_xy(label_cell);

% Convert labels to categorical data for classification.
% Note that we have a class for each possible combination of pitches
% and durations (20*8 = 160), intead of just for the combinations that appear 
% in the dataset. This may allow for more interesting pieces that contain
% patterns not seen in the training set. 
Y = cellfun(@(x) categorical(x, 1:np*dl) ,Y,'UniformOutput',false);


%% Define LSTM and visualize
% adapted from https://www.mathworks.com/help/deeplearning/ug/time-series-forecasting-using-deep-learning.html
% define input, layer and output sizes
num_hidden_units = 128;
input_shape = 1; % num features = 1, since we have combined our 2 features
num_outputs = np*dl;

% Define model layers
layers = [ ...
    sequenceInputLayer(input_shape, Name='seq in')
    lstmLayer(num_hidden_units,'OutputMode','sequence', Name='lstm')
    softmaxLayer
    fullyConnectedLayer(num_outputs, Name='fc1')
    softmaxLayer
    fullyConnectedLayer(num_outputs, Name='fc2')
    softmaxLayer
    classificationLayer(Name='co')];

% optional L2 regularization
layers(4) = setL2Factor(layers(4),'Weights',2);
layers(6) = setL2Factor(layers(6),'Weights',2);

% Visualize the network
analyzeNetwork(layers)

%% Training
% Define training parameters
max_epochs = 400;
% use mini batch size of 1 to avoid padding
mini_bs = 1;
options = trainingOptions('adam', ...
    'MaxEpochs',max_epochs, ...
    'MiniBatchSize', mini_bs, ...
    'InitialLearnRate',0.01, ...
    'LearnRateSchedule','piecewise', ...
    'Shuffle', 'every-epoch',...
    'Verbose',0, ...
    'LearnRateDropPeriod',100, ...
    'LearnRateDropFactor',0.5, ...
    'Plots','training-progress');

% Train LSTM
net = trainNetwork(X,Y,layers,options);
disp('Training Complete')

%% Generate music
% Get model going with training set, then generate new music
generate(net, X{50}, pitch_labels, dur_labels, 'new_test50_simple', 'na', 2);
generate(net, X{25}, pitch_labels, dur_labels, 'new_test25_simple', 'na', 2);
generate(net, X{10}, pitch_labels, dur_labels, 'new_test10_simple', 'na', 2);

function generate(net, test_seq, pitches, durs, name, samp_mode, gen_amt)
% Uses trained LSTM to generate new music. Saves outputs as MIDI files
% to be played and or visualized in an application that supports MIDI
%
% - net: trained LSTM
% - test_seq: sequence from the training set to use as seed
% - pitches: possible pitches
% - durs: possible durations
% - name: output name
% - samp mode: 'greedy' for greedy sampling. else: regular. 
% - gen_amt: sets the amount to generate as a function of the input size.
% - outputs: are described in the within function comments. saves three midi
%            files

    test1 = test_seq;
    % seed size
    hs = ceil(length(test1)/2);
    % set amount you want to generate
    num_test = gen_amt*hs;
    for i = 1:num_test
        if i == 1
            % use first half of song for the first prediction
            history = test1(:,1:hs); 
            % to see what happens if only first event of seed provided
            %history = test1(:,1); 
        else
            % concatenate past history with last prediction to continue
            % generating
            history = [history, last_pred]; 
        end
        % make prediction and update hidden state
        [net,pred] = predictAndUpdateState(net,history,'ExecutionEnvironment','cpu');
        last_preds = pred(:, end); % get last prediction for concatenation
        % In greedy mode, you take the highest probability event
        if strcmp(samp_mode, 'greedy')
            [max_v, idx] = max(last_preds); % greedy
            last_pred = idx;
        else
            % in sampling mode, you sample according to the distribution given by the model
            last_pred = randsample(length(last_preds),1,true,last_preds);
        end
        
    end
    % concatenate last prediction
    history = [history, last_pred]; 

    % save the entire training example
    [ps,ds] = decode_label(test1, pitches, durs);
    save_as_midi(ps, ds, strcat(name, '_samp_class_full_test'));
    % save the first half of the example to see where generation starts
    [ps,ds] = decode_label(test1(:,1:hs), pitches, durs);
    save_as_midi(ps, ds, strcat(name,'_samp_class_in'));
    %save the input plus the generated output. 
    [ps,ds] = decode_label(history, pitches, durs);
    save_as_midi(ps, ds, strcat(name, '_samp_class_in_plus_gen'));
end

function [x, y]= get_xy(seqs)
  % Converts each sequence to input (x) and output (y) for our next step
  % prediction objective. output is input shifted forward by 1.
    x = cell(length(seqs),1);
    y = cell(length(seqs),1);
    for i = 1:length(seqs)
        x{i} = seqs{i}(1:end-1,:);
        y{i} = seqs{i}(2:end,:);
    end
    x = cellfun(@transpose,x,'UniformOutput',false);
    y = cellfun(@transpose,y,'UniformOutput',false);
end

function label = encode_pd(i,j, dl)
  % Creates a label for a given pitch and duration combination
  %
  % i = pitch index --> i = 1:length(pitch_labels)
  % j = duration index --> j = 1:length(dur_labels)
  % dl = number of possible durations = length(dur_labels)
  %
  % label for i,j combination = (i-1)*length(dur_labels) + j
    label = (i-1)*dl + j;
end

function [pitch,duration] = decode_label(label, pitches, durations)
  % Reverses encode_pd to get pitch and duration from the label.
  % Note that label is a vector here (from the model output)
  %
  % pitches = possible pitches
  % durations = possible durations
    dl = length(durations);
    j = mod(label, dl);
    % if j = dl, label = i*dl, so label%dl = 0. 
    % For our math to work out, we want j = dl in this case, not 0. 
    % so set all entries p where the j(p) = 0 to dl. 
    % since matlab indexing starts at 1, we don't have to worry about
    % a case where j actually equals 0.
    j(find(j == 0)) = dl; 
    i = (label - j + dl)/dl;
    pitch = pitches(i);
    duration = durations(j);
end

function save_as_midi(pitches, durs, name)
% Converts generated output to nmat and saves as midi files.
% Uses nmat functionality from MIDI Toolbox:
%
% https://www.jyu.fi/hytk/fi/laitokset/mutku/en/research/materials/miditoolbox
%
% [:, st(b) dur(b) channel pitch velocity st(s) dur(s)] <-- MIDI Toolbox nmat format
% b: beats, s: seconds
% pitches and durs (durations) generated by our model
% name: output file name
    out_s = length(pitches);
    nmat = zeros(out_s, 7);
    nmat(:,2) = durs; % duration 
    nmat(:, 4) = pitches; % pitch 

    onsets = zeros(out_s,1);
    onsets(1) = 0; % onsets start at 0 in nmat format
    for i = 1:out_s-1
        % get current onset by adding previous duration to previous onset
        onsets(i+1) = onsets(i) + durs(i);
    end
    nmat(:,1) = onsets; % onsets
    % channel range: 1-16, choice is arbitrary here with one channel
    nmat(:,3) = ones(out_s,1); 
    velocity = 50; %  1-127
    % velocity (volume), choice is somewhat arbitrary here
    nmat(:,5) = velocity*ones(out_s,1); 
    % these determine tempo
    t_ratio = 15;
    nmat(:,6) = nmat(:,1)/t_ratio; % start time (s) 
    nmat(:,7) = nmat(:,2)/t_ratio; % duration (s)
    writemidi(nmat, strcat(name,'.midi'));
end

%% Copyright
% Copyright (c) 2022 Princeton Satellite Systems, Inc.
% All rights reserved.
