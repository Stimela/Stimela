function [sys,x0,str,ts] = pels25_s(t,x,u,flag,B,x0,U,P),
%  [sys,x0,str,ts] = pels25_s(t,x,u,flag,B,x0,U,P),
%    Stimela S-Function
%
% t = time
% x = state vector, filled with continuous states (flag 1) or
%                      discrete states (flag 2)
% u = input vector
%
% P =  proces parameters, filled with pels25_p.m and defined in pels25_d.m
% B =  Model size, filled with pels25_i.m,
% x0 = initial state, filled with pels25_i.m,
% U = Translationstructure for inout vector, filled in uit Blok00_i.m.
%     Fields are determined by 'st_Varia'
%
% Stimela, 2004

% © Kim van Schagen,

% General purpose calculations
if any(abs(flag)==[1 2 3])
xC=x;
%DebugPr(u);

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % optional: convert input vector to user names
  % eg. Temp = u(U.Temperature);
  % in the code it is also possible to use u(U.Temparature) directly.

  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % optional: calculated values used for al flags
  % eg. TempArea = u(U.Temperature)/P.Area;
mCa = 40;
mCaCO3 = 40+12+3*16;
mHCO3 = 1+12+3*16;
mNaOH = 23+16+1;

A0 	= P.A; % bodem oppervlakte reactor */
Angle = P.Angle; % hoek van de reactor bij conische reactor angle ~=0 */
d0	= P.d0/1000.0; % initiele zand diameter */
rhog= P.rhog; % dichtheid zand */
rhos= P.rhos; % dichtheid caco3 */
rhol= P.rhol;  % dichtheid loog */
sl= P.sl;     % oplossing */
FB = P.FB;    % Geen bed dynamica
KT20  = P.KT20/1000.0;     % KT Invoer naar mmol*/
IoEc = P.IoEc;  % factor EGV naar IS
Df = P.Df;
NumCel = P.NumCel; % aantal cellen */
 
if (NumCel > 20)
    NumCel=20; 
end % Limit number of cells, because of limited memory allocation. */

Q=u(U.Flow)/3600.0; % water flow, limited to 200 m3/h */
Temp=u(U.Temperature); % Temperature in oC, limited to 1 oC */
pH0=u(U.pH); % influent pH between 6 and 9*/
Ca0=u(U.Calcium)/mCa; % influent calcium concentration (mmol/l) */
HCO30=u(U.Bicarbonate)/mHCO3; % influent HCO3 concentration (mmol/l) */
EC=u(U.Conductivity); % influent electrical conductivity mS/m */

NaOH = 1E-3*u(U.Number+1)/(u(U.Flow)+1E-3*u(U.Number+1))*sl*rhol/mNaOH*1E3; %1e3 voor mol/l -> mmol/l
%NGrains = max([u(U.Number+2)*1000.0,0]); % number of grains in
NGrains = max([u(U.Number+2)*1000.0,-inf]); % number of grains in
NPellets = max([u(U.Number+3)*1000.0,0]);  % number of pellets out


% change to kg/s
NGrains = NGrains * rhog * (pi/6*d0^3); %in kg
NPellets = NPellets * rhog * (pi/6*d0^3);

TempK = Temp + 273.15; % Temperature in Kelvin */
nu = 4.96e-4/((Temp+42.5)^(3/2)); % viscosity */
rhow = (0.2198670356299949E16/2199023255552.0+0.4769643019957967E16/281474976710656.0*Temp-0.4604215144723611E16/0.5764607523034235E18*Temp*Temp-212923669458047.0/0.4611686018427388E19*Temp*Temp*Temp+249253633739249.0/0.2361183241434823E22*Temp*Temp*Temp*Temp-0.5426481728272187E16/0.1934281311383407E26*Temp*Temp*Temp*Temp*Temp)/(1.0+0.4865285514884471E16/0.2882303761517117E18*Temp);

KT=1.053^(Temp-20.0)*KT20;

Uionsterkteco=IoEc*EC; % mmol/l benaderingsformule */
Factiefco = CE_Activity(Uionsterkteco);

[K1,K2,Kw,KS]=KValues(TempK);
Mgetal0 = CE_pHHCO3_M(pH0,HCO30,K1,K2,Kw,Factiefco);
Pgetal0 = CE_pHHCO3_P(pH0,HCO30,K1,K2,Kw,Factiefco);
% IS = IB + (2*CO3+HCO3/2+H3O/2+OH/2)
IB0 = Uionsterkteco - HCO30/2 + NaOH/2;

%mixing */
Pgetal0 = Pgetal0+NaOH;
Mgetal0 = Mgetal0+NaOH;  

h=0;
% reactor */
for i=1:NumCel 
  if Angle == 0
      A(i) = A0;
  else
      A(i)      = 0.25*pi*(sqrt(A0/(0.25*pi))+2*h*tan(Angle*pi/180))^2;
  end
  Ca(i)     = xC(i);
  Mgetal(i) = xC(NumCel+i);
  Pgetal(i) = xC(2*NumCel+i);
  IB(i)     = abs(xC(3*NumCel+i));
  CaCO3(i)  = xC(4*NumCel+i);
  mg(i)     = xC(5*NumCel+i);

  if CaCO3(i)<0
      CaCO3(i)=0;
  end
  if IB(i)<0
      IB(i)=0;
  end
  if mg(i)<0
      mg(i)=1;
  end
  
  %pellet diameter
  d(i) = d0*(1+CaCO3(i)/mg(i)*rhog/rhos)^(1/3);

  %pellet density
  rhop(i)=(CaCO3(i)+mg(i))/(CaCO3(i)/rhos + mg(i)/rhog);

  % porosity
  pe(i)=functiep_RZ_K(30/3600,nu,rhow,rhop(i),Q/A(i),d(i),3);
  
  % bedheight
  dX(i) = (CaCO3(i)+mg(i))/(rhop(i)*(1-pe(i))*A(i));

  %specific surface
  S(i)=6*(1-pe(i))/(d(i));
  S(i)=S(i)/pe(i);

  %pressuredrop
  dP(i)=((1-pe(i))*dX(i))*(rhop(i)-rhow)/rhow;
  
  % eerste schatting met FactiefCo
  if (i==1)
    pH(i)=CE_MP_pH(Mgetal(i),Pgetal(i),K1,K2,Kw,Factiefco,9.0);
  else
    pH(i)=CE_MP_pH(Mgetal(i),Pgetal(i),K1,K2,Kw,Factiefco,pH(i-1));
  end

   CO3(i)=CE_pHM_CO3(pH(i),Mgetal(i),K1,K2,Kw,Factiefco);
  HCO3(i)=CE_pHM_HCO3(pH(i),Mgetal(i),K1,K2,Kw,Factiefco);
  
    Factief(i)=CE_Activity(IB(i)+HCO3(i)/2+2*CO3(i));

    % berekening Factief */
    pH(i)=CE_MP_pH(Mgetal(i),Pgetal(i),K1,K2,Kw,Factief(i),pH(i));

    CO3(i)=CE_pHM_CO3(pH(i),Mgetal(i),K1,K2,Kw,Factief(i));
    HCO3(i)=CE_pHM_HCO3(pH(i),Mgetal(i),K1,K2,Kw,Factief(i));

    % Oververzadiging
    Sa = (Ca(i)*CO3(i)-KS/(Factief(i)^8));

    %diffusie
  Reh = 2.0/3.0*Q/A(i)*d(i)/(1.0-pe(i))/nu;
  Sc = nu/Df;
  Sh = 0.66*(Reh^0.5)*(Sc^0.33);
  kf = Sh*Df/d(i);
    
  DF(i) = (KT*kf/(KT+kf))*S(i)*Sa;
    if (DF(i)<0)
	   DF(i)=0;
    end
h=h+dX(i);
end

% doorschuiven pellets */
Ntot=mg(1);
Nc(1)=mg(1);
for i=2:NumCel 
  Nc(i) = Nc(i-1)+mg(i);
  Ntot = Ntot+ mg(i);
end
for i=1:NumCel
  Nc(i) = Nc(i)/Ntot;
end
Nt(1) = NPellets;
for i=2:NumCel
  Nt(i) = (1-Nc(i-1))*NPellets + Nc(i-1)*NGrains;
end

% Einde algemene berekeningen */


  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

end; % of any(abs(flag)==[1 2 3])


if flag == 1, % Continuous states derivative calculation

%    DebugPr(pH)
  % default derivative =0;
  sys = zeros(B.CStates,1);
  
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the derivatives of the continuous states
  % eg. sys(1) = (u(u(U.Temperature)-x(1))/P.Volume;

% mengcompartiment */
sys(1)       = Q/(A(1)*pe(1)*dX(1))*(Ca0-Ca(1))         -   DF(1);
sys(NumCel+1)   = Q/(A(1)*pe(1)*dX(1))*(Mgetal0-Mgetal(1)) - 2.0*DF(1);
sys(2*NumCel+1) = Q/(A(1)*pe(1)*dX(1))*(Pgetal0-Pgetal(1)) -   DF(1);
sys(3*NumCel+1) = Q/(A(1)*pe(1)*dX(1))*(IB0-IB(1))         - 2.0*DF(1);
if (FB==0)
  sys(4*NumCel+1) = (DF(1)*A(1)*pe(1)*dX(1)*mCaCO3)/1000.0;                  % /1000 voor omzetten naar kg
  if Nt(1)>=0
    sys(4*NumCel+1) = sys(4*NumCel+1) - CaCO3(1)/mg(1)*Nt(1); 
  else
    sys(4*NumCel+1) = sys(4*NumCel+1) - CaCO3(1)/mg(1)*Nt(1); % toevoer van pellets met dezlefde diameter.
  end    
  if Nt(2)>=0
    sys(4*NumCel+1) = sys(4*NumCel+1) + CaCO3(2)/mg(2)*Nt(2);
  else
    sys(4*NumCel+1) = sys(4*NumCel+1) + CaCO3(1)/mg(1)*Nt(2); % verwijderen uit deze laag.
  end
  sys(5*NumCel+1) = Nt(2)-Nt(1);
else
  sys(4*NumCel+1) = 0;
  sys(5*NumCel+1) = 0;
end


% overige comparimenten */
for i=2:NumCel-1
    sys(i)          = Q/(A(i)*pe(i)*dX(i))*(Ca(i-1)-Ca(i))         -   DF(i);
    sys(NumCel+i)   = Q/(A(i)*pe(i)*dX(i))*(Mgetal(i-1)-Mgetal(i)) - 2*DF(i);
    sys(2*NumCel+i) = Q/(A(i)*pe(i)*dX(i))*(Pgetal(i-1)-Pgetal(i)) -   DF(i);
    sys(3*NumCel+i) = Q/(A(i)*pe(i)*dX(i))*(IB(i-1)-IB(i))         - 2*DF(i);
  if (FB==0)
    sys(4*NumCel+i) = (DF(i)*A(i)*pe(i)*dX(i)*mCaCO3)/1000.0;          % /1000 voor omzetten naar kg
    if Nt(i)>=0
       sys(4*NumCel+i) = sys(4*NumCel+i)- CaCO3(i)/mg(i)*Nt(i); 
     else
       sys(4*NumCel+i) = sys(4*NumCel+i)- CaCO3(i-1)/mg(i-1)*Nt(i); 
     end
    if Nt(i+1)>=0
      sys(4*NumCel+i) = sys(4*NumCel+i) + CaCO3(i+1)/mg(i+1)*Nt(i+1); 
    else
      sys(4*NumCel+i) = sys(4*NumCel+i) + CaCO3(i)/mg(i)*Nt(i+1); 
    end      
    sys(5*NumCel+i) = Nt(i+1)-Nt(i);
  else
    sys(4*NumCel+i) = 0;
    sys(5*NumCel+i) = 0;
  end
end

i = NumCel;
    sys(i)          = Q/(A(i)*pe(i)*dX(i))*(Ca(i-1)-Ca(i))         -   DF(i);
    sys(NumCel+i)   = Q/(A(i)*pe(i)*dX(i))*(Mgetal(i-1)-Mgetal(i)) - 2*DF(i);
    sys(2*NumCel+i) = Q/(A(i)*pe(i)*dX(i))*(Pgetal(i-1)-Pgetal(i)) -   DF(i);
    sys(3*NumCel+i) = Q/(A(i)*pe(i)*dX(i))*(IB(i-1)-IB(i))         - 2*DF(i);
  if (FB==0)
    sys(4*NumCel+i) = (DF(i)*A(i)*pe(i)*dX(i)*mCaCO3)/1000.0;          % /1000 voor omzetten naar kg
    if Nt(i)>=0
      sys(4*NumCel+i) = sys(4*NumCel+i)  - CaCO3(i)/mg(i)*Nt(i);
    else
      sys(4*NumCel+i) = sys(4*NumCel+i)  - CaCO3(i-1)/mg(i-1)*Nt(i);
    end
    if NGrains>=0
      % nothing geen kalk aanvoer op granaat
    else
      % afvoer bovenste laag, inclusief kalk.
      sys(4*NumCel+i) = sys(4*NumCel+i) + CaCO3(i)/mg(i)*NGrains; 
    end
    sys(5*NumCel+i) = NGrains - Nt(i);

  else
    sys(4*NumCel+i) = 0;
    sys(5*NumCel+i) = 0;
  end
    
 %  DebugPr([t Mgetal(1) Pgetal(1)  pH(1) Ca(1) CO3(1) d(1) rhop(1) pe(1) S(1) DF(1)])
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif flag ==2, %discrete state determination

  % default next sample same states (length is B.DStates)
  sys = x(B.CStates+1:B.CStates+B.DStates);
    
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the state value on the next samplemoment (determined by
  % B.SampleTime)
  % eg. sys(1) = (x(1)+u(u(U.Temperature))/P.Volume;
%% Stimela waterquality outputs */    

  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif flag ==3, % output data determination

  % default equal to the input with zeros for extra measurements
  sys = [u(1:U.Number); zeros(B.Measurements,1)];

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Determine output for calculated values
  % eg. sys(u(U.Temparature) = x(1);
sys(U.pH)=          pH(NumCel); % effluent pH */
sys(U.Calcium)=     Ca(NumCel)*mCa; % effluent calcium concentration (mg/l) */
sys(U.Bicarbonate)= HCO3(NumCel)*mHCO3; % effluent HCO3 concentration (mg/l) */
sys(U.Conductivity)=(IB(NumCel) + 2*CO3(NumCel) + HCO3(NumCel)/2 )/IoEc; % effluent electrical conductivity */
sys(U.Mnumber)= Mgetal(NumCel);
sys(U.Pnumber)= Pgetal(NumCel);


  % Determine extra measurements
  % eg. sys(u(U.Number+1) = x(1)/P.Opp;
% Additional outputs */
bedhoogte = 0;
deltaP = 0;
for i=1:NumCel
    deltaP=deltaP+dP(i);
    bedhoogte = bedhoogte + dX(i);
    if bedhoogte<0.75
      dP50 = deltaP/bedhoogte*0.5;
    end
    
    sys(U.Number+NumCel+i)=d(i)*1000.0;     % diameter van pellets over de hoogte in mm */
    sys(U.Number+2*NumCel+i)=pe(i);        
    sys(U.Number+3*NumCel+i)=dX(i);
    sys(U.Number+4*NumCel+i)=pH(i);
    sys(U.Number+5*NumCel+i)=dP(i);         % drukval */
    sys(U.Number+6*NumCel+i)=Q/A(i);         % watersnelheid */
end

% Important outputs */

sys(U.Number+1) = deltaP; % Total Pressure drop */
sys(U.Number+2) = bedhoogte; % Bedheight */
sys(U.Number+3) = d(1)*1000.0; % Released pellet diameter */
sys(U.Number+4) = log10(Ca(NumCel)*CO3(NumCel)/(KS/(Factief(NumCel)^8)));
sys(U.Number+5) = dP50

if any(~isreal(sys))
    disp(sys)
end

  
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif flag == 0
  % initialize Model
  % [cs,ds,out,in,,direct]
  sys = [B.CStates,B.DStates,U.Number+B.Measurements,U.Number+B.Setpoints, 0, B.Direct,1];
  ts = [B.SampleTime,0];
  str = 'pels25';
  x0=x0;
else
    % If flag is anything else, no need to return anything
    % since this is a continuous system
    sys = [];
end


function DebugPr(d)

    fid=fopen('pels25_s.log','at');
    for i=1:length(d)
        fprintf(fid,'\t%g',d(i));

    end
    fprintf(fid,'\n');
    fclose(fid);
 