function [B,x0,U] = ws2opc_i(ws2opc_file)
% [B,x0,U] = ws2opc_i(ws2opc_file)
%   initialisation of model ws2opc
%   B   Model size
%   x0  default initial state
%   U   measuerement list
%
% Stimela, 2004

% © Kim van Schagen,

U = st_Varia('LongNames'); % default with long Names

% Get Model parameter file for parameter specific sizes
ws2opc_fileEcht = chckFile(ws2opc_file);
P = st_getPdata(ws2opc_fileEcht, 'ws2opc');

% Parameters in P can now be used to determine B and x0


%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill B and x0 

% initialisation
B.CStates=0;        % number of continous states
B.DStates=0; %        % number of discrete states
B.Setpoints=0;      % number of extra setpoints
B.Measurements= 0;  % number of extra measurements
B.WaterIn  = 0;     % Incoming water Flow (yes=1, no=0)
B.WaterOut  = 0;    % Outgoing water Flow (yes=1, no=0)
B.Direct=0;         % direct feedthrough (yes=1, no=0);
B.SampleTime=0;     % SampleTime for discrete states (-1 = inherited, -2 = next hit in flag=4)

x0=[]; %P.Default;              % collumn vector with the same length as B_CStates + 


%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

