function [B,x0,U] = cascad_i(cascad_file)
% [B,x0,U] = cascad_i(cascad_file)
%   initialisation of model cascad
%   B   Model size
%   x0  default initial state
%   U   measuerement list
%
% Stimela, 2004

% © Kim van Schagen,

U = st_Varia('LongNames'); % default with long Names

% Get Model parameter file for parameter specific sizes
cascad_fileEcht = chckFile(cascad_file);
P = st_getPdata(cascad_fileEcht, 'cascad');

% Parameters in P can now be used to determine B and x0

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill B and x0 

% initialisation
if (P.Vair==0)                    % downward compatible
  B.CStates=11*P.NumCel;        % number of continous states
else
  B.CStates=12*P.NumCel;        % number of continous states
end        % number of continous states
B.DStates=0;        % number of discrete states
B.Setpoints=1;      % number of extra setpoints
B.Measurements= 15*(P.NumCel+1)+1;  % number of extra measurements
B.Direct=1;         % direct feedthrough (yes=1, no=0);
B.SampleTime=0;     % SampleTime for discrete states (-1 = inherited)

x0 = zeros(B.CStates+B.DStates,1);
x0(1) = 0.00001;
% collumn vector with the same length as B_CStates + 

%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
