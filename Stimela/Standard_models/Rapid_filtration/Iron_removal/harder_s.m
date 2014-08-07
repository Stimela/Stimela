function [sys,x0,str,ts] = harder_s(t,x,u,flag,B,x0,U,P),
%  [sys,x0,str,ts] = harder_s(t,x,u,flag,B,x0,U,P),
%    Stimela S-Function
%
% t = time
% x = state vector, filled with conx(1:2*NumCel)tinuous states (flag 1) or
%                      discrete states (flag 2)
% u = input vector
%
% P =  proces parameters, filled with harder_p.m and defined in harder_d.m
% B =  Model size, filled with harder_i.m,
% x0 = initial state, filled with harder_i.m,
% U = Translationstructure for inout vector, filled in uit Blok00_i.m.
%     Fields are determined by 'st_Varia'
%
% Stimela, 2004
% References : Tamura, Sung

% © Kim van Schagen,

% General purpose calculations
if any(abs(flag)==[1 2 3])

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % optional: convert input vector to user names
  % eg. Temp = u(U.Temperature);
  % in the code it is also possible to use u(U.Temparature) directly.
  NumCel = P.NumCel;
  Opp    = P.Surf; % in m2
  Diam0   = P.Diam/1000; % in mm
  nmax   = P.nmax/100;
  rhoD   = P.rhoD*1000; % density of iron III floc in g/m3
  rhoK   = P.rhoK*1000; % density of iron II cake in g/m3
  FilPor0 = P.FilPor/100; 
  Lwater = P.Lwater; % in m
 
  dy0     = P.Lbed/P.NumCel; % in m

  Lambda_Iron3  = P.Lambda_Iron3;
  k0     = P.k0*100;
  Df     = P.Df*1000*1000;
  Kauto  = P.Kauto*1000*100;

  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % optional: calculated values used for al flags
  % eg. TempArea = u(U.Temperature)/P.Area;
  Temp   = u(U.Temperature); %in degrees celsius
  Debiet = u(U.Flow);% in m3/h
  Iron2	 = u(U.Iron2)/56; % in mmol/l
  Iron3	 = u(U.Iron3)/56; % in mmol/l
  Oxygen = u(U.Oxygen)/32; % in mmol/l
  EGV	 = u(U.Conductivity); %in mS/cm??
  pH	 = u(U.pH);
  HCO3	 = u(U.Bicarbonate)/61; %in mmol/l

  TempK = Temp + 273.15;
  vel          = Debiet/(Opp*3600); %oppervlakte filtratiesnelheid in m/s
  nu=(497e-6)/((Temp+42.5)^1.5);
  
  % transport
  MatQ  = spdiags([[-1*ones(NumCel,1)],[1*ones(NumCel,1)]],[0,1],NumCel,NumCel+1);

  % Calceq
  IonStrength = 0.183*EGV;
  f = CE_Activity(IonStrength);
  [K1,K2,Kw,Ks] = KValues(TempK);
  Pn=CE_pHHCO3_P(pH,HCO3,K1,K2,Kw,f);
  Mn=CE_pHHCO3_M(pH,HCO3,K1,K2,Kw,f);
  
  % volume zand materiaal
  Vg = (1-FilPor0)*Opp*dy0;
  VFe2 = x(6*NumCel+1:7*NumCel)*56/rhoK;
  Diam = Diam0.*(1+VFe2/Vg).^(1/3);
  dy = (Vg+VFe2)/((1-FilPor0)*Opp);
 
  spoelen = u(U.Number+1);

end; % of any(abs(flag)==[1 2 3])

  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if flag == 1, % Continuous states derivative calculation

  % default derivative =0;
  sys = zeros(B.CStates,1);
  
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the derivatives of the continuous states
  % eg. sys(1) = (u(U.Temperature)-x(1))/P.Volume;
  
  if spoelen == 1
    % alleen vlok uitspoelen.
    sys(1+NumCel:2*NumCel)=-(1/600/2)*(x(1+NumCel:2*NumCel)-0); % loading op 0
  else

    % translate x
    Fe3cel      = x(0*NumCel+1:1*NumCel);
    Fe3VlokFilt = x(1*NumCel+1:2*NumCel);
    Fe2cel      = x(2*NumCel+1:3*NumCel);
    O2cel       = x(3*NumCel+1:4*NumCel);
    Mcel        = x(4*NumCel+1:5*NumCel);
    Pcel        = x(5*NumCel+1:6*NumCel);
    Fe2Adcel    = x(6*NumCel+1:7*NumCel);

    % controle
    Fe3VlokFilt(Fe3VlokFilt<0)=0;
    
    % FilPor Neemt af.
    FilPor = FilPor0 - (Fe3VlokFilt./rhoD);
    FilPor(FilPor<nmax*FilPor0)=nmax*FilPor0;
    
    % determine pH-OH and H30    
    pHcel=CE_MP_pH(Mcel,Pcel,K1,K2,Kw,f,pH);
    OHcel=CE_pHM_OH(pHcel,Mcel,K1,K2,Kw,f);
    H3Ocel = 10.^(3-pHcel)./f;
    
    % R = k * Fe2 * O2 * OH^2
    % k0 = 2.3 10^14 M-3/s = 2.3 10^5 mmol-3/s
    Reac = k0.*O2cel.*OHcel.^2.*Fe2cel;
    
    %R =  * 
    %KT = kauto*O2/H*Fe2*FeAd\
    %Kauto = 56*10^-9.6
    KT = Kauto*O2cel./H3Ocel;%.*Fe2cel; %.*(Fe2Adcel+0.001);
    
    % Diffusion
    Reh = 2.0/3.0.*vel.*Diam./(1.0-FilPor)/nu;
    Sc = nu/Df;
    Sh = 0.66*(Reh.^0.5)*(Sc.^0.33);
    kf = Sh*Df./Diam;
    
    % combined
    Adsorption = KT.*kf./(KT+kf) .* Fe2cel;

    
    % catch vlok
    CatchVlok = ([Lambda_Iron3*(1-(Fe3VlokFilt./(nmax*rhoD*FilPor0)))]).*Fe3cel;
    CatchVlok(CatchVlok<0)=0;

    %% stoppen...
%    Reac = 0;
%    Adsorption=0;

   % CatchVlok = 0;

  
    % vlok
    sys(1:NumCel) = -(vel./(FilPor.*dy)).*(MatQ*[Iron3;Fe3cel])+ Reac - vel./FilPor.*CatchVlok;
    % gefilterde vlok
    sys(1+NumCel:2*NumCel) = (vel).*CatchVlok*56; % sludge accumulation mg/l (ironIII)
    % Fe2
    sys(1+2*NumCel:3*NumCel) = -(vel./(FilPor.*dy)).*(MatQ*[Iron2;Fe2cel])-Reac-Adsorption;
    %O2
    sys(1+3*NumCel:4*NumCel) = -(vel./(FilPor.*dy)).*(MatQ*[Oxygen;O2cel])-0.25*Reac;
    % M (-2 HCO3)
    sys(1+4*NumCel:5*NumCel) = -(vel./(FilPor.*dy)).*(MatQ*[Mn;Mcel])-2*Reac;
    % P (+ 2CO2)
    sys(1+5*NumCel:6*NumCel) = -(vel./(FilPor.*dy)).*(MatQ*[Pn;Pcel])-2*Reac;
    % geadsorbeerd ijzer Fe2 in mmol per laag?
    sys(1+6*NumCel:7*NumCel) =  FilPor.*Opp.*dy.*Adsorption; % ironII adsorption -> Fe2+ mmol
end

  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if any( (~isreal(sys)) | isnan(sys) | isinf(sys)) 
    disp('harder has complex or nan values in flag=1')
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
  % sys(U.Suspended_solids)=x(NumCel)*1000; %Concentratie zwevende stoffen [mg/l]
    Fe3cel      = x(0*NumCel+1:1*NumCel);
    Fe3VlokFilt = x(1*NumCel+1:2*NumCel);
    Fe2cel      = x(2*NumCel+1:3*NumCel);
    O2cel       = x(3*NumCel+1:4*NumCel);
    Mcel        = x(4*NumCel+1:5*NumCel);
    Pcel        = x(5*NumCel+1:6*NumCel);
    Fe2Adcel    = x(6*NumCel+1:7*NumCel);

  
  sys(U.Iron3)=Fe3cel(NumCel)*56; %Concentratie driewaardig ijzer [mg/l]  
  sys(U.Iron2)=Fe2cel(NumCel)*56; %Concentratie tweewaardig ijzer [mg/l]
  sys(U.Oxygen)=O2cel(NumCel)*32; %Concentratie zuurstof [mg/l]
  pHcel=CE_MP_pH(Mcel,Pcel,K1,K2,Kw,f,pH);
  sys(U.pH)=pHcel(NumCel);
  sys(U.Bicarbonate)=CE_pHM_HCO3(pHcel(NumCel),Mcel(NumCel),K1,K2,Kw,f)*61;
  sys(U.Mnumber)=Mcel(NumCel);
  sys(U.Pnumber)=Pcel(NumCel);
  
  if spoelen == 1
    sys(U.Flow)=0;  
  end

  % schoonbed weerstand
  I0=(180*nu*(1-FilPor0)^2*vel)./(9.81*FilPor0^3*Diam.^2);
  
  % Determine extra measurements
  % eg. sys(U.Number+1) = x(1)/P.Opp;
  % totale bed weerstand
  sys(U.Number+1)=sum(I0.*dy.*(FilPor0./(FilPor0-x(NumCel+1:2*NumCel)/rhoD)).^2); %weerstand tgv accumulatie laag1
  sys(U.Number+2)=sum(dy); %bed hoogte
   
  % sys(U.Number+1:U.Number+NumCel)= x(1:NumCel)*1000; %concentratie SS [mg/l]
  sys(U.Number+10+(1:NumCel))= x(1:NumCel)*56; %concentratie Fe3 [mg/l]
  sys(U.Number+10+NumCel+(1:NumCel))=x(NumCel+1:2*NumCel); % sludge accumulation
  sys(U.Number+10+2*NumCel+(1:NumCel))= x(2*NumCel+1:3*NumCel)*56; %concentratie Fe2 [mg/l]
  sys(U.Number+10+3*NumCel+(1:NumCel))= x(3*NumCel+1:4*NumCel)*32; %concentratie O2 [mg/l]
  sys(U.Number+10+4*NumCel+(1:NumCel))= x(4*NumCel+1:5*NumCel); %m-value (mmol/l)
  sys(U.Number+10+5*NumCel+(1:NumCel))= x(5*NumCel+1:6*NumCel); %p-value (mmol/l)
  sys(U.Number+10+6*NumCel+(1:NumCel))=cumsum(I0.*dy.*(FilPor0./(FilPor0-x(NumCel+1:2*NumCel)/rhoD)).^2); %weerstand tgv accumulatie laag1
  sys(U.Number+10+7*NumCel+(1:NumCel))=Diam; %grain diameter per layer
  sys(U.Number+10+8*NumCel+(1:NumCel))=dy; %layer thickness

  
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif flag == 0
  % initialize Model
  % [cs,ds,out,in,,direct]
  sys = [B.CStates,B.DStates,U.Number+B.Measurements,U.Number+B.Setpoints, 0, B.Direct,1];
  ts = [B.SampleTime,0];
  str = 'harder';
  x0=x0;
else
    % If flag is anything else, no need to return anything
    % since this is a continuous system
    sys = [];
end



