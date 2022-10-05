%% Train the lander network
% See also TitanLanderClass, rlTrainingOptions, train, sim, TimeLabel, PlotSet

env     = TitanLanderClass;

obsInfo = getObservationInfo(env);
actInfo = getActionInfo(env);
disp(obsInfo);
disp(actInfo);

initOpts = rlAgentInitializationOptions('NumHiddenUnit',128);
agent     = rlDDPGAgent(obsInfo,actInfo,initOpts);
agent.AgentOptions.NoiseOptions.StandardDeviationDecayRate = 1e-5;
agent.AgentOptions.NoiseOptions.StandardDeviationMin = 0.001*agent.ActionInfo.UpperLimit;
actorNet  = getModel(getActor(agent));
criticNet = getModel(getCritic(agent));

NewFigure('Actor Network')
plot(layerGraph(actorNet))
NewFigure('Critic Network')
plot(layerGraph(criticNet))
disp('Critic Network')
disp(criticNet.Layers)
disp('Actor Network')
disp(actorNet.Layers)

doTraining  = true;
maxsteps    = 2520;
maxepisodes = 5000;

trainingOpts = rlTrainingOptions(...
    'MaxEpisodes',maxepisodes,...
    'MaxStepsPerEpisode',maxsteps,...
    'Verbose',true,...
    'Plots','training-progress',...
    'StopTrainingCriteria','EpisodeReward',...
    'StopTrainingValue',595);

if( doTraining )   
    % Train the agent
    trainingStats = train(agent,env,trainingOpts);
end

%% Simulate 
simOptions = rlSimulationOptions('MaxSteps', 2000);
experience = sim(env,agent, simOptions);
t = experience.Observation.LanderStates.Time';
x = experience.Observation.LanderStates.Data;
u = experience.Action.Control.Data;
u =[0 reshape(u,1,size(u,3))]; % Scale
x = reshape(x,3,size(x,3));
xP = [x;u];

yL = {'H' 'V_R' 'V_T' '\alpha'};
xP(1,:) = xP(1,:) - 2575;
[t,tL]  = TimeLabel(t*env.Ts);
PlotSet(t,xP,'x label',tL,'y label',yL,'figure title','Time history');


%% Copyright
% Copyright (c) 2019, 2022 Princeton Satellite Systems, Inc.
% All rights reserved.
