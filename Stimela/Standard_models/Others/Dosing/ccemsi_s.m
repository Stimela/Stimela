function [sys,x0,str,ts] = ccemsi_s(t,x,u,flag,B,x0,U,P),
%  [sys,x0,str,ts] = ccemsi_s(t,x,u,flag,B,x0,U,P),
%    Stimela S-Function
%
% t = time
% x = state vector, filled with continuous states (flag 1) or
%                      discrete states (flag 2)
% u = input vector
%
% P =  proces parameters, filled with ccemsi_p.m and defined in ccemsi_d.m
% B =  Model size, filled with ccemsi_i.m,
% x0 = initial state, filled with ccemsi_i.m,
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
  sys = [u(1:U.Number*B.WaterOut); zeros(B.Measurements,1)];

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Determine output for calculated values
  % eg. sys(U.Temparature) = x(1);
  switch (P.ParIon)
      case 1
          IS0 = IS;
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
  
  SIndex = log10(f^8*(CaTot*CO3)/Ks); 
 
  % Determine extra measurements
  % eg. sys(U.Number+1) = x(1)/P.Opp;
  
  sys(1) = SIndex;      % Langelier Index
  
  if any( (~isreal(sys)) | isnan(sys))
      sys((~isreal(sys))| isnan(sys))=0;
  end
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif flag == 0
  % initialize Model
  % [cs,ds,out,in,,direct]
  sys = [B.CStates,B.DStates,U.Number*B.WaterOut+B.Measurements,U.Number*B.WaterIn+B.Setpoints, 0, B.Direct,1];
  ts = [B.SampleTime,1]; % niet tijdens int.
  str = 'ccemsi';
  x0=x0;
else
    % If flag is anything else, no need to return anything
    % since this is a continuous system
    sys = [];
end
