function [B,x0,U] = nitfil_i(nitfil_file)
% [B,x0,U] = nitfil_i(nitfil_file)
%   initialisation of model nitfil
%   B   Model size
%   x0  default initial state
%   U   measuerement list
%
% Stimela, 2004

% © Kim van Schagen,

U = st_Varia('LongNames'); % default with long Names

% Get Model parameter file for parameter specific sizes
nitfil_fileEcht = chckFile(nitfil_file);
P = st_getPdata(nitfil_fileEcht, 'nitfil');

% Parameters in P can now be used to determine B and x0


%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill B and x0 
NumCel = P.NumCel;
Xns0=P.X0_Ns;
Xnb0=P.X0_Nb;

% initialisation
B.CStates=14*(NumCel);        % number of continous states
B.DStates=0;        % number of discrete states
B.Setpoints=1;      % number of extra setpoints
B.Measurements= 14*(NumCel);  % number of extra measurements
B.Direct=1;         % direct feedthrough (yes=1, no=0);
B.SampleTime=0;     % SampleTime for discrete states (-1 = inherited)

%x0=[];              % collumn vector with the same length as B_CStates + 
x0 = [0.5*ones(NumCel,1);0.5*ones(NumCel,1);0.1*ones(NumCel,1);0.1*ones(NumCel,1);Xns0*ones(NumCel,1);Xnb0*ones(NumCel,1);1*ones(NumCel,1);1*ones(NumCel,1);11.44*ones(NumCel,1);11.44*ones(NumCel,1);244*ones(NumCel,1);244*ones(NumCel,1);1*ones(NumCel,1);1*ones(NumCel,1)]; % begin toestand (even lang als Bl(1)+Bl(2))

%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
