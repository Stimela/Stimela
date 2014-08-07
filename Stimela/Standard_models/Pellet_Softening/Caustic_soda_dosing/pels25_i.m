function [B,x0,U] = pels25_i(pels25_file)
% [B,x0,U] = pels25_i(pels25_file)
%   initialisation of model pels25
%   B   Model size
%   x0  default initial state
%   U   measuerement list
%
% Stimela, 2004

% © Kim van Schagen,

U = st_Varia('LongNames'); % default with long Names

% Get Model parameter file for parameter specific sizes
pels25_fileEcht = chckFile(pels25_file);
P = st_getPdata(pels25_fileEcht, 'pels25');

% Parameters in P can now be used to determine B and x0


%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill B and x0 
NumCel=P.NumCel;

% initialisation
B.CStates=6*(NumCel);        % number of continous states
B.DStates=0;                 % number of discrete states
B.Setpoints=3;               % number of extra setpoints NaOH, Ngrains, Npellets
B.Measurements=7*NumCel;     % number of extra measurements
B.Direct=1;                  % direct feedthrough (yes=1, no=0);
B.SampleTime=0;              % SampleTime for discrete states (-1 = inherited)

if length(P.kg0)== P.NumCel
    % gegeven
    mg = P.kg0;
else
  % calculate initial sand distribution
  dmin = 0.28/1000;
  dmax = 1.0/1000;
  if length(P.kg0)==2
    %[kg in onderste laag - totaal kg]
    dest=dmin+(dmax-dmin)*exp(-(2:NumCel));
    verhouding=dmax^3./dest.^3;
    som=sum(verhouding);
    if P.kg0(2)<P.kg0(1)
        P.kg0(2)=P.kg0(1)+1;
    end

    mg = [P.kg0(1) verhouding/som*(P.kg0(2)-P.kg0(1))];
  else
    dest=dmin+(dmax-dmin)*exp(-(1:NumCel));
    verhouding=dmax^3./dest.^3;
    som=sum(verhouding);

    mg = verhouding/som*P.kg0;
  end  
end  

% berekenen kalkx0
if length(P.d) >0
    if length(P.d)== P.NumCel
       mc = (((P.d/P.d0).^3-1)*P.rhos.*mg/P.rhog).*(P.d>P.d0); 
    else
        if length(P.d)==1
           d = P.d:(P.d0-P.d)/(P.NumCel-1):P.d0;
           mc = (((d/P.d0).^3-1)*P.rhos.*mg/P.rhog).*(d>P.d0); 
        else
          error('pelsof: length of initial diameter does not equal Number of Reactors');
        end
    end    
else
    mc = 0;
end    

% initialiseren concetraties
Ca0=2;
P0=0.5;
M0=4;
IB0 = 9;

ib = st_findblock(gcs,'invruw');
if length(ib)>0
  fl = get_pfil(ib{1});
  if exist(fl)
    Pruw = invruw_p(fl);
    if size(Pruw.Calcium,2)==1
      Ca0 = Pruw.Calcium/40;
    else
      Ca0 = Pruw.Calcium(1,2)/40;
    end
      
    P0= -0.3;
    if size(Pruw.Bicarbonate,2)==1
      M0 = Pruw.Bicarbonate/61;
    else
      M0 = Pruw.Bicarbonate(1,2)/61;
    end      
    if size(Pruw.Conductivity,2)==1
      IB0 = Pruw.Conductivity*P.IoEc;
    else
      IB0 = Pruw.Conductivity(1,2)*P.IoEc;
    end
    
  end
end

% collumn vector with the same length as B_CStates + 
x0(0*NumCel+(1:NumCel))=Ca0;   %Calcium
x0(1*NumCel+(1:NumCel))=M0;   %P-getal
x0(2*NumCel+(1:NumCel))=P0; %M-getal
x0(3*NumCel+(1:NumCel))=IB0;   %IB
x0(4*NumCel+(1:NumCel))=mc;   %mass Kalk
x0(5*NumCel+(1:NumCel))=mg;%Nn;  %number of grains

%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
