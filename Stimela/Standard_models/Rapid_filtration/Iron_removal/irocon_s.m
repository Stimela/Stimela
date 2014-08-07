function [sys,x0,str,ts] = irocon_s(t,x,u,flag,B,x0,U,P),
%  [sys,x0,str,ts] = irocon_s(t,x,u,flag,B,x0,U,P),
%    Stimela S-Function
%
% t = time
% x = state vector, filled with conx(1:2*NumCel)tinuous states (flag 1) or
%                      discrete states (flag 2)
% u = input vector
%
% P =  proces parameters, filled with irocon_p.m and defined in irocon_d.m
% B =  Model size, filled with irocon_i.m,
% x0 = initial state, filled with irocon_i.m,
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
  NumCel = P.NumCel;
  LBed = u(U.Number+1);
  Opp    = P.Surf; % in m2
  dy0     = LBed/P.NumCel; % in m
  Kfe = P.Kfe;
  
%   Diam0   = P.Diam/1000; % in mm
%   nmax   = P.nmax/100;
%   rhoD   = P.rhoD; % density of iron III floc in kg/m3
%   rhoD   = rhoD*1000; % g/m3
%   rhoK   = P.rhoK*1000; % density of iron II cake in g/m3
%   FilPor0 = P.FilPor/100; 
%   Lwater = P.Lwater; % in m
%   Kf     = P.Kf;
%   nf     = P.nf;
%   M      = P.M;
%   Lambda_Iron3  = P.Lambda_Iron3;
  
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
  %Hplus  = 10^(-pH);
  TempK = Temp + 273.15;
  vel   = Debiet/(Opp*3600); %oppervlakte filtratiesnelheid
  
  MatQ  = spdiags([[-1*ones(NumCel,1)],[1*ones(NumCel,1)]],[0,1],NumCel,NumCel+1);
  IonStrength = 0.165*EGV;
  %I = 0.165/1000*EGV;
  f = CE_Activity(IonStrength);
  %Fi = 10^(-((0.5*sqrt(I))/(1+sqrt(I))-0.2*I));
  %K1= (1/Fi)*10^(-356.3094-0.06091964*(Temp+273.16)+21834.37/(Temp+273.16)+126.839*log10(Temp+273.16)-1684915/((Temp+273.16)^2));
  [K1,K2,Kw,Ks] = KValues(TempK);
  %CO2 = 10^(-pH).*HCO3./K1*44/61; 
  P=CE_pHHCO3_P(pH,HCO3,K1,K2,Kw,f);
  M=CE_pHHCO3_M(pH,HCO3,K1,K2,Kw,f);
  
   
%   NumGrain=(1-FilPor0)*Opp*dy0/(1/6*pi*Diam0^3);
%   Diam=(Diam0^3+(x(6*NumCel+1:7*NumCel)./rhoK)./(1/6*NumGrain*pi)).^(1/3);
%   dy=(NumGrain*1/6*pi*Diam.^3)./((1-FilPor0)*Opp);
%   nu=(497e-6)/((Temp+42.5)^1.5);
% 
%   I0=(180*nu*(1-FilPor0)^2*vel)./(9.81*FilPor0^3*Diam.^2);
  %lambda0=(9e-18)./(nu*vel*Diam.^3)%Lerk

%  [lambda0,I0] = d_filcof(Temp,vel,Diam,FilPor0);

  

end; % of any(abs(flag)==[1 2 3])


if flag == 1, % Continuous states derivative calculation

  % default derivative =0;
  sys = zeros(B.CStates,1);

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the derivatives of the continuous states
  % eg. sys(1) = (u(U.Temperature)-x(1))/P.Volume;

   % default derivative =0;
  sys = zeros(B.CStates,1);
  
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the derivatives of the continuous states
  % eg. sys(1) = (u(U.Temperature)-x(1))/P.Volume;

%   FilPor(1:NumCel) = FilPor0 - (x(NumCel+1:2*NumCel)/rhoD);
%   FilPor=FilPor';
  %VelReal      = vel/FilPor;  %poriesnelheid
  
  
    %phint=-log10((x(1+4*NumCel:5*NumCel)/44)./(x(1+3*NumCel:4*NumCel)/61));
    %pHcel=-log10(K1)+phint;
    pHcel=CE_MP_pH((x(1+3*NumCel:4*NumCel)),(x(1+4*NumCel:5*NumCel)),K1,K2,Kw,f,pH);
    Reac = Kfe*((x(NumCel+1:2*NumCel))).*(0.21*(x(2*NumCel+1:3*NumCel))/10).*((10.^-(14-pHcel)).^(2));
    
    sys(1:NumCel) = -(vel./dy0).*(MatQ*[Iron3;x(1:NumCel)])+ Reac;
    %sys(1+NumCel:2*NumCel) = (vel).*([Lambda_Iron3*(1-abs(x(NumCel+1:2*NumCel)./(nmax*rhoD*FilPor0)))]).*x(1:NumCel); % sludge accumulation (ironIII)
    sys(1+NumCel:2*NumCel) = -(vel./dy0).*(MatQ*[Iron2;x(NumCel+1:2*NumCel)])-Reac;
    sys(1+2*NumCel:3*NumCel) = -(vel./(dy0)).*(MatQ*[Oxygen;x(2*NumCel+1:3*NumCel)])-0.25*Reac;
    sys(1+3*NumCel:4*NumCel) = -(vel./(dy0)).*(MatQ*[M;x(3*NumCel+1:4*NumCel)])-2*Reac;
    sys(1+4*NumCel:5*NumCel) = -(vel./(dy0)).*(MatQ*[P;x(4*NumCel+1:5*NumCel)])-2*Reac;
    %sys(1+6*NumCel:7*NumCel) =  ((FilPor./(1-FilPor)).*M).*(x(2*NumCel+1:3*NumCel)-(x(6*NumCel+1:7*NumCel)./Kf).^(1/nf)); % ironII adsorption


%sys(1:2*NumCel) = MatQ1*[coDOC;x(1:NumCel)] - (1+FilPor)/FilPor*(rhoK*M)*[K*(sign(x(1:NumCel)).*(abs(x(1:NumCel))).^n)-x(NumCel+1:2*NumCel);zeros(NumCel,1)];
    %sys(2*NumCel+1:3*NumCel)=(nX'|sys(2*NumCel+1:3*NumCel)>0).*sys(2*NumCel+1:3*NumCel);
    %sys(6*NumCel+1:7*NumCel)=(nX'|sys(6*NumCel+1:7*NumCel)>0).*sys(6*NumCel+1:7*NumCel);
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if any( (~isreal(sys)) | isnan(sys) | isinf(sys)) 
    disp('irocon has complex or nan values in flag=1')
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
  sys(U.Iron3)=x(NumCel)*56; %Concentratie driewaardig ijzer [mg/l]  
  sys(U.Iron2)=x(2*NumCel)*56; %Concentratie tweewaardig ijzer [mg/l]
  sys(U.Oxygen)=x(3*NumCel)*32; %Concentratie zuurstof [mg/l]
  pHcel=CE_MP_pH((x(1+3*NumCel:4*NumCel)),(x(1+4*NumCel:5*NumCel)),K1,K2,Kw,f,pH);
  sys(U.pH)=pHcel(NumCel);
  sys(U.Bicarbonate)=CE_pHM_HCO3(pHcel(NumCel),x(4*NumCel),K1,K2,Kw,f)*61;
  %x(4*NumCel); % concentration HCO3 [mg/l]
  
  %phint=-log10((x(1+4*NumCel:5*NumCel)/44)./(x(1+3*NumCel:4*NumCel)/61));
  %pHcel=-log10(K1)+phint;
  

 
  % Determine extra measurements
  % eg. sys(U.Number+1) = x(1)/P.Opp;
  % sys(U.Number+1:U.Number+NumCel)= x(1:NumCel)*1000; %concentratie SS [mg/l]
  sys(U.Number+1:U.Number+NumCel)= x(1:NumCel)*56; %concentratie Fe3 [mg/l]
  %sys(U.Number+1+NumCel:U.Number+2*NumCel)=x(NumCel+1:2*NumCel); % sludge accumulation
  %sys(U.Number+1+NumCel:U.Number+2*NumCel)=cumsum(dy-I0.*dy.*(FilPor0./(FilPor0-x(NumCel+1:2*NumCel)/rhoD)).^2); %weerstand tgv accumulatie laag1
  sys(U.Number+1+NumCel:U.Number+2*NumCel)= x(NumCel+1:2*NumCel)*56; %concentratie Fe2 [mg/l]
  sys(U.Number+1+2*NumCel:U.Number+3*NumCel)= x(2*NumCel+1:3*NumCel)*32; %concentratie O2 [mg/l]
  sys(U.Number+1+3*NumCel:U.Number+4*NumCel)= x(3*NumCel+1:4*NumCel); %m-getal [mg/l]
  sys(U.Number+1+4*NumCel:U.Number+5*NumCel)= x(4*NumCel+1:5*NumCel); %p-getal [mg/l]
%   sys(U.Number+1+6*NumCel:U.Number+7*NumCel)=cumsum(dy-I0.*dy.*(FilPor0./(FilPor0-x(NumCel+1:2*NumCel)/rhoD)).^2); %weerstand tgv accumulatie laag1
%   sys(U.Number+1+7*NumCel:U.Number+8*NumCel)=Diam; %grain diameter per layer
%   sys(U.Number+1+8*NumCel:U.Number+9*NumCel)=dy; %layer thickness

  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif flag == 0
  % initialize Model
  % [cs,ds,out,in,,direct]
  sys = [B.CStates,B.DStates,U.Number+B.Measurements,U.Number+B.Setpoints, 0, B.Direct,1];
  ts = [B.SampleTime,0];
  str = 'irocon';
  x0=x0;
else
    % If flag is anything else, no need to return anything
    % since this is a continuous system
    sys = [];
end



function [lambda0F,I0F] = d_filcof(T,v,d,P0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function returns the factor coefficient
% for the filtration coefficient
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Kinematic viscosity
nu=(497e-6)/((T+42.5)^1.5);

% Factor coefficient for head loss
I0F=(180*nu*(1-P0)^2*v)/(9.81*P0^3*d^2);

lambda0F=(9e-18)/(nu*v*d^3);%Lerk


function val = d_filmat(dy,vp,v,N)

% This function returns the main matrix Q for filtration

b     = -vp/dy;
c     = vp/dy;
e     = v/dy;
alpha = -vp/dy;
beta  = vp/dy; 
v1=[[c*ones(N,1);beta], [b*ones(N,1);0]];
q1=spdiags(v1,[0,1],N,N+1);

v2=[[e*ones(N,1);2*e], [-e*ones(N,1);0]];
q2=spdiags(v2,[0,1],N,N+1);


val = [q1;q2];




