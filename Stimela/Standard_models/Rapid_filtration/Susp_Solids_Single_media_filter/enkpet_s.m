function [sys,x0,str,ts] = enkfil_s(t,x,u,flag,B,x0,U,P),
%  [sys,x0,str,ts] = enkfil_s(t,x,u,flag,B,x0,U,P),
%    Stimela S-Function
%
% t = time
% x = state vector, filled with continuous states (flag 1) or
%                      discrete states (flag 2)
% u = input vector
%
% P =  proces parameters, filled with enkfil_p.m and defined in enkfil_d.m
% B =  Model size, filled with enkfil_i.m,
% x0 = initial state, filled with enkfil_i.m,
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
  rhoDSS   = P.rhoDSS;
  rhoDAOC  = P.rhoDAOC;
  rhoDCa   = P.rhoDCa;
  FilPor = P.FilPor;
  FilPor0= FilPor;
  Lwater = P.Lwater;
   %LaShift= P.LaShift;
  dy     = P.dy;

  Lambda_SS  = P.Lambda_SS;
  Lambda_AOC = P.Lambda_AOC;
  Lambda_Ca  = P.Lambda_Ca;

  lengteNumCel = [1 NumCel];
  lengteNumCeli=1:NumCel;
  Diam=interp1(lengteNumCel,Diam,lengteNumCeli);
  
  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % optional: calculated values used for al flags
  % eg. TempArea = u(U.Temperature)/P.Area;
  Susp   = u(U.Suspended_solids);%mg/l
  Susp   = Susp/1000;%kg/m3
  Temp   = u(U.Temperature);
  Debiet = u(U.Flow);
  AOC = u(U.DOC)/1000; %kg/m3
  Ca    = u(U.Calcium); %kg/m3
  Ca    = Ca/1000;
%   rhoDAOC = rhoDAOC/1000; %kg/m3
  
  MatQ  = spdiags([[-1*ones(NumCel,1)],[1*ones(NumCel,1)]],[0,1],NumCel,NumCel+1);

%   Lambda_AOC   = 0.2904*exp(0.4478*Temp)
  vel          = Debiet/(Opp*3600); %oppervlakte filtratiesnelheid
  VelReal      = vel/FilPor;  %poriesnelheid
  [lambda0,I0] = d_filcof(Temp,vel,Diam,FilPor0); % Lambda0 wordt niet gebruikt
  MatQ1        = d_filmat(dy,VelReal,vel,NumCel);       %Concentratie/accumulatie laag1
  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

end; % of any(abs(flag)==[1 2 3])


if flag == 1, % Continuous states derivative calculation

  % default derivative =0;
  sys = zeros(B.CStates,1);
  
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the derivatives of the continuous states
  % eg. sys(1) = (u(U.Temperature)-x(1))/P.Volume;
  spoelen = u(U.Number+1);
  
  %%% modification Rene - Petra
  FilPor(1:NumCel) = FilPor0 - (x(NumCel+1:2*NumCel)/rhoDSS+ x(3*NumCel+1:4*NumCel)/rhoDAOC+ x(5*NumCel+1:6*NumCel)/rhoDCa);
  FilPor=FilPor';
%   anal = 0.001/rhoDAOC

  
  
  if spoelen == 1
     sys(1:2*NumCel)=-(1/90)*x(1:2*NumCel);
  else
    %sys(1:2*NumCel) = MatQ1*[Susp;x(1:NumCel)] - VelReal*[lambda0*(1-x(NumCel+1:2*NumCel)/(nmax*rhoD*FilPor));zeros(NumCel,1)].*x(1:2*NumCel);
    %sys(1:2*NumCel) = MatQ1*[Susp;x(1:NumCel)] - VelReal*[lambda0*(1-abs(x(NumCel+1:2*NumCel)/(nmax*rhoD*FilPor)-LaShift));zeros(NumCel,1)].*x(1:2*NumCel);
    %sys(1:2*NumCel) = MatQ1*[Susp;x(1:NumCel)] - VelReal*[Lambda_SS*(1-abs(x(NumCel+1:2*NumCel)./(nmax*rhoDSS*FilPor0)+x(3*NumCel+1:4*NumCel)./(nmax*rhoDAOC*FilPor0)+x(5*NumCel+1:6*NumCel)./(nmax*rhoDCa*FilPor0)));zeros(NumCel,1)].*x(1:2*NumCel);
    
%     a_vel=vel;
%     a_velreal=vel./(FilPor);
%     a_FilPor=FilPor;
%     a_Lambda_SS=Lambda_SS;
%     a_rhoDSS=rhoDSS;
%     a_FilPor0=FilPor0;
%     a_x=x(NumCel+1:2*NumCel);
%     a_SS=x(NumCel+1:2*NumCel)/rhoDSS;
%     a_SS2=x(NumCel+1:2*NumCel)./(nmax*rhoDSS*FilPor0);
%     a_AOCsig=x(3*NumCel+1:4*NumCel);
%     a_AOC=x(3*NumCel+1:4*NumCel)./(1/rhoDAOC);
%     a_AOC2=x(3*NumCel+1:4*NumCel)./(nmax*(1/rhoDAOC)*FilPor0);
%     a_AOC3=(1-abs(x(3*NumCel+1:4*NumCel)./(nmax*(1/rhoDAOC)*FilPor0)));
%     a_AOC4=([Lambda_SS*(1-abs(0./(nmax*rhoDSS*FilPor0)+x(3*NumCel+1:4*NumCel)./(nmax*(1/rhoDAOC)*FilPor0)+0./(nmax*rhoDCa*FilPor0)))]).*x(1:NumCel)
%     a_Ca=x(5*NumCel+1:6*NumCel)/rhoDCa;
%     a_Ca2=x(5*NumCel+1:6*NumCel)./(nmax*rhoDCa*FilPor0)
%     a_fil=a_SS + a_AOC + a_Ca
%     a_conc=x(1:NumCel)
%     a_vul=nmax*FilPor0
%     a_rhoAOC=(1/rhoDAOC)
%     a_tot=abs(x(NumCel+1:2*NumCel)./(nmax*rhoDSS*FilPor0)+x(3*NumCel+1:4*NumCel)./(nmax*(1/rhoDAOC)*FilPor0)+x(5*NumCel+1:6*NumCel)./(nmax*rhoDCa*FilPor0))
%     a_tot2=a_SS2+a_AOC2+a_Ca2
%     a_tot3=(1-abs(x(NumCel+1:2*NumCel)./(nmax*rhoDSS*FilPor0)+x(3*NumCel+1:4*NumCel)./(nmax*(1/rhoDAOC)*FilPor0)+x(5*NumCel+1:6*NumCel)./(nmax*rhoDCa*FilPor0)))
%     a_tot4=-(vel./(FilPor*dy)).*(MatQ*[Susp;x(1:NumCel)])
%     a_tot5=(MatQ*[Susp;x(1:NumCel)])
%     
%     aAOC = -(vel./(FilPor)).*([Lambda_SS*(1-abs(0./(nmax*rhoDSS*FilPor0)+x(3*NumCel+1:4*NumCel)./(nmax*(1/rhoDAOC)*FilPor0)+0./(nmax*rhoDCa*FilPor0)))]).*x(1:NumCel)
%     aSS = -(vel./(FilPor)).*([Lambda_SS*(1-abs(x(NumCel+1:2*NumCel)./(nmax*rhoDSS*FilPor0)+0./(nmax*(1/rhoDAOC)*FilPor0)+0./(nmax*rhoDCa*FilPor0)))]).*x(1:NumCel)
%      aCa = -(vel./(FilPor)).*([Lambda_SS*(1-abs(0./(nmax*rhoDSS*FilPor0)+0./(nmax*(1/rhoDAOC)*FilPor0)+x(5*NumCel+1:6*NumCel)./(nmax*rhoDCa*FilPor0)))]).*x(1:NumCel)
%     
%     atot = -(vel./(FilPor)).*([Lambda_SS*(1-abs(x(NumCel+1:2*NumCel)./(nmax*rhoDSS*FilPor0)+x(3*NumCel+1:4*NumCel)./(nmax*(1/rhoDAOC)*FilPor0)+x(5*NumCel+1:6*NumCel)./(nmax*rhoDCa*FilPor0)))]).*x(1:NumCel)
%     
%     a_totAOC=-(vel./(FilPor*dy)).*(MatQ*[Susp;x(2*NumCel+1:3*NumCel)])-(vel./(FilPor)).*([Lambda_AOC]).*x(2*NumCel +1:3*NumCel)
%     a_totCa= -(vel./(FilPor*dy)).*(MatQ*[Susp;x(1+4*NumCel:5*NumCel)])-(vel./(FilPor)).*([Lambda_Ca*(1-abs(x(NumCel+1:2*NumCel)./(nmax*rhoDSS*FilPor0)+x(3*NumCel+1:4*NumCel)./(nmax*(1/rhoDAOC)*FilPor0)+x(5*NumCel+1:6*NumCel)./(nmax*rhoDCa*FilPor0)))]).*x(4*NumCel +1:5*NumCel)
%     a_totSS=-(vel./(FilPor*dy)).*(MatQ*[Susp;x(1:NumCel)])-(vel./(FilPor)).*([Lambda_SS*(1-abs(x(NumCel+1:2*NumCel)./(nmax*rhoDSS*FilPor0)+x(3*NumCel+1:4*NumCel)./(nmax*(1/rhoDAOC)*FilPor0)+x(5*NumCel+1:6*NumCel)./(nmax*rhoDCa*FilPor0)))]).*x(1:NumCel)
    
    sys(1:NumCel) = -(vel./(FilPor*dy)).*(MatQ*[Susp;x(1:NumCel)]) - (vel./(FilPor)).*([Lambda_SS*(1-abs(x(NumCel+1:2*NumCel)./(nmax*rhoDSS*FilPor0)+x(3*NumCel+1:4*NumCel)./(nmax*(0.001/rhoDAOC)*FilPor0)+x(5*NumCel+1:6*NumCel)./(nmax*rhoDCa*FilPor0)))]).*x(1:NumCel);
    sys(1+NumCel:2*NumCel) = -vel*MatQ*[Susp;x(1:NumCel)]/dy;
    %sys(1+2*NumCel:3*NumCel) = -(vel./(FilPor*dy)).*(MatQ*[AOC;x(2*NumCel+1:3*NumCel)])-(vel./(FilPor)).*([Lambda_AOC*(1-abs(x(3*NumCel+1:4*NumCel)./(nmax*(0.001/rhoDAOC)*FilPor0)))]).*x(2*NumCel +1:3*NumCel);
    sys(1+2*NumCel:3*NumCel) = -(vel./(FilPor*dy)).*(MatQ*[AOC;x(2*NumCel+1:3*NumCel)])-(vel./(FilPor)).*([Lambda_AOC.*(1-abs(x(3*NumCel+1:4*NumCel)./(nmax*rhoDAOC*FilPor0)+x(5*NumCel+1:6*NumCel)./(nmax*rhoDCa*FilPor0)))]).*x(2*NumCel +1:3*NumCel);
    %sys(1+2*NumCel:3*NumCel) = -(vel./(FilPor*dy)).*(MatQ*[AOC;x(2*NumCel+1:3*NumCel)])-(vel./(FilPor)).*([Lambda_AOC]).*x(2*NumCel +1:3*NumCel);
    sys(1+3*NumCel:4*NumCel) = -vel*MatQ*[AOC;x(2*NumCel+1:3*NumCel)]/dy;
    %sys(2*NumCel+1:4*NumCel) = MatQ1*[AOC;x(2*NumCel+1:3*NumCel)] - VelReal*[Lambda_AOC*(1-abs(x(3*NumCel+1:4*NumCel)./(nmax*rhoDAOC*FilPor0)));zeros(NumCel,1)].*x(2*NumCel+1:4*NumCel);
    sys(1+4*NumCel:5*NumCel) = -(vel./(FilPor*dy)).*(MatQ*[Ca;x(1+4*NumCel:5*NumCel)])-(vel./(FilPor)).*([Lambda_Ca*(1-abs(x(NumCel+1:2*NumCel)./(nmax*rhoDSS*FilPor0)+x(3*NumCel+1:4*NumCel)./(nmax*rhoDAOC*FilPor0)+x(5*NumCel+1:6*NumCel)./(nmax*rhoDCa*FilPor0)))]).*x(4*NumCel +1:5*NumCel);
    sys(1+5*NumCel:6*NumCel) = -vel*MatQ*[Ca;x(4*NumCel+1:5*NumCel)]/dy;
    %sys(4*NumCel+1:6*NumCel) = MatQ1*[Ca;x(4*NumCel+1:5*NumCel)] - VelReal*[Lambda_Ca*(1-abs(x(5*NumCel+1:6*NumCel)./(nmax*rhoDCa*FilPor0)));zeros(NumCel,1)].*x(4*NumCel+1:6*NumCel);

end;
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
  sys(U.Suspended_solids)=x(NumCel)*1000; %Concentratie zwevende stoffen [mg/l]
  sys(U.DOC)=x(3*NumCel)*1000; %concentratie AOC [mg/l]
  sys(U.Calcium)=x(5*NumCel)*1000; %concentratie Calcium [mg/l]
  
%   test=dy*(FilPor0./(FilPor0-(x(NumCel+1:2*NumCel)/rhoDSS+x(3*NumCel+1:4*NumCel)/(1/rhoDAOC)+x(5*NumCel+1:6*NumCel)/rhoDCa))).^2
  
  % Determine extra measurements
  % eg. sys(U.Number+1) = x(1)/P.Opp;
  sys(U.Number+1:U.Number+NumCel)= x(1:NumCel)*1000; %concentratie SS [mg/l]
  sys(U.Number+1+NumCel:U.Number+2*NumCel)=cumsum(dy-I0*dy.*(FilPor0./(FilPor0-(x(NumCel+1:2*NumCel)/rhoDSS+x(3*NumCel+1:4*NumCel)/rhoDAOC+x(5*NumCel+1:6*NumCel)/rhoDCa))).^2); %weerstand tgv accumulatie laag1 %%% per laag de (gecumuleerde) absolute druk t.o.v. bovenkant filter (en niet drukval)
  sys(U.Number+2*NumCel+1:U.Number+3*NumCel)= x(NumCel+1:2*NumCel)*1000; %sigma SS 
  sys(U.Number+3*NumCel+1:U.Number+4*NumCel)= x(2*NumCel+1:3*NumCel)*1000; %concentratie AOC [mg/l]
  sys(U.Number+4*NumCel+1:U.Number+5*NumCel)= x(3*NumCel+1:4*NumCel)*1000; %sigma AOC [mg/l]
  sys(U.Number+5*NumCel+1:U.Number+6*NumCel)= x(4*NumCel+1:5*NumCel)*1000; %concentratie Ca [mg/l]
  sys(U.Number+6*NumCel+1:U.Number+7*NumCel)= x(5*NumCel+1:6*NumCel)*1000; %sigma Ca [mg/l]
%   controle=I0
%   diam=Diam
% sigma=x(3*NumCel+1:4*NumCel)
% verstop=x(3*NumCel+1:4*NumCel)/(1/rhoDAOC)
% ein=cumsum(dy-I0*dy.*(FilPor0./(FilPor0-(x(NumCel+1:2*NumCel)/rhoDSS+x(3*NumCel+1:4*NumCel)/(1/rhoDAOC)+x(5*NumCel+1:6*NumCel)/rhoDCa))).^2)
% verstopp=(FilPor0./(FilPor0-(x(NumCel+1:2*NumCel)/rhoDSS+x(3*NumCel+1:4*NumCel)/(1/rhoDAOC)+x(5*NumCel+1:6*NumCel)/rhoDCa))).^2
% tot=dy-I0*dy.*verstopp
  
%   rij1=x(3*NumCel+1:4*NumCel)/(1/rhoDAOC)
%   rij2=FilPor0-rij1
%   rij3=FilPor0./rij2
 
  %test2=I0*dy*(FilPor0./(FilPor0-(x(NumCel+1:2*NumCel)/rhoDSS+x(3*NumCel+1:4*NumCel)/(1/rhoDAOC)+x(5*NumCel+1:6*NumCel)/rhoDCa))).^2;
  %test3=I0.*test
%   tl=dy-I0.*dy*(FilPor0./(FilPor0-(x(NumCel+1:2*NumCel)/rhoDSS+x(3*NumCel+1:4*NumCel)/(1/rhoDAOC)+x(5*NumCel+1:6*NumCel)/rhoDCa))).^2
     
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif flag == 0
  % initialize Model
  % [cs,ds,out,in,,direct]
  sys = [B.CStates,B.DStates,U.Number+B.Measurements,U.Number+B.Setpoints, 0, B.Direct,1];
  ts = [B.SampleTime,0];
  str = 'enkfil';
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
I0F=(180*nu*(1-P0)^2*v)./(9.81*P0^3*d.^2);
I0F=I0F';

lambda0F=(9e-18)./(nu*v*d.^3);%Lerk


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




