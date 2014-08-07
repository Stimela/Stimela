function [B,x0,U] = ozonox_i(ozonox_file)
% [B,x0,U] = ozonox_i(ozonox_file)
%   initialisation of model ozonox
%   B   Model size
%   x0  default initial state
%   U   measuerement list
%
% Stimela, 2004

% © Kim van Schagen,

U = st_Varia('LongNames'); % default with long Names

% Get Model parameter file for parameter specific sizes
ozonox_fileEcht = chckFile(ozonox_file);
P = st_getPdata(ozonox_fileEcht, 'ozonox');

% Parameters in P can now be used to determine B and x0


%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill B and x0 
NumCel= sum(P.NumCel);

% initialisation
B.CStates=6*NumCel;        % number of continous states
B.DStates=0;        % number of discrete states
B.Setpoints=4;      % number of extra setpoints
B.Measurements= 6*(NumCel+1);  % number of extra measurements
B.Direct=1;         % direct feedthrough (yes=1, no=0);
B.SampleTime=0;     % SampleTime for discrete states (-1 = inherited)
B.WaterIn  = 1;     % Incoming water Flow (yes=1, no=0)
B.WaterOut  = 1;    % Outgoing water Flow (yes=1, no=0)

% initialiseren concetraties
O3 = 1e-5;
UV254=14;
EC=20000;

ib = st_findblock(gcs,'invruw');
if length(ib)>0
  fl = get_pfil(ib{1});
  if exist(fl)
    Pruw = invruw_p(fl);
    if size(Pruw.UV254,2)==1
      UV254 = Pruw.UV254;
    else
      UV254 = Pruw.UV254(1,2);
    end
  end
end


% collumn vector with the same length as B_CStates + 
x0=[O3*ones(NumCel,1);zeros(NumCel,1);UV254*ones(NumCel,1);zeros(NumCel,1);EC*ones(NumCel,1);zeros(NumCel,1)];

%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
