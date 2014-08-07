function [B,x0,U] = iexexc_i(iexexc_file)
% [B,x0,U] = iexexc_i(iexexc_file)
%   initialisation of model iexexc
%   B   Model size
%   x0  default initial state
%   U   measuerement list
%
% Stimela, 2004

% © Kim van Schagen,

U = st_Varia('LongNames'); % default with long Names

% Get Model parameter file for parameter specific sizes
iexexc_fileEcht = chckFile(iexexc_file);
P = st_getPdata(iexexc_fileEcht, 'iexexc');
K= P.K;
n= P.n;

% Parameters in P can now be used to determine B and x0


%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill B and x0 

% initialisation
B.CStates=2*P.NumCel;        % number of continous states
B.DStates=0;        % number of discrete states
B.Setpoints=1;      % number of extra setpoints
B.Measurements= 2*(P.NumCel+2);  % number of extra measurements
B.Direct=1;         % direct feedthrough (yes=1, no=0);
B.SampleTime=0;     % SampleTime for discrete states (-1 = inherited)

q0=K*0.00000000000001^n;
x0=[0.00000000000001*ones(P.NumCel,1); q0*ones(P.NumCel,1)];              % collumn vector with the same length as B_CStates + 

%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
