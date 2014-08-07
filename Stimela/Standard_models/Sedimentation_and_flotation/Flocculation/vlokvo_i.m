function [B,x0,U] = vlokvo_i(vlokvo_file)
% [B,x0,U] = vlokvo_i(vlokvo_file)
%   initialisation of model vlokvo
%   B   Model size
%   x0  default initial state
%   U   measuerement list
%
% Stimela, 2004

% © Kim van Schagen,

U = st_Varia('LongNames'); % default with long Names

% Get Model parameter file for parameter specific sizes
vlokvo_fileEcht = chckFile(vlokvo_file);
P = st_getPdata(vlokvo_fileEcht, 'vlokvo');

% Parameters in P can now be used to determine B and x0


%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill B and x0 

% initialisation
B.CStates=P.NumCel;        % number of continous states
B.DStates=0;        % number of discrete states
B.Setpoints=0;      % number of extra setpoints
B.Measurements= P.NumCel;  % number of extra measurements
B.Direct=1;         % direct feedthrough (yes=1, no=0);
B.SampleTime=0;     % SampleTime for discrete states (-1 = inherited)

x0 =zeros(P.NumCel,1); 
%x0=[];              % collumn vector with the same length as B_CStates + 

%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
