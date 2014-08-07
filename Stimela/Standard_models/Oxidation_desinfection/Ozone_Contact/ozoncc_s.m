function [sys,x0,str,ts] = ozoncc_s(t,x,u,flag,B,x0,U,P),
%  [sys,x0,str,ts] = ozoncc_s(t,x,u,flag,B,x0,U,P),
%    Stimela S-Function
%
% t = time
% x = state vector, filled with continuous states (flag 1) or
%                      discrete states (flag 2)
% u = input vector
%
% P =  proces parameters, filled with ozoncc_p.m and defined in ozoncc_d.m
% B =  Model size, filled with ozoncc_i.m,
% x0 = initial state, filled with ozoncc_i.m,
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

  NumCel       = P.NumCel;
  Hreact       = P.Hreact;       % Heigth of the reactor [m]
  Areact       = P.Areact;       % Surface area ozone reactor [m2]
  MeeTe        = P.MeeTee;       % 1=co-current and 0=counter-current
%   Short_Circ   = P.Short_Circ;   % short circuit flow through the bubble column as part of the total flow [-]
  db0          = P.db0/1000;          % initial bubble diameter [m]
  kUV_Sel      = P.kUV_Sel;      % 1=kUV is given manual and 0=kUV is determined by the model
  kUV          = P.kUV;          % UVA254 decay rate [1/s]
  Y            = P.Y;            % Yield factor for ozone use per UVA decrease [(mg/L)/(1/m)]
  KafbO3_Sel   = P.KafbO3_Sel;   % 1=kO3 is given manual and 0=kO3 is determined by the model
  KafbO3       = P.KafbO3;       % slow decay rate O3 [1/s]  
  ceUVA254_Sel = P.ceUVA254_Sel; % 1=UVAo is given manual and 0=UVAo is determined by the model
  ceUVA254     = P.ceUV254;      % stable UVA254 value after ozonation
  FactorKLO3   = P.FactorKLO3;   % variable in Hughmark equation that varies for single gas bubble (0.061)
                                 % and swarm of bubbles (0.0187)
%   KLO3Init     = P.KLO3Init;     % bij dosering van een overmaat ozon bevindt zich ozon gas boven het wateroppervlak in de
                                 % bellenkolom waardoor ook gasuitwisseling plaatsvindt de kL is dan in het bovenste compartiment
                                 % hoger, dit kan worden gecorrigeerd door een verhoging van de kLO3 met de kLO3init
  F_BrO3init   = P.F_BrO3init;   % FBrO3,ini constant for initial bromate formation (F*ozone dosage)
  kCt_BrO3_Sel = P.kCt_BrO3_Sel; % 1=kBrO3 is given manual and 0=kBrO3 is determined by the model
  kCt_BrO3     = P.kCt_BrO3/60;  % kBrO3 bromate formation rate constant
  F_AOC_Sel    = P.F_AOC_Sel;    % 1=FACO is given manual and 0=FAOC is determined by the model
  F_AOC        = P.F_AOC;        % FAOC constant for AOC formation (F*ozone dosage) [(ug-C/l)/(mg-O3/l)]
  kEc_Sel      = P.kEc_Sel;      % 1=kEc is given manual and 0=kEc is determined by the model
  kEc          = P.kEc/60;       % k inactivation rate for E.coli
  Ct_lagEc     = P.Ct_lagEc/60;  % Ctlag for E.coli
%   NumCel_All   = P.NumCel';      % Reeks van volledig gemengde vaten [-]
%   NumCel       = sum(NumCel_All);% Totaal aantal volledig gemengde vaten [-]
    
  dh           = Hreact/NumCel;  % heigth per CSTR (NumCel) [m]

  Tl      = u(U.Temperature);    % water temperature            [Celsius]
  Ql      = u(U.Flow);           % water flow                 [m3/h]
  coO3    = u(U.Ozone);          % influent O3 concentration    [mg/l]
  coDOC   = u(U.DOC);		     % influent DOC concentration   [mg/l]
  coUVA254= u(U.UV254);		     % influent UV value          [1/m]
%   iniUVA254= u(U.Initiele_UVA254);% initiele UVA254 waarde      [1/m]
  coBrO3  = u(U.Bromate);		 % influent Bromate concentration     [ug/l]
  
  coO3Dos = u(U.Ozone_dosed);    % hoeveelheid gedoseerde ozon
  coO3Dos_kUV = u(U.Ozone_dos_kUV); % hoeveelheid gedoseerde ozon voor kUV
  
  coEc    = u(U.Ecoli);  	     % influent E.coli concentration
  copH    = u(U.pH);	         % influent pH                   [pH]
  coBrmin = u(U.Bromide);        % influent bromide concentration [ug/l]
  coAOC   = u(U.AOC);            % influent AOC concentration   [ug/l]
  
  Qg      = u(U.Number+1);       % gas flow                [m3/h]
  cgoO3   = u(U.Number+4);       % ozone concentration in gas  [g/Nm3]

 coCt    = 0;                   % The initial Ct
 Kinhib  = 0.0001;              % Inhibition coefficient Monod constante mg-O3/l
                                 % Ik heb ook 0.00001 geprobeerd, dit gaf geen verbetering meer
  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % optional: calculated values used for al flags
  % eg. TempArea = u(U.Temperature)/P.Area;

  %Afronden van de luchttemperatuur op gehele getallen
  Tg     = Tl;                      % Air temperature in degrees Celsius
%   Tg     = round(Tg);               % De luchttemperatuur wordt afgerond op hele graden
  nu     = (497e-6)/(42.5+Tl)^1.5;  % kinematic viscosity m2/s for 0oC to 35oC
  rho    = 1000;                    % water density  kg/m3
  SurfTen= -1.47e-4*Tl+7.56e-2;     % Surface tension for 0oC to 30oC
  
  %Bepalen van benodigde grootheden met betrekking tot de debieten en verblijftijden
  Ql       = Ql/3600;             % m3/h -> m3/s
%   Ql_MF    = Ql*(1-Short_Circ);   % Main flow die geozoneerd wordt in de reactor
%   Ql_SC    = Ql*Short_Circ;       % Short circuit stroom die niet geozoneerd wordt in de reactor
  Qg       = Qg/3600;             % m3/h -> m3/s
  RQ       = Qg/Ql;               % RQ value
%   RQ       = Qg/Ql_MF;            % RQ waarde
%   vl       = [];
%   for countvl = 1:size(NumCel_All,1);
%       vlnew   = (Ql_MF*ones(NumCel_All(countvl,1),1))/Areact(countvl,1); % IS EIGENLIJK FOUT MOET BETROKKEN WORDEN OP QL!!!!!!
% %      vlnew   = (Ql*ones(NumCel_All(countvl,1),1))/Areact(countvl,1);
%       vl      = cat(1,vl,vlnew);
%   end
%   vl = vl*ones(1,NumCel+1);

  vl=Ql/Areact;

  vb0    = 0.0135*((20000*SurfTen)/(rho*db0))^0.5;%=0.0135*(70*2/(100*db0))^0.5; % bubble raise velocity
  %vb0    = 0.27;                % Belstijgsnelheid in stilstaand water in m/s
%   hreact = flipud(cumsum(flipud(dh))-flipud(dh)/2); % Gaat ervan uit dat indien de bellenkolom uit meerdere blokken bestaat
%                                                   % deze zijn opgegeven vanaf de ozondoseerschotel, zie opmerking ozoncc_d
%                                                   % gedefinieerd voor meestroom
  
  %De relative molecular masses [g/mol] 
  MrO2    = 31.9988;
  MrO3    = 31.9988*3/2;
  MrN2    = 28.0134;
    
  %Constanten voor de berekening van de gasconcentraties in de lucht
  Po     = 101325;               % Po = standaarddruk zeeniveau [Pa]  
%   pw     = [  611   657   706   758   814   873   935  1002  1073  1148 ...  % pw = waterdampspanning 0-50 Celsius [Pa]
%              1228  1313  1403  1498  1599  1706  1819  1938  2064  2198 ...
%              2339  2488  2645  2810  2985  3169  3363  3567  3782  4008 ...
%              4246  4495  4758  5034  5323  5627  5945  6280  6630  6997 ...
%              7381  7784  8205  8646  9108  9590 10094 10620 11171 11745 ...
%             12344]; 
  pw = 1070*exp(0.04986*Tg)-525.1;
  Tn     = 273.15; % standaard temperatuur K
  alfacountc   = ((Po+((1:NumCel)'-0.5)*dh*10000-pw)/Po)*(Tn/(Tn+Tg));
  alfacoc =((Po+(Hreact-(((1:NumCel)'-0.5)*dh))*10000-pw)/Po)*(Tn/(Tn+Tg));
  
  %Distributiecoëfficiënten van gassen in water voor 0, 10, 20 en 30 graden Celsius
  %TkD    = [0     ;10    ;20    ;30    ];
  %TkDO3  = [0.641;0.539;0.395;0.259];
  %TkD    = [0    ; 5    ; 10   ; 15   ; 20   ; 25   ; 30   ; 35   ]; % Langlais 1991
  %TkDO3  = [0.64 ; 0.50 ; 0.39 ; 0.31 ; 0.24 ; 0.19 ; 0.15 ; 0.12 ];
    
  %Berekening distributiecoëfficiënten voor tussenliggende temperaturen door lineaire interpolatie
  %kDO3   = INTERP1Q(TkD,TkDO3, Tl);
   
  kDO3    = exp(-0.45-0.043*Tl); %Langlais 1991
  
  %Equations for diffusion coëfficiënt based on DO3=1.74e-9 for
  %20oC  Langlais 1991 determined with equation of NERNST EINSTEIN
  DifO3	= 5.97e-15*(Tl+273.15)/(nu*rho);
    
%   if FactorKLO3==99; % in case ozoncc_s is called from ozoncc the FactorKLO3 is made 0 in ozoncc_i and the kLO3 should be zero
%       kLO3 = zeros(NumCel,1);
%   else
      kLO3 = (DifO3/db0)*(2+FactorKLO3*((vb0*db0/nu)^0.48*(nu/DifO3)^0.34*(db0*(9.81)^0.33/(DifO3)^0.66)^0.072)^1.61);
%       kLO3 = kLO3*ones(NumCel,1);
%       kLO3 = kLO3.*KLO3Init; % gedefinieerd voor meestroom
%   end


  O3Dos       = (Qg*cgoO3)/Ql;
  ceO3Dos     = coO3Dos+O3Dos;
  O3Dos_kUV   = (Qg*cgoO3)/Ql;
  if ceO3Dos~=0 % In the first BC ozone is dosed
       if Qg~=0
          coO3Dos_kUV=0;
       end
      
      ceO3Dos_kUV = coO3Dos_kUV+O3Dos_kUV;
      
      if kUV_Sel==0
          kUV=3.75*exp(-3.443*ceO3Dos_kUV);
      end
          
      if KafbO3_Sel==0
          KafbO3_10=0.0011*(coDOC/ceO3Dos)^2;                %Afbraakcoefficient bij 10oC
          KafbO3=(KafbO3_10/(exp(-70000/(8.314*(Tn+10)))))*exp(-70000/(8.314*(Tn+Tl)));
      end

      if ceUVA254_Sel==0
          ceUVA254=coUVA254-0.914*ceO3Dos^0.5*coUVA254^0.5; 
      end

      BrO3init = F_BrO3init*ceO3Dos;
      coBrO3   = coBrO3+BrO3init;

      if kCt_BrO3_Sel==0
          kCt_BrO3=2.74e-7*copH^5.82*coBrmin^0.73*1.035^(Tl-20); % (ug-BrO3/mg-O3)*1/min
          kCt_BrO3=kCt_BrO3*1/60;                                % (ug-BrO3/mg-O3)*1/s
      end

      if F_AOC_Sel==0
          F_AOC=3.55e15*exp(-80500/(8.314*(Tn+Tl)));
      end
      if Qg~=0
          ceAOC=F_AOC*O3Dos*coDOC+coAOC;
      else
          ceAOC=coAOC;
      end

      if kEc_Sel==0
          kEc=4.49*exp(3.305*ceO3Dos); % (l/mg-O3)*1/min*1/s
          kEc=kEc*1/60;                % (l/mg-O3)*1/s*1/s
      end


  else % In the first BC NO ozone is dosed
      ceO3Dos_kUV = 0;
      kUV         = 0;
      KafbO3      = 0;
      ceUVA254    = coUVA254;
      coBrO3      = coBrO3;
      kCt_BrO3    = 0;
      F_AOC       = 0;
      ceAOC       = coAOC;
      kEc         = 0;
  end

  MatQ1 = Matrix1(1,NumCel);

  % Hom empircal constants 
  n=1;
  m=2;

%   %de concentraties in [mol/l] (met gebruik making van activiteiten):
%   coO3   = coO3/(1000*MrO3);
%   %de concentraties in [mmol/l] (met gebruik making van activiteiten):
%   coO3   = coO3/MrO3;

%%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


end; % of any(abs(flag)==[1 2 3])



if flag == 1, % Continuous states derivative calculation

  % default derivative =0;
  sys = zeros(B.CStates,1);
  
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the derivatives of the continuous states
  % eg. sys(1) = (u(U.Temperature)-x(1))/P.Volume;

  %sys(1:NumCel)=(vl./dh).*MatQ1*[coO3;x(1:NumCel)]-KafbO3*x(1:NumCel)-kUV*(x(NumCel+1:2*NumCel)-ceUVA254).*Y;
  %sys(NumCel+1:2*NumCel)=(vl./dh).*MatQ1*[coUVA254;x(NumCel+1:2*NumCel)]-kUV*(x(NumCel+1:2*NumCel)-ceUVA254);

  if MeeTe==1   % MEESTROOM
 
  
  sys(1:NumCel)=(vl./dh).*MatQ1*[coO3;x(1:NumCel)]+kLO3.*RQ.*(vl/(vb0+vl))*(6/db0).*(alfacoc*kDO3.*x(NumCel+1:2*NumCel)-x(1:NumCel))-KafbO3*x(1:NumCel)-kUV.*(x(2*NumCel+1:3*NumCel)-ceUVA254).*Y.*(x(1:NumCel)./(Kinhib+x(1:NumCel)));
  sys(NumCel+1:2*NumCel)=((vb0+vl)./dh).*MatQ1*[cgoO3;x(NumCel+1:2*NumCel)]-kLO3*(6/db0).*(alfacoc*kDO3.*x(NumCel+1:2*NumCel)-x(1:NumCel));
  sys(2*NumCel+1:3*NumCel)=(vl./dh).*MatQ1*[coUVA254;x(2*NumCel+1:3*NumCel)]-kUV.*(x(2*NumCel+1:3*NumCel)-ceUVA254).*(x(1:NumCel)./(Kinhib+x(1:NumCel)));
  sys(3*NumCel+1:4*NumCel)=(vl./dh).*MatQ1*[coBrO3;x(3*NumCel+1:4*NumCel)]+kCt_BrO3*x(1:NumCel);
%  sys(4*NumCel+1:5*NumCel)=(vl./dh).*MatQ1*[coEc;x(4*NumCel+1:5*NumCel)]-kEc_lag.*x(1:NumCel).*x(4*NumCel+1:5*NumCel); % Delayed Chick-Watson
  sys(4*NumCel+1:5*NumCel)=(vl./dh).*MatQ1*[coEc;x(4*NumCel+1:5*NumCel)]-kEc.*m.*x(4*NumCel+1:5*NumCel).*x(1:NumCel).^n.*(cumsum(dh(:,1)./vl(:,1))).^(m-1); % Hom
  sys(5*NumCel+1:6*NumCel)=(vl./dh).*MatQ1*[coCt;x(5*NumCel+1:6*NumCel)]+x(1:NumCel);


  elseif MeeTe==0    % TEGENSTROOM
      
  sys(1:NumCel)=(vl./dh).*MatQ1*[coO3;x(1:NumCel)]+kLO3.*RQ.*(vl(:,1)./(vb0-vl(:,1)))*(6/db0).*(alfacountc*kDO3.*flipud(x(NumCel+1:2*NumCel))-x(1:NumCel))-KafbO3*x(1:NumCel)-kUV.*(x(2*NumCel+1:3*NumCel)-ceUVA254).*Y.*(x(1:NumCel)./(Kinhib+x(1:NumCel)));
  sys(NumCel+1:2*NumCel)=((vb0-vl)./dh).*MatQ1*[cgoO3;x(NumCel+1:2*NumCel)]-kLO3*(6/db0).*(alfacoc*kDO3.*x(NumCel+1:2*NumCel)-flipud(x(1:NumCel)));
  sys(2*NumCel+1:3*NumCel)=(vl./dh).*MatQ1*[coUVA254;x(2*NumCel+1:3*NumCel)]-kUV.*(x(2*NumCel+1:3*NumCel)-ceUVA254).*(x(1:NumCel)./(Kinhib+x(1:NumCel)));
  sys(3*NumCel+1:4*NumCel)=(vl./dh).*MatQ1*[coBrO3;x(3*NumCel+1:4*NumCel)]+kCt_BrO3*x(1:NumCel);
%  sys(4*NumCel+1:5*NumCel)=(vl./dh).*MatQ1*[coEc;x(4*NumCel+1:5*NumCel)]-kEc_lag.*x(1:NumCel).*x(4*NumCel+1:5*NumCel); % Delayed Chick-Watson
  sys(4*NumCel+1:5*NumCel)=(vl./dh).*MatQ1*[coEc;x(4*NumCel+1:5*NumCel)]-kEc.*m.*x(4*NumCel+1:5*NumCel).*x(1:NumCel).^n.*(cumsum(dh(:,1)./vl(:,1))).^(m-1); % Hom
  sys(5*NumCel+1:6*NumCel)=(vl./dh).*MatQ1*[coCt;x(5*NumCel+1:6*NumCel)]+x(1:NumCel);

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
  sys = [u(1:U.Number); zeros(B.Measurements,1)];

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Determine output for calculated values
  % eg. sys(U.Temparature) = x(1);
   
   % Menging vind plaats na de (ozondosering) bellenkolom het effluent van de bellenkolom
   % wordt daarom gecorrigeerd met de short-circuit flow.
   sys(U.Ozone)=(x(NumCel));
   sys(U.UV254)=(x(3*NumCel));   
   sys(U.Bromate) =(x(4*NumCel));   
   sys(U.Ecoli)=(x(5*NumCel));
   sys(U.AOC)=ceAOC;
   sys(U.Ozone_dosed)=ceO3Dos;
   sys(U.Ozone_dos_kUV)=ceO3Dos_kUV;

  % Determine extra measurements
  % eg. sys(U.Number+1) = x(1)/P.Opp;

   % Omdat de menging wordt verondersteld na de (ozondosering) bellenkolom plaats te
   % vinden wordt in de bellenkolom de concentratie niet beinvloed door de
   % short-circuit flow.
   sys(U.Number+1:U.Number+(NumCel+1))=[coO3;x(1:NumCel)];
   sys(U.Number+1+(NumCel+1):U.Number+2*(NumCel+1))=[cgoO3;x(NumCel+1:2*NumCel)];
   sys(U.Number+1+2*(NumCel+1):U.Number+3*(NumCel+1))=[coUVA254;x(2*NumCel+1:3*NumCel)];
   sys(U.Number+1+3*(NumCel+1):U.Number+4*(NumCel+1))=[coBrO3;x(3*NumCel+1:4*NumCel)];
   sys(U.Number+1+4*(NumCel+1):U.Number+5*(NumCel+1))=[coEc;x(4*NumCel+1:5*NumCel)];
   sys(U.Number+1+5*(NumCel+1):U.Number+6*(NumCel+1))=1/60*[coCt;x(5*NumCel+1:6*NumCel)];

  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif flag == 0
  % initialize Model
  % [cs,ds,out,in,,direct]
  sys = [B.CStates,B.DStates,U.Number+B.Measurements,U.Number+B.Setpoints, 0, B.Direct,1];
  ts = [B.SampleTime,0];
  str = 'ozoncc';
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



%%%%%% ongebruikt
% The following function returns the matrix Q1a for aeration

function val = Matrix1a(T,N,Po,Hreact,Tg)

hreact   = Hreact/N*cumsum([0.5;ones(N-1,1)]);
hreact1  = [Hreact/N*cumsum([1.5;ones(N-2,1)]);Hreact];
pw     = [  611   657   706   758   814   873   935  1002  1073  1148 ...  % pw = waterdampspanning 0-50 Celsius [Pa]
             1228  1313  1403  1498  1599  1706  1819  1938  2064  2198 ...
             2339  2488  2645  2810  2985  3169  3363  3567  3782  4008 ...
             4246  4495  4758  5034  5323  5627  5945  6280  6630  6997 ...
             7381  7784  8205  8646  9108  9590 10094 10620 11171 11745 ...
            12344]; 
      
a     = 1./T;
v1=[[(((Po+flipud(hreact)*10000-pw(Tg+1))./(Po+flipud(hreact1)*10000-pw(Tg+1))).* a).*ones(N,1)], [-a.*ones(N,1)]];
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LET OP, VOOR GEVORDERDEN:
% Aangepaste verblijftijdspreidingscurven
% Het volgende blok kan gebruikt worden wanneer het gewenst is de waterstroom niet in allemaal evengrootte
% gemengde vaten op te delen maar in gemengde vaten van verschillende grootten. Hiermee kan in principe
% iedere willekeurige verblijftijdspreidingscurve benaderd worden.  
% Voorbeeld:
% Aantal = 2, TijdAantal = 0.9, totale verblijftijd = 100 seconden en NumCel = 10 (aantal volledig gemende vaten)
% in dit geval hebben de eerste 8 volledige gemengde vaten een totale verblijftijd van 0.1 * 100 = 10 seconden
% dat betekent dat ieder van de eerste 8 vaten een verblijftijd heeft van 10/8 = 1.25 seconde. De laatste
% twee vaten hebben een totale verblijftijd van 0.9 * 100 = 90 seconden dat betekent dat ieder van de laatste
% twee vaten een verblijftijd heeft van 90/2 = 45 seconden. Dit zal tot gevolg hebben dat de piek in de
% verblijftijdspreidingscurve eerder optreedt en lager zal zijn dan bij 10 evengrootte volledig gemengde vaten.
% Indien dit wordt toegepast moet de stromingsmatrix MatQ3 worden aangepast, zie opmerking bij 'stromingsmatrices'
%%%%%%%%
%Aantal     = NumCel-5;                        % De laatste volledig gemengde vaten, Aantal ( Aantal =< NumCel), hebben 
%TijdAantal = 0.95;                      % een deel, TijdAantal (0 =< TijdAantal =< 1) van de totale verblijftijd
%Tel        = 0;                        % initialiseren teller
%for Tel=1:1:(NumCel-Aantal)
%  dhnew(Tel,1)=((1-TijdAantal)*Hreact)/(NumCel-Aantal);
%end
%for Tel=(NumCel-Aantal+1):1:NumCel
%  dhnew(Tel,1)=(TijdAantal*Hreact)/Aantal;
%end
%dh = dhnew*ones(1,NumCel+1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function LogPr(name, d)

    fid=fopen('ozoncc_s.log','at');
	if (fid~=0)
      fprintf(fid,'%s',name);
      fprintf(fid,'\t%g',d);

      fprintf(fid,'\n');
      fclose(fid);
  end