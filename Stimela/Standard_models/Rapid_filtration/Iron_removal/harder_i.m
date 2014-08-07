function [B,x0,U] = harder_i(harder_file)
% [B,x0,U] = harder_i(harder_file)
%   initialisation of model harder
%   B   Model size
%   x0  default initial state
%   U   measuerement list
%
% Stimela, 2004

% © Kim van Schagen,

U = st_Varia('LongNames'); % default with long Names

% Get Model parameter file for parameter specific sizes
harder_fileEcht = chckFile(harder_file);
P = st_getPdata(harder_fileEcht, 'harder');

% Parameters in P can now be used to determine B and x0


%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill B and x0 

% initialisation
B.CStates=7*(P.NumCel);        % number of continous states
B.DStates=0;        % number of discrete states
B.Setpoints=1;      % number of extra setpoints
B.Measurements= 10+9*(P.NumCel);  % number of extra measurements
B.Direct=1;         % direct feedthrough (yes=1, no=0);
B.SampleTime=0;     % SampleTime for discrete states (-1 = inherited)

% initialiseren concetraties
Fe0=2;
P0=-0.5;
M0=3;

ib = st_findblock(gcs,'invruw');
if length(ib)>0
  fl = get_pfil(ib{1});
  if exist(fl)
    Pruw = invruw_p(fl);
         
    P0= -0.3;
    if size(Pruw.Bicarbonate,2)==1
      M0 = Pruw.Bicarbonate/61;
    else
      M0 = Pruw.Bicarbonate(1,2)/61;
    end      
    
  end
end

% collumn vector with the same length as B_CStates + 
x0(0*P.NumCel+(1:P.NumCel))=0; %Fe3
x0(1*P.NumCel+(1:P.NumCel))=0;   %Vulling
x0(2*P.NumCel+(1:P.NumCel))=0;   %Fe2
x0(3*P.NumCel+(1:P.NumCel))=1;   %O2
x0(4*P.NumCel+(1:P.NumCel))=M0;  %M0
x0(5*P.NumCel+(1:P.NumCel))=P0;  %P0
x0(6*P.NumCel+(1:P.NumCel))=0 ;  %Fe2Ad


%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
