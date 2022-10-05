function Q3 = QMult( Q2 ,Q1 )
	
%% Multiply two quaternions.
% Q2 transforms from A to B and Q1 transforms from B to C
% so Q3 transforms from A to C. If only one argument is input
% it produces the 4x4 matrix equivalent:
% q3 = Q2*q1;
%
%% Form:
%   Q3 = QMult( Q2 ,Q1 )	
%% Inputs
%   Q2              (4,1)  Quaternion from a to b
%   Q1              (4,1)  Quaternion from b to c
%
%% Outputs
%   Q3              (4,1)  Quaternion from a to c or 4x4 version of q
%


if( nargin == 2 )

  Q3 = [Q1(1,:).*Q2(1,:) - Q1(2,:).*Q2(2,:) - Q1(3,:).*Q2(3,:) - Q1(4,:).*Q2(4,:);...
        Q1(2,:).*Q2(1,:) + Q1(1,:).*Q2(2,:) - Q1(4,:).*Q2(3,:) + Q1(3,:).*Q2(4,:);...
        Q1(3,:).*Q2(1,:) + Q1(4,:).*Q2(2,:) + Q1(1,:).*Q2(3,:) - Q1(2,:).*Q2(4,:);...
        Q1(4,:).*Q2(1,:) - Q1(3,:).*Q2(2,:) + Q1(2,:).*Q2(3,:) + Q1(1,:).*Q2(4,:)];
  
else

  Q3 = [Q2(1), -Q2(2), -Q2(3), -Q2(4);... 
        Q2(2),  Q2(1), -Q2(4),  Q2(3);... 
        Q2(3),  Q2(4),  Q2(1), -Q2(2);...  
        Q2(4), -Q2(3),  Q2(2),  Q2(1)]; 
		
end


%   Copyright (c) 1993, 2022 Princeton Satellite Systems, Inc. 
%   All rights reserved.
