function [sys,x0,str,ts] = plaatb_s(t,x,u,flag,B,x0,U,P),
%  [sys,x0,str,ts] = plaatb_s(t,x,u,flag,B,x0,U,P),
%    Stimela S-Function
%
% t = time
% x = state vector, filled with continuous states (flag 1) or
%                      discrete states (flag 2)
% u = input vector
%
% P =  proces parameters, filled with plaatb_p.m and defined in plaatb_d.m
% B =  Model size, filled with plaatb_i.m,
% x0 = initial state, filled with plaatb_i.m,
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

  Tl      = u(U.Temperature);         %watertemperatuur            [Celsius]
  Ql      = u(U.Flow);         %waterdebiet                 [m3/h]
  coO2    = u(U.Oxygen);         %influent concentratie O2    [mg/l]
  coCH4   = u(U.Methane);         %influent concentratie CH4   [mg/l]
% coCO2   = u(U.Carbon_dioxide);         %influent concentratie CO2   [mg/l]
  coH2S   = u(U.Hydrogen_sulfide);        %influent concentratie H2S   [mg/l]
  coHCO3  = u(U.Bicarbonate);         %influent concentratie HCO3  [mg/l]
  coN2    = u(U.Nitrogen);        %influent concentratie N2    [mg/l]
  coMn       = u(U.Mnumber)/1000;    %Mnumber in [mol/l]
    
%   if coHCO3 == 0             %HCO3 concentratie mag niet gelijk zijn aan nul
%      errstr=['De waterstofcarbonaat concentratie moet groter zijn dan 0, vul in het invoer ruwwater blokje een nieuwe waarde in.'];
%      errordlg(errstr, 'Foute invoer');
%      error('De waterstofcarbonaat concentratie moet groter zijn dan 0')
%   end
  pHo     = u(U.pH);         %influent pH                 [-]
  EGVo    = u(U.Conductivity);         %influent EGV                [mS/m]
  %QgTot = u(U.Number+1)/3600; %totale luchtdebiet [m3/s]
  
%   coFe2   = u(U.Iron2);        %influent concentratie Fe2+  [mg/l]
%   coFe3   = u(U.Iron3);        %influent concentratie Fe3+  [mg/l]
%   coCa2   = u(U.Calcium);       %influent concentratie Ca2+  [mg/l]
 
%   
%   coCaCO3 = 0;%u(U.Calcium_carbonate);        %influent concentratie CaCO3 [mg/l]
  
  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % optional: calculated values used for al flags
  % eg. TempArea = u(U.Temperature)/P.Area;

  NumCel   = P.NumCel;   %aantal volledig gemengde vaten [-]
  k2CH4    = P.k2;   %de k2 van methaan [1/s]
  
  %% cascade aerator
  %QgTot    = P.QgTot/3600;   %totale luchtdebiet [m3/s]
  %MeeTe    = P.MeeTe;   %mee- of tegenstroom
  
  %% plate aerator
  QgTot    = P.QgTot;  %totale luchtdebiet [m3/s]
  QgVers   = P.QgVers;  %verse luchtdebiet [m3/s]
  QgRec    = P.QgRec;  %recirculatie luchtdebiet [m3/s]
  
  
  %RQeff    = P.RQeff;   %de effectieve lucht water verhouding
  Popp     = P.Popp;  %totale plaatoppervlak [m2]
  Lengte   = P.Lengte;  %lengte van de plaat [m]
  Breedte  = P.Breedte;  %breedte van de plaat [m]
  Htot     = P.Htot;     %hoogte bellenbed [m]
  PercWat  = P.PercWat;     %percentage water in het bellenbed [%/100]
 
  
  
  
  %%cascade aerator
  %VBak     = P.VBak;   %de inhoud van een plaatbe bak
  %Vair     = P.Vair;   % inhoud van de afgesloten lucht boven de plaatbe
  
  
  
%   PercFe   = P.PercFe;   %percentage ijzer dat hydroliseert in de plaatbe [%/100]
%   PercCa   = P.PercCa;   %percentage calcium dat kristalliseert in de plaatbe [%/100]
% 
%   PercSlib=0;
  
  
  
    %Afronden van de luchttemperatuur op gehele getallen
  Tg     = Tl;               %Lucht temperatuur in graden Celsius
  %Tg     = round(Tg);        %De luchttemperatuur wordt afgerond op hele graden
  
  
  
  
  
  %Bepalen van benodigde grootheden met betrekking tot de debieten en verblijftijden cascade aerator
  %Ql       = Ql/3600;            % Omzetten van het debiet van m3/h -> m3/s
  %Td       = (NumCel*VBak)/Ql;   % Bepalen van de gemiddelde verblijftijd in de plaatbe
  %TijdStap = (VBak)/Ql;          % Bepalen van de gemiddelde verblijftijd in één volledig gemengd vat
  
  
  
  
  %Bepalen van benodigde grootheden met betrekking tot de debieten en verblijftijden plate aerator
  Ql       = Ql/3600;              % Omzetten van het debiet van m3/h -> m3/s
  RQ       = QgTot/Ql;             % Lucht water verhouding [-]
  VWater   = Popp*(PercWat*Htot);  % Watervolume in het bellenbed [m3]
  Td       = VWater/Ql;            % Bepalen van de gemiddelde verblijftijd in de plaatbeluchter
  TijdStap = Td/NumCel;            % Bepalen van de gemiddelde verblijftijd in één volledig gemengd vat
  
  
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
%Aantal     = 4;                        % De laatste volledig gemengde vaten, Aantal ( Aantal =< NumCel), hebben 
%TijdAantal = 0.8;                      % een deel, TijdAantal (0 =< TijdAantal =< 1) van de totale verblijftijd
%Tel        = 0;                        % initialiseren teller
%for Tel=1:1:(NumCel-Aantal)
%  TijdStap(Tel,1)=((1-TijdAantal)*Td)/(NumCel-Aantal);
%end
%for Tel=(NumCel-Aantal+1):1:NumCel
%  TijdStap(Tel,1)=(TijdAantal*Td)/Aantal;
%end
%%%%%%%%


  %Benodigde constanten
  cStap  = 1; %constante voor verblijftijden

  %De relatieve molecuulmassa's [mg/mol] 
  MrCO2  = 1000*44.01;
  MrCO3  = 1000*60.01;
  MrHCO3 = 1000*61.02;
  MrH2S  = 1000*34.08;
  MrO2   = 1000*31.9988;
  MrCH4  = 1000*16.04303; 
  MrN2   = 1000*28.0134;
    
%   MrFe   = 1000*55.847;
%   MrCa   = 1000*40.02;
%   MrCaCO3= 1000*100.08935; 
 
  
  
    
  %Constanten voor de berekening van de gasconcentraties in de lucht
  Po     = 101325;                                                           % po = standaarddruk zeeniveau [Pa]  
%   pw     = [  611   657   706   758   814   873   935  1002  1073  1148 ...  % pw = waterdampspanning 0-50 Celsius [Pa]
%              1228  1313  1403  1498  1599  1706  1819  1938  2064  2198 ...
%              2339  2488  2645  2810  2985  3169  3363  3567  3782  4008 ...
%              4246  4495  4758  5034  5323  5627  5945  6280  6630  6997 ...
%              7381  7784  8205  8646  9108  9590 10094 10620 11171 11745 ...
%             12344]; 
  R      = 8.3143;                                                            % R = universele gasconstante [J/(K*mol)] 
  
  pw = 1070*exp(0.04986*Tg)-525.1;
  
  %Gasconcentraties in de lucht (Temperatuur in Kelvin)
  cgoO2  = (0.20948*(Po-pw)*(MrO2 /1000))/(R*(Tg+273)); 
  cgoCH4 =  0; 
  cgoCO2 = (0.00032*(Po-pw)*(MrCO2/1000))/(R*(Tg+273));
  cgoH2S =  0; 
  cgoN2  = (0.78084*(Po-pw)*(MrN2 /1000))/(R*(Tg+273));
  
  %Distributiecoëfficiënten van gassen in water voor 0, 10, 20 en 30 graden Celsius
%   TkD    = [0     ;10    ;20    ;30    ];
%   TkDO2  = [0.0493;0.0398;0.0337;0.0296]; 
%   TkDCH4 = [0.0556;0.0433;0.0335;0.0306]; 
%   TkDCO2 = [1.7100;1.2300;0.9420;0.7380];
%   TkDN2  = [0.0230;0.0192;0.0166;0.0151];
%   TkDH2S = [4.6900;3.6500;2.8700;2.3000];  % De kDH2S bij 30 graden 2,3 is door mij verzonnen (geen literatuur waarde)
%   
%   %Berekening distributiecoëfficiënten voor tussenliggende temperaturen door lineaire interpolatie
%   kDO2   = INTERP1Q(TkD,TkDO2, Tl);
%   kDCH4  = INTERP1Q(TkD,TkDCH4,Tl);
%   kDCO2  = INTERP1Q(TkD,TkDCO2,Tl);
%   kDH2S  = INTERP1Q(TkD,TkDH2S,Tl);
%   kDN2   = INTERP1Q(TkD,TkDN2, Tl);
  
  kDO2  = 0.02727*exp(-0.0426*Tl)+0.02202;
  kDCH4 = 0.03227*exp(-0.05315*Tl)+0.02352;
  kDCO2 = 1.307*exp(-0.04489*Tl)+0.4015;
  kDN2  = 5.75e-006*Tl^2-0.0004355*Tl+0.023;
  kDH2S = 0.001175*Tl^2-0.1148*Tl+4.688;
  
  
  %Vergelijkingen voor de diffusiecoëfficiënten, best fit bij 10, 20 en 30 graden Celsius, bruikbaar van 0-40 Celsius
  DifO2  = 1/(9.048299e-1 - 1.961736e-2*Tl + 1.076824e-4*Tl^2)*1e-9;
  DifCH4 = 1/(1.081256    - 2.310800e-2*Tl + 1.189257e-4*Tl^2)*1e-9;
  DifCO2 = 1/(9.644559e-1 - 2.058414e-2*Tl + 1.061623e-4*Tl^2)*1e-9;
  DifH2S = 1/(1.15095     - 2.461722e-2*Tl + 1.265363e-4*Tl^2)*1e-9;
  DifN2  = 1/(9.874819e-1 - 2.112977e-2*Tl + 1.121742e-4*Tl^2)*1e-9;
 
  %De macht van de diffussiecoefficient
  n     = 1;
  k2O2  = k2CH4*(DifO2 /DifCH4)^n;
  k2CO2 = k2CH4*(DifCO2/DifCH4)^n;
  k2N2  = k2CH4*(DifN2 /DifCH4)^n;
  k2H2S = k2CH4*(DifH2S/DifCH4)^n;


  % Stromingsmatrices
  % LET OP, VOOR GEVORDERDEN:
  % Het plaatbe model heeft de mogelijkheid om de ijzeroxidatie niet alleen in toenemende mate plaats te laten vinden
  % maar ook constant over de waterstroom of geheel geconcentreerd in de laatste stap. Mocht dit wenselijk zijn dan 
  % moet in 'flag == 1' de bijbehorende regels worden gebruikt.
  MatQ1 = Matrix1(TijdStap,NumCel);
%   MatQ2 = rot90(eye(NumCel));
%   MatQ3 = Matrix1(TijdStap,NumCel+1)
  MatQ4 = Matrix2(TijdStap,NumCel);        % constante ijzeroxidatie over waterstroom (stapjes)
%   MatQ5 = Matrix3(TijdStap,NumCel);        % toenemende ijzeroxidatie over waterstroom (stapjes)
%  MatQ6 = Matrix1(TijdStap,1);
%  MatQ7 = Matrix4(TijdStap,NumCel);        % al het ijzer wordt in de laatste stap geoxideerd
% Indien aangepaste verblijftijdsspreidingscurven worden toegepast moet de bovenstaande MatQ3, MatQ4 en MatQ7
% worden uitgezet en moeten de twee onderstaande regels met MatQ3 worden gebruikt. Het is dus alleen mogelijk
% met de aangepaste verblijftijdspreidingscurven te werken bij toenemende oxidatie over de waterstroom, 
% zie ook 'aangepaste verblijftijdsspreidingscurven'.
%  TijdStapVblT = [TijdStap;1]; 
%  MatQ3 = M1gasuit(TijdStapVblT,NumCel+1);


  %De verschillende evenwichtsconstanten (Temperatuur in Kelvin)
  T      = (Tl+273);
%   pK1    = 356.3094 + 0.06091964*T - 21834.37/T - 126.8339*log10(T) + 1684915/(T^2);
%   pK2    = 107.8871 + 0.03252849*T - 5151.79/T  - 38.92561*log10(T) + 563713.9/(T^2);

  
  %de concentraties in [mol/l] (met gebruik making van activiteiten):
  
  coHCO3 = (coHCO3/MrHCO3); %*fi(1,4,EGVo);
  
  %coCO2  = (10^(pK1-pHo+log10(coHCO3)));
  %coCO3  = (10^(-pK2+pHo+log10(coHCO3)));
  
  IonStrength = 0.183*EGVo;
  f = CE_Activity(IonStrength);
  [K1,K2,Kw,Ks] = KValues(T);
  %coCO21=CE_pHHCO3_CO2(pHo,coHCO3,K1,K2,Kw,f);
  coCO2=CE_pHM_CO2(pHo,coMn,K1,K2,Kw,f);
  %Mn=CE_pHHCO3_M(pH,HCO3,K1,K2,Kw,f);
    
  coO2   = coO2/MrO2;
  coCH4  = coCH4/MrCH4;
  coH2S  = coH2S/MrH2S;
  coN2   = coN2/MrN2;
  cgoO2  = cgoO2/MrO2;
  cgoCH4 = cgoCH4/MrCH4;
  cgoCO2 = cgoCO2/MrCO2;
  cgoN2  = cgoN2/MrN2;
  cgoH2S = cgoH2S/MrH2S; 
  
  %coHCO3 = coHCO3/fi(1,4,EGVo);
  
%   coFe2  = coFe2/MrFe;
%   coFe3  = coFe3/MrFe;
%   coFe   = PercFe*coFe2;  % hoeveelheid geoxideerd ijzer
%   coCa2  = coCa2/MrCa;
%   coCa   = PercCa*coCa2;  % hoeveelheid neergeslagen calcium
%   coCaCO3= coCaCO3/MrCa;
  


  %Dit blokje hoort bij toenemende ijzeroxidatie over stapjes
%   KFe = 3;% snelheid van ijzeroxidatie
%   p   = cumsum(1:KFe:KFe*NumCel);
%   p1  = coFe/p(1,NumCel);
%   p2  = coFe3/p(1,NumCel);
%   pFe = p1*(1:KFe:KFe*NumCel);
%   pFe = rot90(pFe);
%   pFe = flipud(pFe);
%   pFe3 = p2*(1:KFe:KFe*NumCel);
%   pFe3 = rot90(pFe3);
%   pFe3 = flipud(pFe3);
  
  
%   %Dit blokje hoort bij toenemende ontharding over stapjes
%   KCa = 3;% snelheid van ontharding
%   q   = cumsum(1:KCa:KCa*NumCel);
%   q1  = coCa/q(1,NumCel);
%   q2  = coCaCO3/q(1,NumCel);
%   qCa = q1*(1:KCa:KCa*NumCel);
%   qCa = rot90(qCa);
%   qCa = flipud(qCa);
%   qCaCO3 = q2*(1:KCa:KCa*NumCel);
%   qCaCO3 = rot90(qCaCO3);
%   qCaCO3 = flipud(qCaCO3);

  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

end; % of any(abs(flag)==[1 2 3])


if flag == 1, % Continuous states derivative calculation

  % default derivative =0;
  sys = zeros(B.CStates,1);
  
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the derivatives of the continuous states
  % eg. sys(1) = (u(U.Temperature)-x(1))/P.Volume;


  sys(1:NumCel)=MatQ1*[coO2;x(1:NumCel)]+k2O2*kDO2*x(NumCel+1:2*NumCel)-k2O2*x(1:NumCel);        %-0.25*MatQ5*[pFe;x(8*NumCel+1:9*NumCel)];
  sys(NumCel+1:2*NumCel)=MatQ4*[cgoO2*(QgVers/QgTot)+(sum(x(NumCel+1:2*NumCel))/NumCel)*(QgRec/QgTot);x(NumCel+1:2*NumCel)]-((k2O2*kDO2)/(RQ/NumCel))*x(NumCel+1:2*NumCel)+(k2O2/(RQ/NumCel))*x(1:NumCel);
  sys(2*NumCel+1:3*NumCel)=MatQ1*[coCH4;x(2*NumCel+1:3*NumCel)]+k2CH4*kDCH4*x(3*NumCel+1:4*NumCel)-k2CH4*x(2*NumCel+1:3*NumCel);
  sys(3*NumCel+1:4*NumCel)=MatQ4*[cgoCH4*(QgVers/QgTot)+(sum(x(3*NumCel+1:4*NumCel))/NumCel)*(QgRec/QgTot);x(3*NumCel+1:4*NumCel)]-((k2CH4*kDCH4)/(RQ/NumCel))*x(3*NumCel+1:4*NumCel)+(k2CH4/(RQ/NumCel))*x(2*NumCel+1:3*NumCel);
  sys(4*NumCel+1:5*NumCel)=MatQ1*[coCO2;x(4*NumCel+1:5*NumCel)]+k2CO2*kDCO2*x(5*NumCel+1:6*NumCel)-k2CO2*x(4*NumCel+1:5*NumCel);          %+2*MatQ5*[pFe;x(8*NumCel+1:9*NumCel)]+MatQ5*[qCa;x(10*NumCel+1:11*NumCel)];
  sys(5*NumCel+1:6*NumCel)=MatQ4*[cgoCO2*(QgVers/QgTot)+(sum(x(5*NumCel+1:6*NumCel))/NumCel)*(QgRec/QgTot);x(5*NumCel+1:6*NumCel)]-((k2CO2*kDCO2)/(RQ/NumCel))*x(5*NumCel+1:6*NumCel)+(k2CO2/(RQ/NumCel))*x(4*NumCel+1:5*NumCel);
  sys(6*NumCel+1:7*NumCel)=MatQ1*[coMn;x(6*NumCel+1:7*NumCel)];
  sys(7*NumCel+1:8*NumCel)=MatQ1*[coN2;x(7*NumCel+1:8*NumCel)]+k2N2*kDN2*x(8*NumCel+1:9*NumCel)-k2N2*x(7*NumCel+1:8*NumCel);
  sys(8*NumCel+1:9*NumCel)=MatQ4*[cgoN2*(QgVers/QgTot)+(sum(x(8*NumCel+1:9*NumCel))/NumCel)*(QgRec/QgTot);x(8*NumCel+1:9*NumCel)]-((k2N2*kDN2)/(RQ/NumCel))*x(8*NumCel+1:9*NumCel)+(k2N2/(RQ/NumCel))*x(7*NumCel+1:8*NumCel);
  sys(9*NumCel+1:10*NumCel)=MatQ1*[coH2S;x(9*NumCel+1:10*NumCel)]+k2H2S*kDH2S*x(10*NumCel+1:11*NumCel)-k2H2S*x(9*NumCel+1:10*NumCel);
  sys(10*NumCel+1:11*NumCel)=MatQ4*[cgoH2S*(QgVers/QgTot)+(sum(x(10*NumCel+1:11*NumCel))/NumCel)*(QgRec/QgTot);x(10*NumCel+1:11*NumCel)]-((k2H2S*kDH2S)/(RQ/NumCel))*x(10*NumCel+1:11*NumCel)+(k2H2S/(RQ/NumCel))*x(9*NumCel+1:10*NumCel);



%  sys(7*NumCel+1:8*NumCel)=MatQ1*[coHCO3;x(7*NumCel+1:8*NumCel)]-2*MatQ5*[pFe;x(8*NumCel+1:9*NumCel)]-2*MatQ5*[qCa;x(10*NumCel+1:11*NumCel)];
%  sys(7*NumCel+1:8*NumCel)=MatQ1*[coHCO3;x(7*NumCel+1:8*NumCel)]-2*MatQ7*[coFe;x(8*NumCel+1:9*NumCel)];
%  sys(8*NumCel+1:9*NumCel)=-10*x(8*NumCel+1:9*NumCel);
%  sys(9*NumCel+1:10*NumCel)=MatQ1*[coFe3;x(9*NumCel+1:10*NumCel)]+MatQ5*[(pFe-PercSlib*(pFe+pFe3));x(8*NumCel+1:9*NumCel)];
%  sys(9*NumCel+1:10*NumCel)=MatQ1*[coFe3;x(9*NumCel+1:10*NumCel)]+MatQ7*[(PercFe*coFe2-PercSlib*(coFe2+coFe3));x(8*NumCel+1:9*NumCel)];
%  sys(10*NumCel+1:11*NumCel)=-10*x(10*NumCel+1:11*NumCel);
%  sys(11*NumCel+1:12*NumCel)=MatQ1*[coCaCO3;x(11*NumCel+1:12*NumCel)]+MatQ5*[qCa;x(10*NumCel+1:11*NumCel)];
%  sys(12*NumCel+1:13*NumCel)=MatQ1*[coN2;x(12*NumCel+1:13*NumCel)]+k2N2*kDN2*x(13*NumCel+1:14*NumCel)-k2N2*x(12*NumCel+1:13*NumCel);
%  sys(13*NumCel+1:14*NumCel)=MatQ4*[cgoN2*(QgVers/QgTot)+(sum(x(13*NumCel+1:14*NumCel))/NumCel)*(QgRec/QgTot);x(13*NumCel+1:14*NumCel)]-((k2N2*kDN2)/(RQ/NumCel))*x(13*NumCel+1:14*NumCel)+(k2N2/(RQ/NumCel))*x(12*NumCel+1:13*NumCel);
%  sys(14*NumCel+1:15*NumCel)=MatQ1*[coH2S;x(14*NumCel+1:15*NumCel)]+k2H2S*kDH2S*x(15*NumCel+1:16*NumCel)-k2H2S*x(14*NumCel+1:15*NumCel);
%  sys(15*NumCel+1:16*NumCel)=MatQ4*[cgoH2S*(QgVers/QgTot)+(sum(x(15*NumCel+1:16*NumCel))/NumCel)*(QgRec/QgTot);x(15*NumCel+1:16*NumCel)]-((k2H2S*kDH2S)/(RQ/NumCel))*x(15*NumCel+1:16*NumCel)+(k2H2S/(RQ/NumCel))*x(14*NumCel+1:15*NumCel);





  
%   sys(9*NumCel+1)=MatQ6*[cgoH2S;x(9*NumCel+1)]-((k2H2S*kDH2S)/RQeff)*x(9*NumCel+1)+(k2H2S/RQeff)*x(8*NumCel+1);
%   x(9*NumCel+1)=((QgTot-RQeff*Ql)/QgTot)*cgoH2S+((RQeff*Ql)/QgTot)*x(9*NumCel+1);
%   if NumCel >= 2
%     for p=2:NumCel
%       sys(9*NumCel+p)=MatQ6*[x(9*NumCel+p-1);x(9*NumCel+p)]-((k2H2S*kDH2S)/RQeff)*x(9*NumCel+p)+(k2H2S/RQeff)*x(8*NumCel+p);
%       x(9*NumCel+p)=((QgTot-RQeff*Ql)/QgTot)*x(9*NumCel+p-1)+((RQeff*Ql)/QgTot)*x(9*NumCel+p);
%     end
%   else
%   end
  
%   sys(6*NumCel+1:7*NumCel)=MatQ1*[cStap;x(6*NumCel+1:7*NumCel)];
% 
%   %  sys(7*NumCel+1:8*NumCel)=MatQ1*[coHCO3;x(7*NumCel+1:8*NumCel)]-2*MatQ7*[coFe;x(8*NumCel+1:9*NumCel)];
% %  sys(7*NumCel+1:8*NumCel)=MatQ1*[coHCO3;x(7*NumCel+1:8*NumCel)]-2*MatQ4*[(coFe/NumCel);x(8*NumCel+1:9*NumCel)];
% 
%   sys(7*NumCel+1:8*NumCel)=MatQ1*[coHCO3;x(7*NumCel+1:8*NumCel)]-2*MatQ5*[pFe;x(8*NumCel+1:9*NumCel)]-2*MatQ5*[qCa;x(10*NumCel+1:11*NumCel)];
%   sys(8*NumCel+1:9*NumCel)=-10*x(8*NumCel+1:9*NumCel);

  %  sys(9*NumCel+1:10*NumCel)=MatQ1*[coFe3;x(9*NumCel+1:10*NumCel)]+MatQ7*[(PercFe*coFe2-PercSlib*(coFe2+coFe3));x(8*NumCel+1:9*NumCel)];
%  sys(9*NumCel+1:10*NumCel)=MatQ1*[coFe3;x(9*NumCel+1:10*NumCel)]+MatQ4*[(PercFe*coFe2-PercSlib*(coFe2+coFe3))/NumCel;x(8*NumCel+1:9*NumCel)];
  
%   sys(9*NumCel+1:10*NumCel)=MatQ1*[coFe3;x(9*NumCel+1:10*NumCel)]+MatQ5*[(pFe-PercSlib*(pFe+pFe3));x(8*NumCel+1:9*NumCel)];
%   sys(10*NumCel+1:11*NumCel)=-10*x(10*NumCel+1:11*NumCel);
%   sys(11*NumCel+1:12*NumCel)=MatQ1*[coCaCO3;x(11*NumCel+1:12*NumCel)]+MatQ5*[qCa;x(10*NumCel+1:11*NumCel)];
  
%
% if P.Vair > 0
%      sys(11*NumCel+1)=(cgoO2*QgTot -(x(NumCel)-coO2)*Ql - x(11*NumCel+1)*QgTot)/Vair; % O2 in gas
%      sys(11*NumCel+2)=(cgoCH4*QgTot -(x(3*NumCel)-coCH4)*Ql - x(11*NumCel+2)*QgTot)/Vair; % CH4 in gas
%      sys(11*NumCel+3)=(cgoCO2*QgTot -(x(5*NumCel)-coCO2)*Ql - x(11*NumCel+3)*QgTot)/Vair; % CO2 in gas
%      sys(11*NumCel+4)=(cgoN2*QgTot -(x(8*NumCel)-coN2)*Ql - x(11*NumCel+4)*QgTot)/Vair; % N2 in gas
%      sys(11*NumCel+5)=(cgoH2S*QgTot -(x(10*NumCel)-coH2S)*Ql - x(11*NumCel+5)*QgTot)/Vair; % H2S in gas
%  end
  
 
  
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

   sys(U.Oxygen)=x(NumCel)*MrO2;
   sys(U.Methane)=x(3*NumCel)*MrCH4;
   sys(U.Carbon_dioxide)=x(5*NumCel)*MrCO2;
   CO2eff=x(5*NumCel);
   sys(U.Mnumber)=x(7*NumCel)*1000;
   Mneff=x(7*NumCel);
%    sys(U.Bicarbonate)=x(8*NumCel)*MrHCO3;
   %sys(U.pH)=pK1-log10(x(5*NumCel))+log10(x(8*NumCel)*fi(1,4,EGVo));
   sys(U.pH)=CE_CO2M_pH(CO2eff,Mneff,K1,K2,Kw,f,pHo);
   %testpH=sys(U.pH)
   sys(U.Nitrogen)=x(8*NumCel)*MrN2;
   sys(U.Hydrogen_sulfide)=x(10*NumCel)*MrH2S;
   
 
   
   %sys(U.Clcium_carbonate)=x(12*NumCel)*MrCaCO3;
%    sys(U.Iron2)=(coFe2*(1-PercFe)+x(9*NumCel))*MrFe;
%    sys(U.Iron3)=x(10*NumCel)*MrFe;
%    sys(U.Calcium)=(coCa2*(1-PercCa)+x(11*NumCel))*MrCa;
  % Determine extra measurements
  % eg. sys(U.Number+1) = x(1)/P.Opp;
  
  
   %De O2, CH4, CO2, N2 en H2S concentraties in water, lucht en de verzadigingsconcentraties
   
%    x(NumCel+1)=((QgTot-RQeff*Ql)/QgTot)*cgoO2+((RQeff*Ql)/QgTot)*x(NumCel+1);
%    if NumCel >= 2
%      for p=2:NumCel
%        x(NumCel+p)=((QgTot-RQeff*Ql)/QgTot)*x(NumCel+p-1)+((RQeff*Ql)/QgTot)*x(NumCel+p);
%      end
%    else
%    end 
% 
%    x(3*NumCel+1)=((QgTot-RQeff*Ql)/QgTot)*cgoCH4+((RQeff*Ql)/QgTot)*x(3*NumCel+1);
%    if NumCel >= 2
%      for p=2:NumCel
%        x(3*NumCel+p)=((QgTot-RQeff*Ql)/QgTot)*x(3*NumCel+p-1)+((RQeff*Ql)/QgTot)*x(3*NumCel+p);
%      end
%    else
%    end
% 
%    x(5*NumCel+1)=((QgTot-RQeff*Ql)/QgTot)*cgoCO2+((RQeff*Ql)/QgTot)*x(5*NumCel+1);
%    if NumCel >= 2
%      for p=2:NumCel
%        x(5*NumCel+p)=((QgTot-RQeff*Ql)/QgTot)*x(5*NumCel+p-1)+((RQeff*Ql)/QgTot)*x(5*NumCel+p);
%      end
%    else
%    end
%    
%    x(7*NumCel+1)=((QgTot-RQeff*Ql)/QgTot)*cgoN2+((RQeff*Ql)/QgTot)*x(7*NumCel+1);
%    if NumCel >= 2
%      for p=2:NumCel
%        x(7*NumCel+p)=((QgTot-RQeff*Ql)/QgTot)*x(7*NumCel+p-1)+((RQeff*Ql)/QgTot)*x(7*NumCel+p);
%      end
%    else
%    end
%    
%    x(9*NumCel+1)=((QgTot-RQeff*Ql)/QgTot)*cgoH2S+((RQeff*Ql)/QgTot)*x(9*NumCel+1);
%    if NumCel >= 2
%      for p=2:NumCel
%        x(9*NumCel+p)=((QgTot-RQeff*Ql)/QgTot)*x(9*NumCel+p-1)+((RQeff*Ql)/QgTot)*x(9*NumCel+p);
%      end
%    else
%    end
   
   sys(U.Number+1:U.Number+(NumCel+1))=MrO2*[coO2;x(1:NumCel)];
   sys(U.Number+1+(NumCel+1):U.Number+2*(NumCel+1))=MrO2*[cgoO2;x(NumCel+1:2*NumCel)];
   sys(U.Number+1+2*(NumCel+1):U.Number+3*(NumCel+1))=MrO2*kDO2*[cgoO2;x(NumCel+1:2*NumCel)];
   sys(U.Number+1+3*(NumCel+1):U.Number+4*(NumCel+1))=MrCH4*[coCH4;x(2*NumCel+1:3*NumCel)];
   sys(U.Number+1+4*(NumCel+1):U.Number+5*(NumCel+1))=MrCH4*[cgoCH4;x(3*NumCel+1:4*NumCel)];
   sys(U.Number+1+5*(NumCel+1):U.Number+6*(NumCel+1))=MrCH4*kDCH4*[cgoCH4;x(3*NumCel+1:4*NumCel)];
   sys(U.Number+1+6*(NumCel+1):U.Number+7*(NumCel+1))=MrCO2*[coCO2;x(4*NumCel+1:5*NumCel)];
   sys(U.Number+1+7*(NumCel+1):U.Number+8*(NumCel+1))=MrCO2*[cgoCO2;x(5*NumCel+1:6*NumCel)];
   sys(U.Number+1+8*(NumCel+1):U.Number+9*(NumCel+1))=MrCO2*kDCO2*[cgoCO2;x(5*NumCel+1:6*NumCel)];
   sys(U.Number+1+9*(NumCel+1):U.Number+10*(NumCel+1))=MrN2*[coN2;x(7*NumCel+1:8*NumCel)];
   sys(U.Number+1+10*(NumCel+1):U.Number+11*(NumCel+1))=MrN2*[cgoN2;x(8*NumCel+1:9*NumCel)];
   sys(U.Number+1+11*(NumCel+1):U.Number+12*(NumCel+1))=MrN2*kDN2*[cgoN2;x(8*NumCel+1:9*NumCel)];
   sys(U.Number+1+12*(NumCel+1):U.Number+13*(NumCel+1))=MrH2S*[coH2S;x(9*NumCel+1:10*NumCel)];
   sys(U.Number+1+13*(NumCel+1):U.Number+14*(NumCel+1))=MrH2S*[cgoH2S;x(10*NumCel+1:11*NumCel)];
   sys(U.Number+1+14*(NumCel+1):U.Number+15*(NumCel+1))=MrH2S*kDH2S*[cgoH2S;x(10*NumCel+1:11*NumCel)];

%    %Verblijftijd voor C- en F-functies
%    %sys(U.Number+1+9*(NumCel+1):U.Number+10*(NumCel+1))=[cStap;x(6*NumCel+1:7*NumCel)];
%    sys(U.Number+1+15*(NumCel+1):U.Number+16*(NumCel+1))=MatQ3*[cStap;x(6*NumCel+1:7*NumCel);x(7*NumCel)]; %laatste term valt er gewoon uit

%    %pH
%    sys(U.Number+1+16*(NumCel+1):U.Number+17*(NumCel+1))=[pK1*ones(NumCel+1,1)-log10([coCO2;x(4*NumCel+1:5*NumCel)])+log10([coHCO3;x(7*NumCel+1:8*NumCel)]*fi(1,4,EGVo))];
%    sys(U.Number+1+17*(NumCel+1):U.Number+18*(NumCel+1))=MrCO2*[coCO2;x(4*NumCel+1:5*NumCel)];
%    sys(U.Number+1+18*(NumCel+1):U.Number+19*(NumCel+1))=MrHCO3*([coHCO3;x(7*NumCel+1:8*NumCel)]);

%    %Fe2+, Fe3+ 
%    sys(U.Number+1+19*(NumCel+1):U.Number+20*(NumCel+1))=MrFe*(coFe2*ones(NumCel+1,1)-[coFe3;x(9*NumCel+1:10*NumCel)]+coFe3*ones(NumCel+1,1));
%    sys(U.Number+1+20*(NumCel+1):U.Number+21*(NumCel+1))=MrFe*[coFe3;x(9*NumCel+1:10*NumCel)];
%    
%    %Ca en CaCO3
%    sys(U.Number+1+21*(NumCel+1):U.Number+22*(NumCel+1))=MrCa*(coCa2*ones(NumCel+1,1)-[coCaCO3;x(11*NumCel+1:12*NumCel)]+coCaCO3*ones(NumCel+1,1));
%    sys(U.Number+1+22*(NumCel+1):U.Number+23*(NumCel+1))=MrCa*[coCaCO3;x(11*NumCel+1:12*NumCel)];


  
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif flag == 0
  % initialize Model
  % [cs,ds,out,in,,direct]
  sys = [B.CStates,B.DStates,U.Number+B.Measurements,U.Number+B.Setpoints, 0, B.Direct,1];
  ts = [B.SampleTime,0];
  str = 'plaatb';
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


% % The following function returns the matrix Q2 for aeration
 
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
% 
% 
% % The following function returns the matrix Q3 for aeration
% 
% function val = Matrix3(T,N)
% 
% a     = 1./T;
% v1=[[a.*ones(N,1)], [-a.*ones(N,1)]];
% q1=spdiags(v1,[0,N],N,2*N);
% val = [q1];
% 
% 
% % The following function returns the matrix Q4 for aeration
% 
% function val = Matrix4(T,N)
% 
% a     = 1./T;
% v1=[-a.*ones(N,1)];
% q1=spdiags(v1,[1],N,N+1);
% Tel=0;
% for p=1:N-1
%   Tel=Tel+1;
%   q1(Tel,1)=0;
% end
% q1(N,1)=1/T;
% val = [q1];
% 
% 
% % The following function returns the ion activity
% 
% function [fiF] = fi(z,a,EGV)
% 
% EGV = EGV/1000;% S/m
% I = 0.183*EGV;% mol/l benaderingsformule
% if I>=0 & I<0.1
%   fiF=10^(-0.5*z^2*(I^0.5/(1+0.33*a*I^0.5)));
% elseif 0.1<=I & I<=0.5
%   fiF=10^(-0.5*z^2*((I^0.5/(1+0.33*a*I^0.5))-0.2*I));
% else
%  error(['Ongeldige Waarde EGV']);
% end
