function [B,x0,U] = verwrk_i(verwrk_file)
% [B,x0,U] = verwrk_i(verwrk_file)
%   initialisation of model verwrk
%   B   Model size
%   x0  default initial state
%   U   measuerement list
%
% Stimela, 2004

% © Kim van Schagen,

U = st_Varia('LongNames'); % default with long Names

% Get Model parameter file for parameter specific sizes
verwrk_fileEcht = chckFile(verwrk_file);
P = st_getPdata(verwrk_fileEcht, 'verwrk');

% Parameters in P can now be used to determine B and x0


%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill B and x0 

% initialisation
B.CStates=0;        % number of continous states
B.DStates=0;        % number of discrete states
B.Setpoints=P.nQ;      % number of extra setpoints
B.Measurements= (P.nQ-1)*U.Number;  % number of extra measurements
B.Direct=1;         % direct feedthrough (yes=1, no=0);
B.SampleTime=-1;     % SampleTime for discrete states (-1 = inherited)

x0=[];              % collumn vector with the same length as B_CStates + 

%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
