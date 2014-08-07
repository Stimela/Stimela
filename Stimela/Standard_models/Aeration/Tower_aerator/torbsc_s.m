function [sys,x0,str,ts] = torbsc_s(t,x,u,flag,B,x0,U,P),
%  [sys,x0,str,ts] = torbsc_s(t,x,u,flag,B,x0,U,P),
%    Stimela S-Function
%
% t = time
% x = state vector, filled with continuous states (flag 1) or
%                      discrete states (flag 2)
% u = input vector
%
% P =  proces parameters, filled with torbsc_p.m and defined in torbsc_d.m
% B =  Model size, filled with torbsc_i.m,
% x0 = initial state, filled with torbsc_i.m,
% U = Translationstructure for inout vector, filled in uit Blok00_i.m.
%     Fields are determined by 'st_Varia'
%
% Stimela, 2004

% © Kim van Schagen,

% General purpose calculations
if any(abs(flag)==[1 2 3])

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % optional: convert input vector to user names
  % eg. Temp = u(U.Temperature);
  % in the code it is also possible to use u(U.Temparature) directly.
  Tl     = u(U.T);         %watertemperatuur            [Celsius]
  Ql     = u(U.F);         %waterdebiet                 [m3/h]
  coVC  = u(U.VC);       %influent concentratie VC   [mol/l]
  
  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % optional: calculated values used for al flags
  % eg. TempArea = u(U.Temperature)/P.Area;
  NumCel   = P.NumCel;     %aantal volledig gemengde vaten [-]
  k2VC    = P.k2;     %de k2 van methaan [1/s]
  kD       = P.kD;
  QgTot    = P.QgTot;  %totale luchtdebiet [m3/s]
  QgVers   = P.QgVers;  %verse luchtdebiet [m3/s]
  QgRec    = P.QgRec;  %recirculatie luchtdebiet [m3/s]
  MeeTe    = P.MeeTe;     %mee-, tegen of gelijkstroom
  Hoogte   = P.Hoogte;     %hoogte van het gepakte bed [m]
  Diam     = P.Diam;     %diameter van het gepakte bed [m]
 

  
  %Afronden van de luchttemperatuur op gehele getallen
  Tg     = Tl;               %Lucht temperatuur in graden Celsius
  Tg     = round(Tg);        %De luchttemperatuur wordt afgerond op hele graden
  
  %Bepalen van benodigde grootheden met betrekking tot de debieten en verblijftijden
  Ql       = Ql/3600;            % Omzetten van het debiet van m3/h -> m3/s
  OppTot   = 0.25*pi*(Diam)^2;   % Bepalen van het totale oppervlak van de BOT
  Td       = Hoogte/(Ql/OppTot); % Bepalen van de gemiddelde verblijftijd in de BOT
  TijdStap = Td/NumCel;          % Bepalen van de gemiddelde verblijftijd in één volledig gemengd vat
  RQ       = QgTot/Ql;           % Bepalen van de lucht-waterverhouding
 

   %Constanten voor de berekening van de gasconcentraties in de lucht
  Po     = 101325;                                                           % po = standaarddruk zeeniveau [Pa]  
  pw     = [  611   657   706   758   814   873   935  1002  1073  1148 ...  % pw = waterdampspanning 0-50 Celsius [Pa]
             1228  1313  1403  1498  1599  1706  1819  1938  2064  2198 ...
             2339  2488  2645  2810  2985  3169  3363  3567  3782  4008 ...
             4246  4495  4758  5034  5323  5627  5945  6280  6630  6997 ...
             7381  7784  8205  8646  9108  9590 10094 10620 11171 11745 ...
            12344]; 
  R      = 8.3143;                                                            % R = universele gasconstante [J/(K*mol)] 
  
  %Gasconcentraties in de lucht (Temperatuur in Kelvin)
  cgoVC     = 0; 
  kDVC      = kD;
  
  % Stromingsmatrices
  % LET OP, VOOR GEVORDERDEN:
  % Het cascade model heeft de mogelijkheid om de ijzeroxidatie niet alleen in toenemende mate plaats te laten vinden
  % maar ook constant over de waterstroom of geheel geconcentreerd in de laatste stap. Mocht dit wenselijk zijn dan 
  % moet in 'flag == 1' de bijbehorende regels worden gebruikt.
  MatQ1 = Matrix1(TijdStap,NumCel);
  MatQ2 = rot90(eye(NumCel));
  MatQ3 = Matrix1(TijdStap,NumCel+1);
  MatQ4 = Matrix2(TijdStap,NumCel);        % constante ijzeroxidatie over waterstroom (stapjes)
  MatQ5 = Matrix3(TijdStap,NumCel);        % toenemende ijzeroxidatie over waterstroom (stapjes)
  MatQ6 = Matrix1(TijdStap,1);
  MatQ7 = Matrix4(TijdStap,NumCel);        % al het ijzer wordt in de laatste stap geoxideerd
% Indien aangepaste verblijftijdsspreidingscurven worden toegepast moet de bovenstaande MatQ3, MatQ4 en MatQ7
% worden uitgezet en moeten de twee onderstaande regels met MatQ3 worden gebruikt. Het is dus alleen mogelijk
% met de aangepaste verblijftijdspreidingscurven te werken bij toenemende oxidatie over de waterstroom, 
% zie ook 'aangepaste verblijftijdsspreidingscurven'.
%  TijdStapVblT = [TijdStap;1]; 
%  MatQ3 = M1gasuit(TijdStapVblT,NumCel+1);


  %De verschillende evenwichtsconstanten (Temperatuur in Kelvin)
  T      = (Tl+273);

  %de concentraties in [mol/l] (met gebruik making van activiteiten):
  coVC  = coVC;
  cgoVC = cgoVC;
  
  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

end; % of any(abs(flag)==[1 2 3])


if flag == 1, % Continuous states derivative calculation

  % default derivative =0;
  sys = zeros(B.CStates,1);
  
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the derivatives of the continuous states
  % eg. sys(1) = (u(U.Temperature)-x(1))/P.Volume;
  if MeeTe==1

  % MEESTROOM

  sys(1:NumCel)=MatQ1*[coVC;x(1:NumCel)]+k2VC*kDVC*x(NumCel+1:2*NumCel)-k2VC*x(1:NumCel);
  sys(NumCel+1:2*NumCel)=MatQ1*[cgoVC*(QgVers/QgTot)+x(2*NumCel)*(QgRec/QgTot);x(NumCel+1:2*NumCel)]-((k2VC*kDVC)/RQ)*x(NumCel+1:2*NumCel)+(k2VC/RQ)*x(1:NumCel);
  
  elseif MeeTe==0

  % TEGENSTROOM

  sys(1:NumCel)=MatQ1*[coVC;x(1:NumCel)]+k2VC*kDVC*MatQ2*x(NumCel+1:2*NumCel)-k2VC*x(1:NumCel);
  sys(NumCel+1:2*NumCel)=MatQ1*[cgoVC*(QgVers/QgTot)+x(2*NumCel)*(QgRec/QgTot);x(NumCel+1:2*NumCel)]-((k2VC*kDVC)/RQ)*x(NumCel+1:2*NumCel)+(k2VC/RQ)*MatQ2*x(1:NumCel);
  
  else
  error(['Ongeldige Waarde 6']);
  end

  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif flag ==2, %discrete state determination

  % default next sample same states (length is B.DStates)
  sys = x(B.CStates+1:B.CStates+B.DStates);
    
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the state value on the next samplemoment (determined by
  % B.SampleTime)
  % eg. sys(1) = (x(1)+u(U.Temperature))/P.Volume;

  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif flag ==3, % output data determination

  % default equal to the input with zeros for extra measurements
  sys = [u; zeros(B.Measurements,1)];

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Determine output for calculated values
  % eg. sys(U.Temparature) = x(1);

  if MeeTe==1   % MEESTROOM

   sys(U.VC)=x(NumCel);
 
   
   %De O2, VC, CO2, N2 en H2S concentraties in water, lucht en de verzadigingsconcentraties
   sys(U.Number+1:U.Number+(NumCel+1))=[coVC;x(1:NumCel)];
   sys(U.Number+1+(NumCel+1):U.Number+2*(NumCel+1))=[cgoVC*(QgVers/QgTot)+x(2*NumCel)*(QgRec/QgTot);x(NumCel+1:2*NumCel)];
   sys(U.Number+1+2*(NumCel+1):U.Number+3*(NumCel+1))=kDVC*[cgoVC*(QgVers/QgTot)+x(2*NumCel)*(QgRec/QgTot);x(NumCel+1:2*NumCel)];


  elseif MeeTe==0

   % TEGENSTROOM
   sys(U.VC)=x(NumCel);

   %De O2, VC, CO2, N2 en H2S concentraties in water, lucht en de verzadigingsconcentraties
   sys(U.Number+1:U.Number+(NumCel+1))=[coVC;x(1:1*NumCel)];
   sys(U.Number+1+(NumCel+1):U.Number+2*(NumCel+1))=[MatQ2*x(NumCel+1:2*NumCel);cgoVC*(QgVers/QgTot)+x(2*NumCel)*(QgRec/QgTot)];
   sys(U.Number+1+2*(NumCel+1):U.Number+3*(NumCel+1))=kDVC*[MatQ2*x(NumCel+1:2*NumCel);cgoVC*(QgVers/QgTot)+x(2*NumCel)*(QgRec/QgTot)];

  else
  error(['Ongeldige Waarde 6']);
  end

  
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif flag == 0
  % initialize Model
  % [cs,ds,out,in,,direct]
  sys = [B.CStates,B.DStates,U.Number+B.Measurements,U.Number+B.Setpoints, 0, B.Direct,1];
  ts = [B.SampleTime,0];
  str = 'torbsc';
  x0=x0;
else
    % If flag is anything else, no need to return anything
    % since this is a continuous system
    sys = [];
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Functions which are used in this m.file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The following function returns the matrix Q1 for aeration

function val = Matrix1(T,N)

a     = 1./T;
v1=[[a.*ones(N,1)], [-a.*ones(N,1)]];
q1=spdiags(v1,[0,1],N,N+1);
val = [q1];


% The following function returns the matrix Q2 for aeration

function val = Matrix2(T,N)

a     = 1./T;
v1=[-a.*ones(N,1)];
q1=spdiags(v1,[1],N,N+1);
Tel=0;
for p=1:N
  Tel=Tel+1;
  q1(Tel,1)=1/T;
end
val = [q1];


% The following function returns the matrix Q3 for aeration

function val = Matrix3(T,N)

a     = 1./T;
v1=[[a.*ones(N,1)], [-a.*ones(N,1)]];
q1=spdiags(v1,[0,N],N,2*N);
val = [q1];


% The following function returns the matrix Q4 for aeration

function val = Matrix4(T,N)

a     = 1./T;
v1=[-a.*ones(N,1)];
q1=spdiags(v1,[1],N,N+1);
Tel=0;
for p=1:N-1
  Tel=Tel+1;
  q1(Tel,1)=0;
end
q1(N,1)=1/T;
val = [q1];


% The following function returns the ion activity

function [fiF] = fi(z,a,EGV)

EGV = EGV/1000;% S/m
I = 0.183*EGV;% mol/l benaderingsformule
if I>=0 & I<0.1
  fiF=10^(-0.5*z^2*(I^0.5/(1+0.33*a*I^0.5)));
elseif 0.1<=I & I<=0.5
  fiF=10^(-0.5*z^2*((I^0.5/(1+0.33*a*I^0.5))-0.2*I));
else
 error(['Ongeldige Waarde EGV']);
end


