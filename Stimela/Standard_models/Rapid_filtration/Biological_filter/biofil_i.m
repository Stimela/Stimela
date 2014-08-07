function [B,x0,U] = biofil_i(biofil_file)
% [B,x0,U] = biofil_i(biofil_file)
%   initialisation of model biofil
%   B   Model size
%   x0  default initial state
%   U   measuerement list
%
% Stimela, 2004

% © Kim van Schagen,

U = st_Varia('LongNames'); % default with long Names

% Get Model parameter file for parameter specific sizes
biofil_fileEcht = chckFile(biofil_file);
P = st_getPdata(biofil_fileEcht, 'biofil');

% Parameters in P can now be used to determine B and x0


%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill B and x0 
NumCel = P.NumCel;
XDOC0=P.X0_DOC;


% initialisation
B.CStates=11*(NumCel);        % number of continous states
B.DStates=0;        % number of discrete states
B.Setpoints=1;      % number of extra setpoints
B.Measurements= 11*(NumCel);  % number of extra measurements
B.Direct=1;         % direct feedthrough (yes=1, no=0);
B.SampleTime=0;     % SampleTime for discrete states (-1 = inherited)
B.WaterIn  = 1;     % Incoming water Flow (yes=1, no=0)
B.WaterOut  = 1;    % Outgoing water Flow (yes=1, no=0)


%x0=[];              % collumn vector with the same length as B_CStates + 
x0 = [1.2*ones(NumCel,1);1.2*ones(NumCel,1);XDOC0*ones(NumCel,1);10*ones(NumCel,1);10*ones(NumCel,1);31*ones(NumCel,1);31*ones(NumCel,1);183*ones(NumCel,1);183*ones(NumCel,1);1*ones(NumCel,1);1*ones(NumCel,1)]; % begin toestand (even lang als Bl(1)+Bl(2))

%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
