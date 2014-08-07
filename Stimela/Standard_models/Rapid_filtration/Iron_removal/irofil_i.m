function [B,x0,U] = irofil_i(irofil_file)
% [B,x0,U] = irofil_i(irofil_file)
%   initialisation of model irofil
%   B   Model size
%   x0  default initial state
%   U   measuerement list
%
% Stimela, 2004

% © Kim van Schagen,

U = st_Varia('LongNames'); % default with long Names

% Get Model parameter file for parameter specific sizes
irofil_fileEcht = chckFile(irofil_file);
P = st_getPdata(irofil_fileEcht, 'irofil');

% Parameters in P can now be used to determine B and x0


%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill B and x0 

% initialisation
B.CStates=7*(P.NumCel);        % number of continous states
B.DStates=0;        % number of discrete states
B.Setpoints=1;      % number of extra setpoints
B.Measurements= 7*(P.NumCel);  % number of extra measurements
B.Direct=1;         % direct feedthrough (yes=1, no=0);
B.SampleTime=0;     % SampleTime for discrete states (-1 = inherited)

x0=[zeros(2*(P.NumCel),1); 10*ones(2*(P.NumCel),1); 61*3*ones(1*(P.NumCel),1); 44*0.9*ones(1*(P.NumCel),1); zeros(1*(P.NumCel),1)] ;              % collumn vector with the same length as B_CStates + 

%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
