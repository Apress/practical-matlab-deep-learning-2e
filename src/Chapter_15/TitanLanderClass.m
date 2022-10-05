classdef TitanLanderClass < rl.env.MATLABEnvironment
    %TITANLANDERCLASS lander with 3 DOF class   
    
    %% Properties (set properties' attributes accordingly)
    properties
        % Specify and initialize environment's necessary properties    
        % Acceleration due to gravity in m/s^2
        
        % Sample time
        Ts        = 10;     

        % Control
        Control = 0;
        
        % Target
        StateTarget = [2575;0;0];
        
        % Initial State
        StateInitial = [2875;0;sqrt(9.142117352579678e+03/2875)];
    end
    
    properties
        % Initialize system State [r;v_r;v_t]
        State = [2875;0;sqrt(9.142117352579678e+03/2875)];
    end
    
    properties(Access = protected)
        % Initialize internal flag to indicate episode termination
        IsDone = false        
    end

    %% Necessary Methods
    methods              
        % Contructor method creates an instance of the environment
        % Change class name and constructor name accordingly
        function this = TitanLanderClass()
            % Initialize Observation settings
            ObservationInfo = rlNumericSpec([3 1]);
            ObservationInfo.Name = 'Lander States';
            ObservationInfo.Description = 'r v_r v_t';
            
            % Initialize Action settings   
            ActionInfo            = rlNumericSpec([1 1]);
            ActionInfo.Name       = 'Control';
            ActionInfo.LowerLimit = 0;
            ActionInfo.UpperLimit =  pi/12;
          
            % The following line implements built-in functions of RL env
            this = this@rl.env.MATLABEnvironment(ObservationInfo,ActionInfo);
            
            % Initialize property values and pre-compute necessary values
            updateActionInfo(this);
        end
        
        % Apply system dynamics and simulates the environment with the 
        % given action for one step.
        function [Observation,Reward,IsDone,LoggedSignals] = step(this,Action)
            LoggedSignals = [];
            
            % Get action
            dRHS        = RHS2DTitan;
            u           = getControl(this,Action);
            dRHS.alpha  = u(1);
             
	          rHS         = @(t,x,d) RHS2DTitan(t,x,d);
            [~, x]      = ode113(rHS, [0 this.Ts], this.State, [], dRHS );
            this.State  = x(end,:)';

            % The observation is the State
            Observation = this.State;

            altitude    = this.State(1) - 2575;
            IsDone      = altitude <= 0.01;
            this.IsDone = IsDone;
            this.Control  = u;

            Reward = newReward(this);

            % Use notifyEnvUpdated to signal that the environment has been
            % update
            notifyEnvUpdated(this);
        end
        
        % Reset environment to initial State and output initial observation
        function InitialObservation = reset(this)
            InitialObservation = this.StateInitial;
            this.State = InitialObservation;
            
            % (optional) use notifyEnvUpdated to signal that the 
            % environment has been updated (e.g. to update visualization)
            notifyEnvUpdated(this);
        end
    end
    %% Optional Methods (set methods' attributes accordingly)
    methods               
        % Helper methods to create the environment
        function control = getControl(~,action)
            control = action;         
        end
        % update the action info based on the allowable controls
        function updateActionInfo(this)
            
        end

        % Reward function
        function Reward = newReward(this)
          h      = this.State(1) - 2575;
          x      = this.State(2:3);

          % Mean heating rate
          if( h < 0 )
            h = 0;
          end
          rho    = TitanAtmosphere(h);
          v      = 1e3*sqrt(x(1)^2 + x(2)^2); % m/s
          dP     = mean(sqrt(rho)*v^3)/6e7;

          % Only care about velocity at zero altitude
          if( h <= 0.01 )
            m = vecnorm(x(1:2));
            c = 1000*exp(-13*m);
          else
            c = 0;
          end
          Reward = -dP + c;
        end
       
        % (optional) Visualization method
        function plot(this)
            % Initiate the visualization
            
            % Update the visualization
            envUpdatedCallback(this)
        end
        
        % (optional) Properties validation through set methods
        function set.State(this,State)
            validateattributes(State,{'numeric'},{'finite','real','vector','numel',3},'','State');
            this.State = double(State(:));
            notifyEnvUpdated(this);
        end        

        function set.StateTarget(this,val)
            validateattributes(val,{'numeric'},{'finite','real','positive','vector','numel',3},'','StateTarget');
            this.StateTarget = val;
        end
        function set.StateInitial(this,val)
            validateattributes(val,{'numeric'},{'finite','real','positive','vector','numel',3},'','StateInitial');
            this.StateInitial = val;
        end
        function set.Ts(this,val)
            validateattributes(val,{'numeric'},{'finite','real','positive','vector','numel',3},'','Ts');
            this.Ts = val;
        end
    end
    
    methods (Access = protected)
        % (optional) update visualization everytime the environment is updated 
        % (notifyEnvUpdated is called)
        function envUpdatedCallback(this)
        end
    end
end

% Copyright
% Copyright (c) 2019, 2022 Princeton Satellite Systems, Inc.
% All rights reserved.
