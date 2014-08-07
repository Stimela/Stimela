function [B,x0,U] = wssetq_i(wssetq_file)
% [B,x0,U] = wssetq_i(wssetq_file)  
%   initialisation of model wssetq
%   B   Model size
%   x0  default initial state
%   U   measuerement list
%
% Stimela, 2004

% © Kim van Schagen,

U = st_Varia('LongNames'); % default with long Names

% Get Model parameter file for parameter specific sizes
wssetq_fileEcht = chckFile(wssetq_file);
P = st_getPdata(wssetq_fileEcht, 'wssetq');

% Parameters in P can now be used to determine B and x0


%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill B and x0 

% initialisation
B.CStates=0;        % number of continous states
B.DStates= 0; %1;        % number of discrete states
B.Setpoints=1;      % number of extra setpoints
B.Measurements= 0;  % number of extra measurements
B.WaterIn  = 1;     % Incoming water Flow (yes=1, no=0)
B.WaterOut  = 1;    % Outgoing water Flow (yes=1, no=0)
B.Direct=1;         % direct feedthrough (yes=1, no=0);
B.SampleTime=-1;     % SampleTime for discrete states (-1 = inherited, -2 = next hot in flag=4)

x0=[]; %P.Default;              % collumn vector with the same length as B_CStates + 

% en check From tag?
ct = get_param([gcb '/From'],'GotoTag');
if ~strcmp(ct,['WSTo' P.WSTag])
  set_param([gcb '/From'],'GotoTag',['WSTo' P.WSTag])
end

%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
