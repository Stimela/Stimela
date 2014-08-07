function [B,x0,U] = regena_i(regena_file)
% [B,x0,U] = regena_i(regena_file)
%   initialisation of model regena
%   B   Model size
%   x0  default initial state
%   U   measuerement list
%
% Stimela, 2004

% © Kim van Schagen,

U = st_Varia('LongNames'); % default with long Names

% Get Model parameter file for parameter specific sizes
regena_fileEcht = chckFile(regena_file);
P = st_getPdata(regena_fileEcht, 'regena');

% Parameters in P can now be used to determine B and x0


%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill B and x0 

% initialisation
B.CStates=0;        % number of continous states
B.DStates=1;        % number of discrete states
B.Setpoints=0;      % number of extra setpoints
B.Measurements= 1;  % number of extra measurements
B.WaterIn= 0;     % Incoming water Flow (yes=1, no=0)
B.WaterOut= 0;    % Outgoing water Flow (yes=1, no=0)
B.Direct=0;         % direct feedthrough (yes=1, no=0);
B.SampleTime= -2;     % SampleTime for discrete states (-1 = inherited)


x0=[P.Tst*3600*24-P.TL*3600*24];              % collumn vector with the same length as B_CStates + 

%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
