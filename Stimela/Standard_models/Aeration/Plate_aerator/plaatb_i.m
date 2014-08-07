function [B,x0,U] = plaatb_i(plaatb_file)
% [B,x0,U] = plaatb_i(plaatb_file)
%   initialisation of model plaatb
%   B   Model size
%   x0  default initial state
%   U   measuerement list
%
% Stimela, 2004

% © Kim van Schagen,

U = st_Varia('LongNames'); % default with long Names

% Get Model parameter file for parameter specific sizes
plaatb_fileEcht = chckFile(plaatb_file);
P = st_getPdata(plaatb_fileEcht, 'plaatb');

% Parameters in P can now be used to determine B and x0


%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill B and x0 

NumCel = P.NumCel;

% initialisation
B.CStates=11*NumCel;        % number of continous states
B.DStates=0;        % number of discrete states
B.Setpoints=0;      % number of extra setpoints
B.Measurements= 15*(NumCel+1);  % number of extra measurements
B.Direct=1;         % direct feedthrough (yes=1, no=0);
B.SampleTime=0;     % SampleTime for discrete states (-1 = inherited)

              % collumn vector with the same length as B_CStates + 
x0 = zeros(B.CStates+B.DStates,1);
x0(1) = 0.00001;

%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
