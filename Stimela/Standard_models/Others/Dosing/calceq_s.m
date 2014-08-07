function [sys,x0,str,ts] = calceq_s(t,x,u,flag,B,x0,U,P),
%  [sys,x0,str,ts] = calceq_s(t,x,u,flag,B,x0,U,P),
%    Stimela S-Function
%
% t = time
% x = state vector, filled with continuous states (flag 1) or
%                      discrete states (flag 2)
% u = input vector
%
% P =  proces parameters, filled with calceq_p.m and defined in calceq_d.m
% B =  Model size, filled with calceq_i.m,
% x0 = initial state, filled with calceq_i.m,
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

  Temp        = u(U.Temperature)+273.16;    % watertemperature           [Kelvin]
  %Ql          = u(U.Flow);                 %water flow                  [m3/h]
  pH          = u(U.pH);                    %influent pH                 [-]
  EC          = u(U.Conductivity);          %influent EC                 [mS/m]
  CO2         = u(U.Carbon_dioxide)/44;     %influent concentratie CO2   [mmol/l]
  HCO3        = u(U.Bicarbonate)/61;         %influent concentratie HCO3  [mmol/l]
  CaTot       = u(U.Calcium)/40;            %influent concentratie Ca2+  [mmol/l]
  SO4         = u(U.Sulphate)/96;           %influent concentratie SO4   [mmol/l]
  Mn           = u(U.Mnumber);               %influent M alkalinity       [mmol/l]
  Pn           = u(U.Pnumber);               %influent P alkalinity       [mmol/l]
  IS          = u(U.Ionstrength);           %influent Ionstrenght        [mmol/l]
  
  TACCacc     = P.TACCacc;
  
  % Dosing of chemicals
  HCl     = u(U.Number+1);                  %chemical dosing             [mmol/l]
  H2SO4   = u(U.Number+2);
  DosCO2  = u(U.Number+3);
  NaOH    = u(U.Number+4);
  CaOH2   = u(U.Number+5);
  Na2CO3  = u(U.Number+6);
  CaCO3   = u(U.Number+7);
  FeCl3   = u(U.Number+8);
  Fe2SO43 = u(U.Number+9);
  Al2SO43 = u(U.Number+10);
  
  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % optional: calculated values used for al flags
  % eg. TempArea = u(U.Temperature)/P.Area;

  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

end; % of any(abs(flag)==[1 2 3])


if flag == 1, % Continuous states derivative calculation

  % default derivative =0;
  sys = zeros(B.CStates,1);
  
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the derivatives of the continuous states
  % eg. sys(1) = (u(U.Temperature)-x(1))/P.Volume;

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
  switch (P.ParIon)
      case 1
          IS = IS;
      case 2
          IS0 = 0.183*EC;
  end
  
  f = CE_Activity(IS0);
  [K1,K2,Kw,Ks] = KValues(Temp);
  
  switch (P.ParEq)
      case 1
          % pH en HCO3
          CO2=CE_pHHCO3_CO2(pH,HCO3,K1,K2,Kw,f);
          CO3=CE_pHHCO3_CO3(pH,HCO3,K1,K2,Kw,f);
          Mn=CE_pHHCO3_M(pH,HCO3,K1,K2,Kw,f);
          Pn=CE_pHHCO3_P(pH,HCO3,K1,K2,Kw,f);
      case 2
          % pH en M
          CO2=CE_pHM_CO2(pH,Mn,K1,K2,Kw,f);
          CO3=CE_pHM_CO3(pH,Mn,K1,K2,Kw,f);
          HCO3=CE_pHM_HCO3(pH,Mn,K1,K2,Kw,f);
          Pn=CE_pHM_P(pH,Mn,K1,K2,Kw,f);
      case 3
          % pH en P
          CO2=CE_pHP_CO2(pH,Pn,K1,K2,Kw,f);
          CO3=CE_pHP_CO3(pH,Pn,K1,K2,Kw,f);
          HCO3=CE_pHP_HCO3(pH,Pn,K1,K2,Kw,f);
          Mn=CE_pHP_M(pH,Pn,K1,K2,Kw,f);
      case 4
          % pH en CO2
          CO3=CE_pHCO2_CO3(pH,CO2,K1,K2,Kw,f);
          HCO3=CE_pHCO2_HCO3(pH,CO2,K1,K2,Kw,f);
          Mn=CE_pHCO2_M(pH,CO2,K1,K2,Kw,f);
          Pn=CE_pHCO2_P(pH,CO2,K1,K2,Kw,f);
      case 5
          %M en P
          CO2=CE_MP_CO2(Mn,Pn,K1,K2,Kw,f);
          CO3=CE_MP_CO3(Mn,Pn,K1,K2,Kw,f);
          HCO3=CE_MP_HCO3(Mn,Pn,K1,K2,Kw,f);
          pH=CE_MP_pH(Mn,Pn,K1,K2,Kw,f);
  end
  
  H3O = 10^(3-pH)/f;
  OH = Kw/(f^2*H3O);
  IB0 = IS0 - (HCO3/2+2*CO3 +H3O/2 + OH/2);
  
  % Dosing
  IB1    = IB0 + 0.5*HCl+2*H2SO4+0.5*NaOH+2*CaOH2+Na2CO3+2*CaCO3+6*FeCl3+15*Fe2SO43+15*Al2SO43;
  CaTot = CaTot+CaOH2+CaCO3;
  Pn     = Pn-HCl-2*H2SO4-DosCO2+NaOH+2*CaOH2+Na2CO3+CaCO3-3*FeCl3-3*Fe2SO43-3*Al2SO43;
  Mn     = Mn-HCl-2*H2SO4+NaOH+2*CaOH2+2*Na2CO3+2*CaCO3-3*FeCl3-3*Fe2SO43-3*Al2SO43;
  SO4   = SO4+H2SO4+3*Fe2SO43+3*Al2SO43;
    
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

  %Determine the supersaturated calcium and the equilibrium pH
 %[CaSO4,Calcium]=freecalcium(CaTot,SO4,Uionsterkte,Temp);
  SIndex = log10(f^8*(CaTot*CO3)/Ks); 
  TACC = CE_TCCP(CaTot,Mn,Pn,K1,K2,Kw,Ks,IS1);
  Cuoplos= 0.52*(HCO3+CO2+CO3)-1.37*pH+2*SO4+10.2;
  Pboplos= -14.1*pH + 12*(Temp-273.16) + 1.135;

  Caeq  = CaTot-TACC;
  Peq   = Pn-TACC;
  Meq   = Mn-2*TACC;
  IBeq    = IB1-2*TACC;
  feq = CE_Activity(IS0);
  pHeq  =CE_MP_pH(Meq,Peq,K1,K2,Kw,feq);
  CO3eq =CE_pHM_CO3(pHeq,Meq,K1,K2,Kw,feq);
  HCO3eq=CE_pHM_HCO3(pHeq,Meq,K1,K2,Kw,feq);
  %ISeq = IBeq + Meq;
  %feq   = CE_Activity(ISeq);
  %pHeq  =CE_MP_pH(Meq,Peq,K1,K2,Kw,feq);
  %CO2eq =CE_pHM_CO2(pHeq,Meq,K1,K2,Kw,feq);
  %CO3eq =CE_pHM_CO3(pHeq,Meq,K1,K2,Kw,feq);
  %HCO3eq=CE_pHM_HCO3(pHeq,Meq,K1,K2,Kw,feq);
  H3Oeq = 10^(3-pHeq)/feq;
  OHeq  = Kw/(feq^2*H3Oeq);
 
  ISeq = IBeq + (2*CO3eq+HCO3eq/2 +H3Oeq/2 + OHeq/2);
  feq   = CE_Activity(ISeq);
  pHeq  =CE_MP_pH(Meq,Peq,K1,K2,Kw,feq);
  CO2eq =CE_pHM_CO2(pHeq,Meq,K1,K2,Kw,feq);
  CO3eq =CE_pHM_CO3(pHeq,Meq,K1,K2,Kw,feq);
  HCO3eq=CE_pHM_HCO3(pHeq,Meq,K1,K2,Kw,feq);
  H3Oeq = 10^(3-pHeq)/feq;
  OHeq  = Kw/(feq^2*H3Oeq);
  
  %Determine pH while TACC=TACCacc
 %[CaSO4,Calcium]=freecalcium(CaTot,SO4,Uionsterkte,Temp);
  %SIndex = log10((CaTot*CO3)/Ks); 
  %TACC = CE_TACC(CaTot,Mn,Pn,K1,K2,Kw,Ks,f);
  %Cuoplos= 0.52*(HCO3+CO2+CO3)-1.37*pH+2*SO4+10.2;
  %Pboplos= -14.1*pH + 12*(Temp-273.16) + 1.135;
  
  %Caeq  = CaTot-TACC;
  %Peq   = Pn-TACC;
  %Meq   = Mn-2*TACC;
  %IBeq    = IB-2*TACC;
  %ISeq = IBeq + 2*Meq;
  %feq   = CE_Activity(ISeq);
  %pHeq  =CE_MP_pH(Meq,Peq,K1,K2,Kw,feq);
  %CO2eq =CE_pHM_CO2(pHeq,Meq,K1,K2,Kw,feq);
  %CO3eq =CE_pHM_CO3(pHeq,Meq,K1,K2,Kw,feq);
  %HCO3eq=CE_pHM_HCO3(pHeq,Meq,K1,K2,Kw,feq);
  %H3Oeq = 10^(3-pHeq)/feq;
  %OHeq  = Kw/(feq^2*H3Oeq);
 
  %ISeq = IBeq + (2*HCO3eq+CO3eq/2 +H3Oeq/2 + OHeq/2);
  %feq   = CE_Activity(ISeq);
  %pHeq  =CE_MP_pH(Meq,Peq,K1,K2,Kw,feq);
  %CO2eq =CE_pHM_CO2(pHeq,Meq,K1,K2,Kw,feq);
  %CO3eq =CE_pHM_CO3(pHeq,Meq,K1,K2,Kw,feq);
  %HCO3eq=CE_pHM_HCO3(pHeq,Meq,K1,K2,Kw,feq);
  %H3Oeq = 10^(3-pHeq)/feq;
  %OHeq  = Kw/(feq^2*H3Oeq);
  
  Caeq1  = CaTot-(TACC-TACCacc);
  Peq1   = Pn-(TACC-TACCacc);
  Meq1   = Mn-2*(TACC-TACCacc);
  IBeq1    = IB1-2*(TACC-TACCacc);
  ISeq1 = IBeq1 + Meq1;
  feq1   = CE_Activity(ISeq1);
  pHeq1  =CE_MP_pH(Meq1,Peq1,K1,K2,Kw,feq1);
  CO2eq1 =CE_pHM_CO2(pHeq1,Meq1,K1,K2,Kw,feq1);
  CO3eq1 =CE_pHM_CO3(pHeq1,Meq1,K1,K2,Kw,feq1);
  HCO3eq1=CE_pHM_HCO3(pHeq1,Meq1,K1,K2,Kw,feq1);
  H3Oeq1 = 10^(3-pHeq1)/feq1;
  OHeq1  = Kw/(feq1^2*H3Oeq1);
 
  ISeq1 = IBeq1 + (2*CO3eq1+HCO3eq1/2 +H3Oeq1/2 + OHeq1/2);
  feq1   = CE_Activity(ISeq1);
  pHeq1  =CE_MP_pH(Meq1,Peq1,K1,K2,Kw,feq1);
  CO2eq1 =CE_pHM_CO2(pHeq1,Meq1,K1,K2,Kw,feq1);
  CO3eq1 =CE_pHM_CO3(pHeq1,Meq1,K1,K2,Kw,feq1);
  HCO3eq1=CE_pHM_HCO3(pHeq1,Meq1,K1,K2,Kw,feq1);
  H3Oeq1 = 10^(3-pHeq1)/feq1;
  OHeq1  = Kw/(feq1^2*H3Oeq1);
  
  sys(U.pH)                = pH;
  sys(U.Mnumber)           = Mn;            %effluent concentration [mmol/l]
  sys(U.Pnumber)           = Pn;            %effluent concentration [mmol/l]
  sys(U.Carbon_dioxide)    = CO2*44;        %effluent concentration [mg/l]
  sys(U.Bicarbonate)       = HCO3*61;       %effluent concentration [mg/l]
  sys(U.Ionstrength)       = IS1;            %effluent concentration [mmol/l]
  sys(U.Calcium)           = CaTot*40;      %effluent concentration [mg/l]
  sys(U.Sulphate)          = SO4*96;        %effluent concentration [mg/l]
  sys(U.Conductivity)      = EC;            %effluent concentration [mS/m]
  
  % Determine extra measurements
  % eg. sys(U.Number+1) = x(1)/P.Opp;
  
  sys(U.Number+1) = SIndex;      % Langelier Index
  sys(U.Number+2) = TACC;        % Supersaturated calcium carbonate (mmol/l)
  sys(U.Number+3) = Cuoplos;     % koperoplossend vermogen
  sys(U.Number+4) = Pboplos;     % loodoplossend vermogen
  sys(U.Number+5) = Caeq*40;     % Equilibrium calcium concentration (mg/l)
  sys(U.Number+6) = pHeq;        % Equilibrium pH
  sys(U.Number+7) = Caeq1*40;    % calcium concentration with accepted supersaturation (mg/l)
  sys(U.Number+8) = pHeq1;       % pH with accepted supersaturation
  
  if any( (~isreal(sys)) | isnan(sys))
      sys((~isreal(sys))| isnan(sys))=0;
  end
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif flag == 0
  % initialize Model
  % [cs,ds,out,in,,direct]
  sys = [B.CStates,B.DStates,U.Number+B.Measurements,U.Number+B.Setpoints, 0, B.Direct,1];
  ts = [B.SampleTime,0];
  str = 'calceq';
  x0=x0;
else
    % If flag is anything else, no need to return anything
    % since this is a continuous system
    sys = [];
end
