function [sys,x0,str,ts] = nitfil_s(t,x,u,flag,B,x0,U,P),
%  [sys,x0,str,ts] = nitfil_s(t,x,u,flag,B,x0,U,P),
%    Stimela S-Function
%
% t = time
% x = state vector, filled with continuous states (flag 1) or
%                      discrete states (flag 2)
% u = input vector
%
% P =  proces parameters, filled with nitfil_p.m and defined in nitfil_d.m
% B =  Model size, filled with nitfil_i.m,
% x0 = initial state, filled with nitfil_i.m,
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
  NumCel=P.NumCel;
  %Lwater=Pr2(1);
  %nmax = Pr2(2);
  %rhoD = Pr2(3);
  MuMax15_Ns=P.MuMax15_Ns;
  MuMax15_Nb=P.MuMax15_Nb;
  AlfaT_Ns=P.AlfaT_Ns;
  AlfaT_Nb=P.AlfaT_Nb;
  KsPO4_Ns=P.KsPO4_Ns;
  KsPO4_Nb=P.KsPO4_Nb;
  KsO2_Ns=P.KsO2_Ns;
  KsO2_Nb=P.KsO2_Nb;
  Y_Ns=P.Y_Ns;
  Y_Nb=P.Y_Nb;
  %knh4=Pr5(3);
  %kno2=Pr5(4);
  B_Ns=P.B_Ns;
  B_Nb=P.B_Nb;
  D1_Ns=P.D1_Ns;
  D1_Nb=P.D1_Nb;
  D2_Ns=P.D2_Ns;
  D2_Nb=P.D2_Nb;
  Opp=P.Surf;
  dy=P.dy;
  Diam=P.Diam;
  FilPor=P.FilPor;
  Fi=P.Fi;

  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % optional: calculated values used for al flags
  % eg. TempArea = u(U.Temperature)/P.Area;
  q=0.0000001;
  %MuMax15_Ns=5e-5;
  %MuMax15_Nb=9e-6;
  
  Susp   = u(U.Suspended_solids);%mg/l
  Susp   = Susp/1000;%kg/m3
  Temp   = u(U.Temperature);
  Debiet = u(U.Flow);
  CO2    = u(U.Carbon_dioxide);
  HCO3   = u(U.Bicarbonate);
  NH4    = u(U.Ammonia);
  NO2    = u(U.Nitrite);
  O2     = u(U.Oxygen);
  PO4    = u(U.Phosphate);
  
  vel          = Debiet/(Opp*3600); %oppervlakte filtratiesnelheid
  VelReal      = vel/FilPor;  %poriesnelheid
  [lambda0,I0] = d_filcof(Temp,vel,Diam,FilPor);
  MatQ1        = d_filmat(dy,VelReal,vel,NumCel);       %Concentratie/accumulatie laag1
  
  %vel          = Debiet/(Opp*3600); %oppervlakte filtratiesnelheid
  %VelReal      = vel/Por;  %poriesnelheid
  MatQ        = d_filmat1(dy,VelReal,NumCel);  
  
  nu = ((497e-6)/((Temp+42.5)^1.5));
  Do2= 1/(9.048299e-1 - 1.961736e-2*Temp + 1.076824e-4*Temp^2)*1e-9; %zie afstudeerrapport alex
  Sc=nu/Do2;
  kf=(2+1.1*(Diam*vel/nu)^0.6*Sc^0.33)*Do2/Diam; %zie rapport david visscher
  ko2=6/Diam*(1-FilPor)*kf;
  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

end; % of any(abs(flag)==[1 2 3])


if flag == 1, % Continuous states derivative calculation

  % default derivative =0;
  sys = zeros(B.CStates,1);
  
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the derivatives of the continuous states
  % eg. sys(1) = (u(U.Temperature)-x(1))/P.Volume;
  KsNH4_Ns=0.405*exp(0.118*(Temp-15));
  KsNO2_Nb=0.405*exp(0.146*(Temp-15));
  
  K1= (1/Fi)*10^(-356.3094-0.06091964*(Temp+273.16)+21834.37/(Temp+273.16)+126.839*log10(Temp+273.16)-1684915/((Temp+273.16)^2));
  nu = ((497e-6)/((Temp+42.5)^1.5));
  
  nh4=x(1:NumCel)+q;
  nh4s=x(NumCel+1:2*NumCel)+q;
  no2=x(2*NumCel+1:3*NumCel)+q;
  no2s=x(3*NumCel+1:4*NumCel)+q;
  xns=x(4*NumCel+1:5*NumCel)+q;
  xnb=x(5*NumCel+1:6*NumCel)+q;
  o2=x(6*NumCel+1:7*NumCel);
  o2s=x(7*NumCel+1:8*NumCel);
  co2=x(8*NumCel+1:9*NumCel);
  co2s=x(9*NumCel+1:10*NumCel);
  hco3=x(10*NumCel+1:11*NumCel);
  hco3s=x(11*NumCel+1:12*NumCel);
  po4=x(12*NumCel+1:13*NumCel);
  po4s=x(13*NumCel+1:14*NumCel);

  pH = - log10(K1.*((co2s/44000)./(hco3s/61000)));
  AlfapH_Ns=1./(1+0.041*10.^abs(8.4-pH));
  AlfapH_Nb=1./(1+0.041*10.^abs(8.8-pH));
  Monod_nh4_Ns=nh4s./(nh4s+KsNH4_Ns);
  Monod_o2_Ns=o2s./(o2s+KsO2_Ns);
  Monod_po4_Ns=po4s./(po4s+KsPO4_Ns);
  Monod_no2_Nb=no2s./(no2s+KsNO2_Nb);
  Monod_o2_Nb=o2s./(o2s+KsO2_Nb);
  Monod_po4_Nb=po4s./(po4s+KsPO4_Nb);
  muNs=exp(log(AlfaT_Ns)*(Temp-15)).*AlfapH_Ns*MuMax15_Ns.*min(min(Monod_nh4_Ns,Monod_o2_Ns),Monod_po4_Ns);
  %Y_Ns=(8*(274.75/6))./(3500+5.7*exp(-69400/8.314*(1/(Temp+273)-1/298))./(muNs*3600)+4.2*(274.75/6));
  muNb=exp(log(AlfaT_Nb)*(Temp-15)).*AlfapH_Nb*MuMax15_Nb.*min(min(Monod_no2_Nb,Monod_o2_Nb),Monod_po4_Nb);
  %Y_Nb=(2*(74.14/2))./(3500+5.7*exp(-69400/8.314*(1/(Temp+273)-1/298))./(muNb*3600)+4.2*(74.14/2));

  ds=0.0001;

  sys(1:NumCel)= MatQ*[NH4;nh4]-ko2*(nh4-nh4s);
  %sys(NumCel+1:2*NumCel)= -MatQ*[NH4;nh4]-muNs.*xns./Y_Ns;
  sys(NumCel+1:2*NumCel)= (ko2*(nh4-nh4s)-muNs.*xns./Y_Ns)/(ds*6*(1-FilPor)/Diam);
  sys(2*NumCel+1:3*NumCel)= MatQ*[NO2;no2]-ko2*(no2-no2s);
  sys(3*NumCel+1:4*NumCel)= (ko2*(no2-no2s)-muNb.*xnb./Y_Nb+muNs.*xns./Y_Ns)/(ds*6*(1-FilPor)/Diam);
  %sys(3*NumCel+1:4*NumCel)= -MatQ*[NO2;no2]-muNb.*xnb./Y_Nb+muNs.*xns./Y_Ns;
  sys(4*NumCel+1:5*NumCel)=((1-D1_Ns)*muNs-B_Ns-D2_Ns).*xns;
  sys(5*NumCel+1:6*NumCel)=((1-D1_Nb)*muNb-B_Nb-D2_Nb).*xnb;
  sys(6*NumCel+1:7*NumCel)= MatQ*[O2;o2]-ko2*(o2-o2s);
  sys(7*NumCel+1:8*NumCel)= (ko2*(o2-o2s)-muNs.*xns./Y_Ns*(1.5*32/14)-muNb.*xnb./Y_Nb*(0.5*32/14))/(ds*6*(1-FilPor)/Diam);
  sys(8*NumCel+1:9*NumCel)= MatQ*[CO2;co2]-ko2*(co2-co2s);
  sys(9*NumCel+1:10*NumCel)= (ko2*(co2-co2s)+muNs.*xns./Y_Ns*(2*44/14))/(ds*6*(1-FilPor)/Diam);
  sys(10*NumCel+1:11*NumCel)= MatQ*[HCO3;hco3]-ko2*(hco3-hco3s);
  sys(11*NumCel+1:12*NumCel)= (ko2*(hco3-hco3s)-muNs.*xns./Y_Ns*(2*61/14))/(ds*6*(1-FilPor)/Diam);
  sys(12*NumCel+1:13*NumCel)= MatQ*[PO4;po4]-ko2*(po4-po4s);
  sys(13*NumCel+1:14*NumCel)= (ko2*(po4-po4s)-muNs.*xns/39.1-muNb.*xnb/39.1)/(ds*6*(1-FilPor)/Diam);


  
  
%  spoelen = u(Uv(1)+1);
  
%  if spoelen == 1
%     sys(1:2*NumCel)=-(1/90)*x(1:2*NumCel);
%  else
%    sys(1:2*NumCel) = MatQ1*[Susp;x(1:NumCel)] - VelReal*[lambda0*(1-x(NumCel+1:2*NumCel)/(nmax*rhoD*FilPor));zeros(NumCel,1)].*x(1:2*NumCel);
%  end;

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
  sys(U.Carbon_dioxide) = x(9*NumCel);
  sys(U.Bicarbonate) = x(11*NumCel);
  sys(U.Ammonia) = x(NumCel);
  sys(U.Nitrite) = x(3*NumCel);
  sys(U.Oxygen) = x(7*NumCel);
  sys(U.Phosphate) = x(13*NumCel);

  % Determine extra measurements
  % eg. sys(U.Number+1) = x(1)/P.Opp;
  sys(U.Number+1:U.Number+14*NumCel) = x(1:14*NumCel);
  %sys(Uv(2))=x(NumCel)*1000; %Concentratie zwevende stoffen [mg/l]
  % sys(Uv(1)+1:Uv(1)+NumCel)= x(1:NumCel)*1000; %concentratie SS [mg/l]
  % sys(Uv(1)+1+NumCel:Uv(1)+2*NumCel)=cumsum(dy-I0*dy*(FilPor./(FilPor-x(NumCel+1:2*NumCel)/rhoD)).^2); %weerstand tgv accumulatie laag1
  
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif flag == 0
  % initialize Model
  % [cs,ds,out,in,,direct]
  sys = [B.CStates,B.DStates,U.Number+B.Measurements,U.Number+B.Setpoints, 0, B.Direct,1];
  ts = [B.SampleTime,0];
  str = 'nitfil';
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


%b     = -vp/(2*dy);
%c     = vp/(2*dy);
%e     = v/(2*dy);
%alpha = -vp/dy;
%beta  = vp/dy; 
%v1=[[c*ones(N-1,1);beta], [zeros(N-1,1);alpha], [b*ones(N-1,1);0]];
%q1=spdiags(v1,[0,1,2],N,N+1);
%
%v2=[[e*ones(N-1,1);2*e], [zeros(N-1,1);-2*e], [-e*ones(N-1,1);0]];
%q2=spdiags(v2,[0,1,2],N,N+1);
%
%
%val = [q1;q2];


b     = -vp/(2*dy);
c     = vp/(2*dy);
e     = v/(2*dy);
alpha = -vp/dy;
beta  = vp/dy; 
v1=[[c*ones(N,1);beta], [b*ones(N,1);0]];
q1=spdiags(v1,[0,1],N,N+1);

v2=[[e*ones(N,1);2*e], [-e*ones(N,1);0]];
q2=spdiags(v2,[0,1],N,N+1);


val = [q1;q2];


function val = d_filmat1(dy,vp,N)
a1     = vp/(dy);
a2    = -vp/(dy);
%b     = v/(dy);
alpha = -vp/dy;
beta  = vp/dy;
v1=[[a1*ones(N-1,1);beta], [a2*ones(N-1,1);alpha]];
q1=spdiags(v1,[0,1],N,N+1);
%v2=[b*ones(N,1), -b*ones(N,1)];
%q2=spdiags(v2,[0,1],N,N+1);
val = [q1];




