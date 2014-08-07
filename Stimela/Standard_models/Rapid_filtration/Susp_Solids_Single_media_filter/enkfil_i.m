function [B,x0,U] = enkfil_i(enkfil_file)
% [B,x0,U] = enkfil_i(enkfil_file)
%   initialisation of model enkfil
%   B   Model size
%   x0  default initial state
%   U   measuerement list
%
% Stimela, 2004

% © Kim van Schagen,

U = st_Varia('LongNames'); % default with long Names

% Get Model parameter file for parameter specific sizes
enkfil_fileEcht = chckFile(enkfil_file);
P = st_getPdata(enkfil_fileEcht, 'enkfil');

% Parameters in P can now be used to determine B and x0


%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill B and x0 

% initialisation
B.CStates=2*(P.NumCel);        % number of continous states
B.DStates=0;        % number of discrete states
B.Setpoints=1;      % number of extra setpoints
B.Measurements= 2*(P.NumCel);  % number of extra measurements
B.Direct=1;         % direct feedthrough (yes=1, no=0);
B.SampleTime=0;     % SampleTime for discrete states (-1 = inherited)
B.WaterIn=1;
B.WaterOut=1;

x0=zeros(2*(P.NumCel),1);              % collumn vector with the same length as B_CStates + 

%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
