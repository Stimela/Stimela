function [B,x0,U] = torbsc_i(torbsc_file)
% [B,x0,U] = torbsc_i(torbsc_file)
%   initialisation of model torbsc
%   B   Model size
%   x0  default initial state
%   U   measuerement list
%
% Stimela, 2004

% © Kim van Schagen,

U = st_Varia('ShortNames'); % default with long Names

% Get Model parameter file for parameter specific sizes
torbsc_fileEcht = chckFile(torbsc_file);
P = st_getPdata(torbsc_fileEcht, 'torbsc');

% Parameters in P can now be used to determine B and x0


%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill B and x0 
NumCel = P.NumCel;
MeeTe = P.MeeTe;

if MeeTe==1

%meestroom
% initialisation
B.CStates=2*NumCel;        % number of continous states
B.DStates=0;        % number of discrete states
B.Setpoints=0;      % number of extra setpoints
B.Measurements= 3*(NumCel+1);  % number of extra measurements
B.Direct=1;         % direct feedthrough (yes=1, no=0);
B.SampleTime=0;     % SampleTime for discrete states (-1 = inherited)

x0 = [zeros(2*NumCel,1)]; % begin toestand (even lang als Bl(1)+Bl(2))

elseif MeeTe==0

%tegenstroom
% initialisation
B.CStates=2*NumCel;        % number of continous states
B.DStates=0;        % number of discrete states
B.Setpoints=0;      % number of extra setpoints
B.Measurements= 3*(NumCel+1);  % number of extra measurements
B.Direct=1;         % direct feedthrough (yes=1, no=0);
B.SampleTime=0;     % SampleTime for discrete states (-1 = inherited)

x0 = [zeros(2*NumCel,1)]; % begin toestand (even lang als Bl(1)+Bl(2))

elseif MeeTe==2

%gemengde stroom
% initialisation
B.CStates=11*NumCel+5;        % number of continous states
B.DStates=0;        % number of discrete states
B.Setpoints=0;      % number of extra setpoints
B.Measurements= 23*(NumCel+1);  % number of extra measurements
B.Direct=1;         % direct feedthrough (yes=1, no=0);
B.SampleTime=0;     % SampleTime for discrete states (-1 = inherited)

x0 = [0.00001;zeros(NumCel-1,1);zeros(NumCel,1);0.0000005*ones(NumCel,1);zeros(NumCel,1);zeros(NumCel,1);0;0;0;0;0;zeros(NumCel,1);0.0002*ones(NumCel,1);zeros(NumCel,1);zeros(NumCel,1);zeros(NumCel,1);zeros(NumCel,1)]; % begin toestand (even lang als Bl(1)+Bl(2))

end
%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
