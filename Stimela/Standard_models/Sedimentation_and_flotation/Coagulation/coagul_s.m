function [sys,x0,str,ts] = coagul_s(t,x,u,flag,B,x0,U,P),
%  [sys,x0,str,ts] = coagul_s(t,x,u,flag,B,x0,U,P),
%    Stimela S-Function
%
% t = time
% x = state vector, filled with continuous states (flag 1) or
%                      discrete states (flag 2)
% u = input vector
%
% P =  proces parameters, filled with coagul_p.m and defined in coagul_d.m
% B =  Model size, filled with coagul_i.m,
% x0 = initial state, filled with coagul_i.m,
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
  %NumCel = P.NumCel;
  NumCel = 1;
  %Surf    = P.Surf;
  Vol    = P.Volume;
  G10    = P.G10;
  Ka     = P.Ka;
  Kb     = P.Kb;
  k1     = P.k1;
  k2     = P.k2;
  a1     = P.a1;
  a2     = P.a2;
  a3     = P.a3;
  b      = P.b;
  %L      = P.Length;
  %dy     = Length/NumCel;
  
  Susp   = u(U.Suspended_solids);   %mg/l
  Susp   = Susp/1000;               %kg/m3
  Temp   = u(U.Temperature);
  Flow   = u(U.Flow)/3600;
  DOC    = u(U.DOC);
  UV     = u(U.UV254);
  pH     = u(U.pH);
 
  LogPr('DOC', DOC);
  LogPr('a1',a1);
  LogPr('a2',a2);
  LogPr('a3',a3);
  
  
  TempK        = u(U.Temperature)+273.16;    % watertemperature           [Kelvin]
  EC          = u(U.Conductivity);          %influent EC                 [mS/m]
%   CO2         = u(U.Carbon_dioxide)/44;     %influent concentratie CO2   [mmol/l]
%   HCO3        = u(U.Bicarbonate)/61;         %influent concentratie HCO3  [mmol/l]
%   CaTot       = u(U.Calcium)/40;            %influent concentratie Ca2+  [mmol/l]
%   SO4         = u(U.Sulphate)/96;           %influent concentratie SO4   [mmol/l]
  Mn           = u(U.Mnumber);               %influent M alkalinity       [mmol/l]
  
%   HCl     = u(U.Number+1);                  %chemical dosing             [mmol/l]
%   H2SO4   = u(U.Number+2);
%   DosCO2  = u(U.Number+3);
%   NaOH    = u(U.Number+4);
%   CaOH2   = u(U.Number+5);
%   Na2CO3  = u(U.Number+6);
%   CaCO3   = u(U.Number+7);
  FeCl3   = u(U.Number+8);
  Fe2SO43 = u(U.Number+9);
  Al2SO43 = u(U.Number+10);
  
  %Dos    = u(U.Number+1);           %coagulant dosing in mmol/l
  Dos = FeCl3+Fe2SO43+Al2SO43;
  
  LogPr('Dos', Dos);
  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % optional: calculated values used for al flags
  % eg. TempArea = u(U.Temperature)/P.Area;
  %vel          = Flow/Surf; %oppervlakte filtratiesnelheid
  %VelReal      = vel;  
  %MatQ1        = Matrix(NumCel);       %Concentratie/laag1
  % Kinematic viscosity
  nu=(497e-6)/((Temp+42.5)^1.5);
  nu10=(497e-6)/((10+42.5)^1.5);
  G=G10*(nu10/nu)^0.5;
  
    IS0 = 0.183*EC;
  f = CE_Activity(IS0);
  
  LogPr('f', f);
  
  [K1,K2,Kw,Ks] = KValues(TempK);
  
  LogPr('K1', K1);
  LogPr('K2', K2);
  LogPr('Kw', Kw);
  LogPr('Ks', Ks);
  
  CO2=CE_pHM_CO2(pH,Mn,K1,K2,Kw,f);
  
  LogPr('CO2', CO2);
  
  CO3=CE_pHM_CO3(pH,Mn,K1,K2,Kw,f);
  HCO3=CE_pHM_HCO3(pH,Mn,K1,K2,Kw,f);
  Pn=CE_pHM_P(pH,Mn,K1,K2,Kw,f);
  H3O = 10^(3-pH)/f;
  OH = Kw/(f^2*H3O);
  IB0 = IS0 - (HCO3/2+2*CO3 +H3O/2 + OH/2);
  
  LogPr('Pn-1', Pn);
  LogPr('Mn-1', Mn);
  
  IB1    = IB0 + 6*FeCl3+15*Fe2SO43+15*Al2SO43;
  Pn     = Pn-3*FeCl3-3*Fe2SO43-3*Al2SO43;
  Mn     = Mn-3*FeCl3-3*Fe2SO43-3*Al2SO43;
  
  LogPr('Pn', Pn);
  LogPr('Mn', Mn);
     
  pH=CE_MP_pH(Mn,Pn,K1,K2,Kw,f);
  CO2=CE_pHM_CO2(pH,Mn,K1,K2,Kw,f);
  CO3=CE_pHM_CO3(pH,Mn,K1,K2,Kw,f);
  HCO3=CE_pHM_HCO3(pH,Mn,K1,K2,Kw,f);
  H3O = 10^(3-pH)/f;
  OH = Kw/(f^2*H3O);
  IS1 = IB1 + (2*CO3+HCO3/2 +H3O/2 + OH/2);
  f = CE_Activity(IS1);
  pH=CE_MP_pH(Mn,Pn,K1,K2,Kw,f);
  CO2=CE_pHM_CO2(pH,Mn,K1,K2,Kw,f);
  CO3=CE_pHM_CO3(pH,Mn,K1,K2,Kw,f);
  HCO3=CE_pHM_HCO3(pH,Mn,K1,K2,Kw,f);
  H3O = 10^(3-pH)/f;
  OH = Kw/(f^2*H3O);
  IS1 = IB1 + (2*CO3+HCO3/2 +H3O/2 + OH/2);
  
  EC = IS1/0.183;

  
  SUV=UV/DOC;
  fN=k1*SUV+k2;
  DOCads = (1-fN)*DOC;
  
  LogPr('DOCads', DOCads);
  
  a = a1*pH+a2*pH^2+a3*pH^3;
  
  LogPr('a',a);
  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

end; % of any(abs(flag)==[1 2 3])


if flag == 1, % Continuous states derivative calculation

  % default derivative =0;
  sys = zeros(B.CStates,1);
  
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the derivatives of the continuous states
  % eg. sys(1) = (u(U.Temperature)-x(1))/P.Volume;
   
  %sys(1:NumCel) = (Flow/Vol)*MatQ1*[Susp;x(1:NumCel)] - Ka*G*x(1:NumCel) + Kb*G^2*x(1:NumCel);
  
   % sys(1:NumCel) = (VelReal/dy)*MatQ1*[Susp;x(1:NumCel)] - Ka*G*x(1:NumCel) + Kb*G^2*x(1:NumCel);
    
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
 
    
  Suspcoag=(1+Dos*Kb*G^2*(Vol/Flow))/(1+Dos*Ka*G*(Vol/Flow))*Susp;  
   
  ceq=((1-b*DOCads+Dos*a*b)-(((1-b*DOCads+Dos*a*b)^2+4*b*DOCads))^0.5)/(-2*b);
  test1=(1-b*DOCads+Dos*a*b);
  LogPr('ceq', ceq);
  LogPr('test1',test1);
  
  DOCcoag = ceq+fN*DOC;
  UVcoag = (DOCcoag/DOC)*UV;  
  
%   IS0 = 0.183*EC;
%   f = CE_Activity(IS0);
%   [K1,K2,Kw,Ks] = KValues(TempK);
%   CO2=CE_pHM_CO2(pH,Mn,K1,K2,Kw,f);
%   CO3=CE_pHM_CO3(pH,Mn,K1,K2,Kw,f);
%   HCO3=CE_pHM_HCO3(pH,Mn,K1,K2,Kw,f);
%   Pn=CE_pHM_P(pH,Mn,K1,K2,Kw,f);
%   H3O = 10^(3-pH)/f;
%   OH = Kw/(f^2*H3O);
%   IB0 = IS0 - (HCO3/2+2*CO3 +H3O/2 + OH/2);
%   
%   IB1    = IB0 + 6*FeCl3+15*Fe2SO43+15*Al2SO43;
%   Pn     = Pn-3*FeCl3-3*Fe2SO43-3*Al2SO43;
%   Mn     = Mn-3*FeCl3-3*Fe2SO43-3*Al2SO43;
%      
%   pH=CE_MP_pH(Mn,Pn,K1,K2,Kw,f);
%   CO2=CE_pHM_CO2(pH,Mn,K1,K2,Kw,f);
%   CO3=CE_pHM_CO3(pH,Mn,K1,K2,Kw,f);
%   HCO3=CE_pHM_HCO3(pH,Mn,K1,K2,Kw,f);
%   H3O = 10^(3-pH)/f;
%   OH = Kw/(f^2*H3O);
%   IS1 = IB1 + (2*CO3+HCO3/2 +H3O/2 + OH/2);
%   f = CE_Activity(IS1);
%   pH=CE_MP_pH(Mn,Pn,K1,K2,Kw,f);
%   CO2=CE_pHM_CO2(pH,Mn,K1,K2,Kw,f);
%   CO3=CE_pHM_CO3(pH,Mn,K1,K2,Kw,f);
%   HCO3=CE_pHM_HCO3(pH,Mn,K1,K2,Kw,f);
%   H3O = 10^(3-pH)/f;
%   OH = Kw/(f^2*H3O);
%   IS1 = IB1 + (2*CO3+HCO3/2 +H3O/2 + OH/2);
%   
%   EC = IS1/0.183;
  
  % default equal to the input with zeros for extra measurements
  sys = [u(1:U.Number); zeros(B.Measurements,1)];

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Determine output for calculated values
  % eg. sys(U.Temparature) = x(1);
  
  %sys(U.Suspended_solids)=x(NumCel)*1000; %Concentratie zwevende stoffen [mg/l]
  sys(U.Suspended_solids)=Suspcoag*1000; 
  sys(U.DOC)= DOCcoag;
  sys(U.UV254)= UVcoag;
  sys(U.Conductivity)      = EC;            %effluent concentration [mS/m]
  sys(U.pH)                = pH;
  sys(U.Mnumber)           = Mn;            %effluent concentration [mmol/l]
  % Determine extra measurements
  % eg. sys(U.Number+1) = x(1)/P.Opp;
  
  %sys(U.Number+1:U.Number+(NumCel+1))= [Suspcoag*1000]; %concentratie SS [mg/l]
  %sys(U.Number+1:U.Number+(NumCel))= x(1:NumCel)*1000; %concentratie SS [mg/l]
 
  
  
  
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif flag == 0
  % initialize Model
  % [cs,ds,out,in,,direct]
  sys = [B.CStates,B.DStates,U.Number+B.Measurements,U.Number+B.Setpoints, 0, B.Direct,1];
  ts = [B.SampleTime,0];
  str = 'coagul';
  x0=x0;
else
    % If flag is anything else, no need to return anything
    % since this is a continuous system
    sys = [];
end



function val = Matrix(N)

v1=[[ones(N,1)], [-ones(N,1)]];
q1=spdiags(v1,[0,1],N,N+1);
val = [q1];

function LogPr(name, d)

    fid=fopen('coagul_s.log','at');
	if (fid~=0)
      fprintf(fid,'%s',name);
      fprintf(fid,'\t%g',d);

      fprintf(fid,'\n');
      fclose(fid);
  end







