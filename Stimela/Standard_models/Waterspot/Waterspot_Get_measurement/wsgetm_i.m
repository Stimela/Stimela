function [B,x0,U] = wsgetm_i(wsgetm_file)
% [B,x0,U] = wsgetm_i(wsgetm_file)
%   initialisation of model wsgetm
%   B   Model size
%   x0  default initial state
%   U   measuerement list
%
% Stimela, 2004

% � Kim van Schagen,

U = st_Varia('LongNames'); % default with long Names

% Get Model parameter file for parameter specific sizes
wsgetm_fileEcht = chckFile(wsgetm_file);
P = st_getPdata(wsgetm_fileEcht, 'wsgetm');

% Parameters in P can now be used to determine B and x0


%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill B and x0 

% initialisation
B.CStates=0;        % number of continous states
B.DStates=0; %1;        % number of discrete states
B.Setpoints=-1;      % number of extra setpoints
B.Measurements= 1;  % number of extra measurements
B.WaterIn  = 0;     % Incoming water Flow (yes=1, no=0)
B.WaterOut  = 0;    % Outgoing water Flow (yes=1, no=0)
B.Direct=1;         % direct feedthrough (yes=1, no=0);
B.SampleTime=-1;     % SampleTime for discrete states (-1 = inherited, -2 = next hot in flag=4)

x0=[]; %P.Default;              % collumn vector with the same length as B_CStates + 

% en check goto tag?
ct = get_param([gcb '/Goto'],'GotoTag');
if ~strcmp(ct,['WSFrom' P.WSTag])
  set_param([gcb '/Goto'],'GotoTag',['WSFrom' P.WSTag])
end
%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
