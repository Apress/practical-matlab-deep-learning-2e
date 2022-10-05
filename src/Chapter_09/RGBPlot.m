%% Script to create an RGP plot
% Creates a new figure and plots the rgbs variable.
%
% See also NewFigure, subplot, plot

NewFigure('RGB')
c = 'rgb';
for k = 1:3
  subplot(3,1,k);
  plot(1:2401,rgbs(:,k),c(k))
  grid on
end

%% Copyright
% Copyright (c) 2022 Princeton Satellite Systems, Inc.
% All rights reserved.
