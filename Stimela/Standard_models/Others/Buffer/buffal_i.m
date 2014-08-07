function [B,x0,U] = buffal_i(buffal_file)
% [B,x0,U] = buffal_i(buffal_file)
%   initialisation of model buffal
%   B   Model size
%   x0  default initial state
%   U   measuerement list
%
% Stimela, 2004

% © Kim van Schagen,

U = st_Varia('LongNames'); % default with long Names

% Get Model parameter file for parameter specific sizes
buffal_fileEcht = chckFile(buffal_file);
P = st_getPdata(buffal_fileEcht, 'buffal');

% Parameters in P can now be used to determine B and x0


%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill B and x0 

% initialisation
B.CStates=U.Number;        % number of continous states
B.DStates=0;        % number of discrete states
B.Setpoints=0;      % number of extra setpoints
B.Measurements= 0;  % number of extra measurements
B.WaterIn  = 1;     % Incoming water Flow (yes=1, no=0)
B.WaterOut  = 1;    % Outgoing water Flow (yes=1, no=0)
B.Direct=0;         % direct feedthrough (yes=1, no=0);
B.SampleTime=0;     % SampleTime for discrete states (-1 = inherited, -2 = next hot in flag=4)

x0 = zeros(U.Number,1);
ib = st_findblock(gcs,'invruw');
if length(ib)>0
  fl = get_pfil(ib{1});
  if exist(fl)
    Pruw = invruw_p(fl);
    
    % alle namen
    UNames=fieldnames(U);
    for i=1:U.Number
      if isfield(Pruw,UNames{i})
        % waarde van 1
        Pruw1=getfield(Pruw,UNames{i});
        if size(Pruw1,2)==1
          x0(i) = Pruw1;
        else
          x0(i) = Pruw1(1,2);
        end
      end
    end
   
  end
end

x0(U.Flow)=0;              % collumn vector with the same length as B_CStates + 

%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
