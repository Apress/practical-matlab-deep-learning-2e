%% Equality constraints for the landing for a 2D flat planet problem.
%   The constraint is the terminal altitude and velocities. The velocity
%   must be zero. The function integrates the trajectory to find the
%   terminal values.
%% Form
%   [cIn, cEq, s] = TitanLandingConst2D( x, d )
%
%% Inputs
%   x       (:,1)   [alpha;thrust]
%   d        (.)    Data structure describing the vehicle model
%
%% Outputs
%   cIn    (1,1)   Inequality constraints
%   cEq    (3,1)   Equality constraints

function [cIn, cEq] = TitanLandingConst2D( u, d )

rTitan  = 2575;
[~,xP]  = Simulation2DTitan( d.x, d.t, d, u );

% We don't have any nonlinear inequality contraints
cIn = [];

% Equality constraint
cEq = [xP(1,end)-rTitan;xP(2:3,end)];

%% Copyright
% Copyright (c) 2019, 2022 Princeton Satellite Systems, Inc.
% All rights reserved.
