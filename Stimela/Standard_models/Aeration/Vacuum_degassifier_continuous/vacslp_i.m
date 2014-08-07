function [B,x0,U] = vacslp_i(vacslp_file)
% [B,x0,U] = vacslp_i(vacslp_file)
%   initialisation of model vacslp
%   B   Model size
%   x0  default initial state
%   U   measuerement list
%
% Stimela, 2004

% © Kim van Schagen,

U = st_Varia('LongNames'); % default with long Names

% Get Model parameter file for parameter specific sizes
vacslp_fileEcht = chckFile(vacslp_file);
P = st_getPdata(vacslp_fileEcht, 'vacslp');

% Parameters in P can now be used to determine B and x0


%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill B and x0 

% initialisation
B.CStates=11*P.NumCel+5;        % number of continous states
B.DStates=0;        % number of discrete states
B.Setpoints=0;      % number of extra setpoints
B.Measurements= 36*(P.NumCel+1);  % number of extra measurements
B.Direct=1;         % direct feedthrough (yes=1, no=0);
B.SampleTime=0;     % SampleTime for discrete states (-1 = inherited)

x0 = [0.0000001*ones(P.NumCel,1);0.0000001*ones(P.NumCel,1);0.0000005*ones(P.NumCel,1);0.0000001*ones(P.NumCel,1);0.0000001*ones(P.NumCel,1);0.0000001;0.0000001;0.0000001;0.0000001;0.0000001;0.0000001*ones(P.NumCel,1);0.0000002*ones(P.NumCel,1);0.0000001*ones(P.NumCel,1);0.0000001*ones(P.NumCel,1);zeros(P.NumCel,1);zeros(P.NumCel,1)];              % collumn vector with the same length as B_CStates + 

%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
