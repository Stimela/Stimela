function [sys,x0,str,ts] = mengpH_s(t,x,u,flag,B,x0,U,P),
%  [sys,x0,str,ts] = mengpH_s(t,x,u,flag,B,x0,U,P),
%    Stimela S-Function
%
% t = time
% x = state vector, filled with continuous states (flag 1) or
%                      discrete states (flag 2)
% u = input vector
%
% P =  proces parameters, filled with mengpH_p.m and defined in mengpH_d.m
% B =  Model size, filled with mengpH_i.m,
% x0 = initial state, filled with mengpH_i.m,
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

  mCa = 40;
mCaCO3 = 40+12+3*16;
mHCO3 = 1+12+3*16;
mNaOH = 23+16+1;

  
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

  if any( (~isreal(sys)) | isnan(sys))
    disp('mengpH has complex or nan values in flag=1')
    sys((~isreal(sys))| isnan(sys))=0;
  end

  
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
      
  Debiet1=u(U.Flow);
  Temp1 = u(U.Temperature);
  EC1 = u(U.Conductivity);
  HCO31= u(U.Bicarbonate)/mHCO3;
  pH1 = u(U.pH);
  Ca1 = u(U.Calcium)/mCa;
  TempK1=273.15+Temp1;
  Uionsterkte1=0.183*EC1;

  %/* berekeningen 1*/
  [K1,K2,Kw,Ks] =  KValues(TempK1);
  Factiviteit1 = CE_Activity(Uionsterkte1);
  Mgetal1 = CE_pHHCO3_M(pH1,HCO31,K1,K2,Kw,Factiviteit1);
  Pgetal1 = CE_pHHCO3_P(pH1,HCO31,K1,K2,Kw,Factiviteit1);
  Uionbasissterkte1 = Uionsterkte1- 2* HCO31;

  Debiet2=u(U.Number + U.Flow);
  Temp2 = u(U.Number + U.Temperature);
  EC2 =   u(U.Number + U.Conductivity);
  HCO32= u(U.Number  + U.Bicarbonate)/mHCO3;
  pH2 = u(U.Number + U.pH);
  Ca2 = u(U.Number  + U.Calcium)/mCa;
  TempK2=273.15+Temp2;
  Uionsterkte2=0.183*EC2;

  %/* berekeningen 2*/
  [K1,K2,Kw,Ks] =  KValues(TempK2);
  Factiviteit2 = CE_Activity(Uionsterkte2);
  Mgetal2 = CE_pHHCO3_M(pH2,HCO32,K1,K2,Kw,Factiviteit2);
  Pgetal2 = CE_pHHCO3_P(pH2,HCO32,K1,K2,Kw,Factiviteit2);
  Uionbasissterkte2 = Uionsterkte2- 2* HCO32;
     
  if ((Debiet1+Debiet2)>0)
    
      sys(1:U.Number)=(u(1:U.Number)*Debiet1+u(U.Number+(1:U.Number))*Debiet2)/(Debiet1+Debiet2);
             
      Uionbasissterkte=(Uionbasissterkte1*Debiet1+Uionbasissterkte2*Debiet2)/(Debiet1+Debiet2);
      Mgetal=(Mgetal1*Debiet1+Mgetal2*Debiet2)/(Debiet1+Debiet2);
      Pgetal=(Pgetal1*Debiet1+Pgetal2*Debiet2)/(Debiet1+Debiet2);
      Ca=(Ca1*Debiet1+Ca2*Debiet2)/(Debiet1+Debiet2);
      TempK = (TempK1*Debiet1+TempK2*Debiet2)/(Debiet1+Debiet2);

      [K1,K2,Kw,Ks] =  KValues(TempK);

      Uionsterkte = (Uionsterkte1*Debiet1+Uionsterkte2*Debiet2)/(Debiet1+Debiet2);
      Factiviteit = CE_Activity(Uionsterkte);

      pH = CE_MP_pH(Mgetal,Pgetal,K1,K2,Kw,Factiviteit,pH1);
      HCO3 = CE_pHM_HCO3(pH,Mgetal,K1,K2,Kw,Factiviteit);
      CO3 = CE_pHM_CO3(pH,Mgetal,K1,K2,Kw,Factiviteit);
      Uionsterkte = Uionbasissterkte + 2*HCO3 +CO3/2;

      Factiviteit = CE_Activity(Uionsterkte);
      pH = CE_MP_pH(Mgetal,Pgetal,K1,K2,Kw,Factiviteit,pH);
      HCO3 = CE_pHM_HCO3(pH,Mgetal,K1,K2,Kw,Factiviteit);
      CO3 = CE_pHM_CO3(pH,Mgetal,K1,K2,Kw,Factiviteit);
    else
      warning([gcb ' (t=' num2str(t) ') : Flow1=0 and Flow2=0'])

      TempK = TempK1;
      Uionsterkte = Uionsterkte1;
      HCO3 = HCO31;
      pH=pH1;
      Ca = Ca1;
              
  end
  
  	  sys(U.Flow)=Debiet1+Debiet2;
  	  sys(U.Temperature)=TempK-273.15;
      sys(U.Conductivity)=Uionsterkte/0.183;
      sys(U.Bicarbonate)=HCO3*mHCO3;
      sys(U.pH)=pH;
      sys(U.Calcium)=Ca*mCa;
  
    if any( (~isreal(sys)) | isnan(sys))
      disp([gcb ' has complex or nan values in flag=3'])
      sys((~isreal(sys))| isnan(sys))=0;
    end

  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif flag == 0
  % initialize Model
  % [cs,ds,out,in,,direct]
  sys = [B.CStates,B.DStates,U.Number+B.Measurements,U.Number+B.Setpoints, 0, B.Direct,1];
  ts = [B.SampleTime,0];
  str = 'mengpH';
  x0=x0;
else
    % If flag is anything else, no need to return anything
    % since this is a continuous system
    sys = [];
end
