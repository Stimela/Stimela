function [sys,x0,str,ts] = irofil_s(t,x,u,flag,B,x0,U,P),
%  [sys,x0,str,ts] = irofil_s(t,x,u,flag,B,x0,U,P),
%    Stimela S-Function
%
% t = time
% x = state vector, filled with conx(1:2*NumCel)tinuous states (flag 1) or
%                      discrete states (flag 2)
% u = input vector
%
% P =  proces parameters, filled with irofil_p.m and defined in irofil_d.m
% B =  Model size, filled with irofil_i.m,
% x0 = initial state, filled with irofil_i.m,
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
  Opp    = P.Surf;
  Diam   = P.Diam;
  nmax   = P.nmax;
  rhoD   = P.rhoD;
  rhoD   = rhoD*1000; % g/m3
  rhoK   = P.rhoK;
  FilPor0 = P.FilPor;
  Lwater = P.Lwater;
  Kf     = P.Kf;
  nf     = P.nf;
  M      = P.M;
  %LaShift= P.LaShift;
  dy     = P.dy;
  Lambda_Iron3  = P.Lambda_Iron3;
  Kfe = P.Kfe;
  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % optional: calculated values used for al flags
  % eg. TempArea = u(U.Temperature)/P.Area;
  Susp   = u(U.Suspended_solids);%mg/l
  Susp   = Susp/1000;%kg/m3
  Temp   = u(U.Temperature);
  Debiet = u(U.Flow);
  Iron2	 = u(U.Iron2);
  Iron3	 = u(U.Iron3);
  Oxygen = u(U.Oxygen);
  EGV	 = u(U.Conductivity);
  pH	 = u(U.pH);
  HCO3	 = u(U.Bicarbonate);
  %Hplus  = 10^(-pH);

  MatQ  = spdiags([[-1*ones(NumCel,1)],[1*ones(NumCel,1)]],[0,1],NumCel,NumCel+1);
  I = 0.165/1000*EGV;
  Fi = 10^(-((0.5*sqrt(I))/(1+sqrt(I))-0.2*I));
  K1= (1/Fi)*10^(-356.3094-0.06091964*(Temp+273.16)+21834.37/(Temp+273.16)+126.839*log10(Temp+273.16)-1684915/((Temp+273.16)^2));
  CO2 = 10^(-pH).*HCO3./K1*44/61; 
  
  vel          = Debiet/(Opp*3600); %oppervlakte filtratiesnelheid
  [lambda0,I0] = d_filcof(Temp,vel,Diam,FilPor0);

  spoelen = u(U.Number+1);

  % MatQ1        = d_filmat(dy,VelReal,vel,NumCel);       %Concentratie/accumulatie laag1
  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



end; % of any(abs(flag)==[1 2 3])


if flag == 1, % Continuous states derivative calculation

  % default derivative =0;
  sys = zeros(B.CStates,1);
  
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the derivatives of the continuous states
  % eg. sys(1) = (u(U.Temperature)-x(1))/P.Volume;

  FilPor(1:NumCel) = FilPor0 - (x(NumCel+1:2*NumCel)/rhoD);
  FilPor=FilPor';
  VelReal      = vel/FilPor;  %poriesnelheid
  
  if spoelen == 1
    % sys(1:NumCel)=-(1/90)*(x(1:NumCel)-Iron3);
    % sys(1+NumCel:2*NumCel)=-(1/90)*(x(1+NumCel:2*NumCel)-0); % loading op 0
    % sys(1+2*NumCel:3*NumCel)=-(1/90)*(x(1+2*NumCel:3*NumCel)-Iron2); % iron2 gelijk influent
    % sys(1+3*NumCel:4*NumCel)=-(1/90)*(x(1+3*NumCel:4*NumCel)-Oxygen); % Oxygen gelijk influent
    % sys(1+4*NumCel:5*NumCel)=-(1/90)*(x(1+4*NumCel:5*NumCel)-HCO3); % HCO3 gelijk influent
    % sys(1+5*NumCel:6*NumCel)=-(1/90)*(x(1+5*NumCel:6*NumCel)-CO2); % CO2 gelijk influent

    xspoel = ones(NumCel,1)*[x(NumCel) 0 x(3*NumCel) x(4*NumCel) x(5*NumCel) x(6*NumCel)];
    xspoel = xspoel(:);
    
    sys(1+0*NumCel:6*NumCel)=-(1/90)*(x(1+0*NumCel:6*NumCel)-xspoel);
%     disp(x(1:2*NumCel))
  else
    x(1+5*NumCel:6*NumCel);
     phint=-log10((x(1+5*NumCel:6*NumCel)/44)./(x(1+4*NumCel:5*NumCel)/61));
      pHcel=-log10(K1)+phint;%-log10((x(1+5*NumCel:6*NumCel)/44)./(x(1+4*NumCel:5*NumCel)/61))
    % sys(1:2*NumCel) = MatQ1*[Iron3;x(1:NumCel)] - VelReal*[lambda0*(1-abs(x(NumCel+1:2*NumCel)/(nmax*rhoD*FilPor)-LaShift));zeros(NumCel,1)].*x(1:2*NumCel);
    sys(1:NumCel) = -(vel./(FilPor*dy)).*(MatQ*[Iron3;x(1:NumCel)])+ Kfe*((x(2*NumCel+1:3*NumCel)/56).^2).*(x(3*NumCel+1:4*NumCel)/32).*((10.^(-pHcel)).^(-2))- (vel./(FilPor)).*([Lambda_Iron3*(1-abs(x(NumCel+1:2*NumCel)./(nmax*rhoD*FilPor0)))]).*x(1:NumCel);
    sys(1+NumCel:2*NumCel) = -vel*MatQ*[Iron3;x(1:NumCel)]/dy;
    sys(1+2*NumCel:3*NumCel) = -(vel./(FilPor*dy)).*(MatQ*[Iron2;x(2*NumCel+1:3*NumCel)])-Kfe*((x(2*NumCel+1:3*NumCel)/56).^2).*(x(3*NumCel+1:4*NumCel)/32).*((10.^(-pHcel)).^(-2))-((1+FilPor)./FilPor).*(rhoK*M).*(Kf*(sign(x(2*NumCel+1:3*NumCel)).*(abs(x(2*NumCel+1:3*NumCel))).^nf)-x(6*NumCel+1:7*NumCel));
    sys(1+3*NumCel:4*NumCel) = -(vel./(FilPor*dy)).*(MatQ*[Oxygen;x(3*NumCel+1:4*NumCel)])-(32/224)*Kfe*((x(2*NumCel+1:3*NumCel)/56).^2).*(x(3*NumCel+1:4*NumCel)/32).*((10.^(-pHcel)).^(-2));
    sys(1+4*NumCel:5*NumCel) = -(vel./(FilPor*dy)).*(MatQ*[HCO3;x(4*NumCel+1:5*NumCel)])-(8*61/224)*Kfe*((x(2*NumCel+1:3*NumCel)/56).^2).*(x(3*NumCel+1:4*NumCel)/32).*((10.^(-pHcel)).^(-2));
    sys(1+5*NumCel:6*NumCel) = -(vel./(FilPor*dy)).*(MatQ*[CO2;x(5*NumCel+1:6*NumCel)])+(8*44/224)*Kfe*((x(2*NumCel+1:3*NumCel)/56).^2).*(x(3*NumCel+1:4*NumCel)/32).*((10.^(-pHcel)).^(-2));
    sys(1+6*NumCel:7*NumCel) =  M*(Kf*(sign(x(2*NumCel+1:3*NumCel)).*(abs(x(2*NumCel+1:3*NumCel))).^nf)-x(6*NumCel+1:7*NumCel)); %-vel*MatQ*[Iron2;x(1:NumCel)]/dy;
    end


%sys(1:2*NumCel) = MatQ1*[coDOC;x(1:NumCel)] - (1+FilPor)/FilPor*(rhoK*M)*[K*(sign(x(1:NumCel)).*(abs(x(1:NumCel))).^n)-x(NumCel+1:2*NumCel);zeros(NumCel,1)];
    %sys(2*NumCel+1:3*NumCel)=(nX'|sys(2*NumCel+1:3*NumCel)>0).*sys(2*NumCel+1:3*NumCel);
    %sys(6*NumCel+1:7*NumCel)=(nX'|sys(6*NumCel+1:7*NumCel)>0).*sys(6*NumCel+1:7*NumCel);
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if any( (~isreal(sys)) | isnan(sys) | isinf(sys)) 
    disp('irofil has complex or nan values in flag=1')
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
  sys(U.Iron3)=x(NumCel); %Concentratie driewaardig ijzer [mg/l]  
  sys(U.Iron2)=x(3*NumCel); %Concentratie tweewaardig ijzer [mg/l]
  sys(U.Oxygen)=x(4*NumCel); %Concentratie zuurstof [mg/l]

  if spoelen == 1
    sys(U.Flow)=0;  
  end
  %sys(U.pH)=-log10(x(5*NumCel));


  % Determine extra measurements
  % eg. sys(U.Number+1) = x(1)/P.Opp;
  % sys(U.Number+1:U.Number+NumCel)= x(1:NumCel)*1000; %concentratie SS [mg/l]
  sys(U.Number+1:U.Number+NumCel)= x(1:NumCel); %concentratie Fe3 [mg/l]
  sys(U.Number+1+NumCel:U.Number+2*NumCel)=cumsum(dy-I0*dy*(FilPor0./(FilPor0-x(NumCel+1:2*NumCel)/rhoD)).^2); %weerstand tgv accumulatie laag1
  sys(U.Number+1+2*NumCel:U.Number+3*NumCel)= x(2*NumCel+1:3*NumCel); %concentratie Fe2 [mg/l]
  sys(U.Number+1+3*NumCel:U.Number+4*NumCel)= x(3*NumCel+1:4*NumCel); %concentratie O2 [mg/l]
  sys(U.Number+1+4*NumCel:U.Number+5*NumCel)= x(4*NumCel+1:5*NumCel); %concentratie HCO3 [mg/l]
  sys(U.Number+1+5*NumCel:U.Number+6*NumCel)= x(5*NumCel+1:6*NumCel); %concentratie CO2 [mg/l]
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif flag == 0
  % initialize Model
  % [cs,ds,out,in,,direct]
  sys = [B.CStates,B.DStates,U.Number+B.Measurements,U.Number+B.Setpoints, 0, B.Direct,1];
  ts = [B.SampleTime,0];
  str = 'irofil';
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




