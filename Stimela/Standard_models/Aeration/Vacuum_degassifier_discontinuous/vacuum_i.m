function [B,x0,U] = vacuum_i(vacuum_file)
% [B,x0,U] = vacuum_i(vacuum_file)
%   initialisation of model vacuum
%   B   Model size
%   x0  default initial state
%   U   measuerement list
%
% Stimela, 2004

% © Kim van Schagen,

U = st_Varia('LongNames'); % default with long Names

% Get Model parameter file for parameter specific sizes
vacuum_fileEcht = chckFile(vacuum_file);
P = st_getPdata(vacuum_fileEcht, 'vacuum');

% Parameters in P can now be used to determine B and x0


%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill B and x0 

% initialisation
B.CStates=6*P.NumCel+5;        % number of continous states
B.DStates=0;        % number of discrete states
B.Setpoints=0;      % number of extra setpoints
B.Measurements= 32*(P.NumCel+1);  % number of extra measurements
B.Direct=1;         % direct feedthrough (yes=1, no=0);

% NB for this model the sample time consists of 2 rows
% to accomplish this vacuum_s(flag==0) differs from the standard Stimela format
  % the second row ensures that sample time will not exceed the cycle
  % period of the vacuum pump
  %
  % ts eerste regel eerste getal: sample tijd (om de hoeveel seconden een sample wordt genomen, als 0 wordt
  %                                            gekozen bepaald Matlab automatisch op basis van de integratie
  %                                            de sampletijd)
  % ts eerste regel tweede getal: sample offset (dit is de begintijd van wanneer je begint met samples nemen)
  % ts tweede regel hetzelfde
  % De eerste regel zijn de sampletijden bepaald door Matlab, de tweede regel zijn de sampletijden zelf bepaald
%B.SampleTime= [0,0;P.Tpump/3,0];     % SampleTime for discrete states (-1 = inherited)
B.SampleTime= [0,0;P.Tpump/10,0];     % SampleTime for discrete states (-1 = inherited)

x0 = [zeros(P.NumCel,1);zeros(P.NumCel,1);0.00005*ones(P.NumCel,1);zeros(P.NumCel,1);zeros(P.NumCel,1);0;0;0;0;0;zeros(P.NumCel,1)];
              % collumn vector with the same length as B_CStates + 

%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
