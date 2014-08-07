function [B,x0,U] = buffer_i(buffer_file)
% [B,x0,U] = buffer_i(buffer_file)
%   initialisation of model buffer
%   B   Model size
%   x0  default initial state
%   U   measuerement list
%
% Stimela, 2004

% � Kim van Schagen,

U = st_Varia('LongNames'); % default with long Names

% Get Model parameter file for parameter specific sizes
buffer_fileEcht = chckFile(buffer_file);
P = st_getPdata(buffer_fileEcht, 'buffer');

% Parameters in P can now be used to determine B and x0


%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill B and x0 

% initialisation
B.CStates=1;        % number of continous states % only volume
B.DStates=0;        % number of discrete states
B.Setpoints=1;      % number of extra setpoints
B.Measurements= 1;  % number of extra measurements
B.WaterIn  = 1;     % Incoming water Flow (yes=1, no=0)
B.WaterOut  = 1;    % Outgoing water Flow (yes=1, no=0)
B.Direct=1;         % direct feedthrough (yes=1, no=0);
B.SampleTime=0;     % SampleTime for discrete states (-1 = inherited, -2 = next hot in flag=4)

x0(1)=P.InitialH*P.Surface;              %

%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
