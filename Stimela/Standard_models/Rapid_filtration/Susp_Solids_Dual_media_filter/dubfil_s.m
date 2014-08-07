function [sys,x0,str,ts] = dubfil_s(t,x,u,flag,B,x0,U,P),
%  [sys,x0,str,ts] = dubfil_s(t,x,u,flag,B,x0,U,P),
%    Stimela S-Function
%
% t = time
% x = state vector, filled with continuous states (flag 1) or
%                      discrete states (flag 2)
% u = input vector
%
% P =  proces parameters, filled with dubfil_p.m and defined in dubfil_d.m
% B =  Model size, filled with dubfil_i.m,
% x0 = initial state, filled with dubfil_i.m,
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
NumCel1=P.NumCel1;
NumCel2=P.NumCel2;  
Opp=P.Surf;
Diam1=P.Diam1;
Diam2=P.Diam2;
n1=P.n1;
n2=P.n2;
rhoD=P.rhoD;
FilPor1=P.FilPor1;
FilPor2=P.FilPor2;
Lambda01=P.Lambda01;
Lambda02=P.Lambda02;

Ls=P.Ls;
dy1=P.dy1;
dy2=P.dy2;

k1=1/n1;
k2=1/n2;

  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % optional: calculated values used for al flags
  % eg. TempArea = u(U.Temperature)/P.Area;
  Susp=u(U.Suspended_solids);%mg/l
  Susp=Susp/1000; %kg/m3
  Temp=u(U.Temperature);
  Debiet=u(U.Flow);

  vel=Debiet/(Opp*3600); %oppervlakte filtratiesnelheid
  VelReal1=vel/FilPor1;  %poriesnelheid
  VelReal2=vel/FilPor2;  %poriesnelheid
  [LambdaCalc01,I01] = d_filcof(Temp,vel,Diam1,FilPor1);
  [LambdaCalc02,I02] = d_filcof(Temp,vel,Diam2,FilPor2);
  MatQ1 = Matrix(1,NumCel1);
  MatQ2 = Matrix(1,NumCel2);
  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

end; % of any(abs(flag)==[1 2 3])


if flag == 1, % Continuous states derivative calculation

  % default derivative =0;
  sys = zeros(B.CStates,1);
  
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the derivatives of the continuous states
  % eg. sys(1) = (u(U.Temperature)-x(1))/P.Volume;
  
  spoelen = u(U.Number+1);
  
  if spoelen == 1
     sys(1:2*(NumCel1+NumCel2))=-(1/90)*x(1:2*(NumCel1+NumCel2));
  else
     sys(1:NumCel1) = ((vel./(FilPor1-x(NumCel1+1:2*NumCel1)/rhoD))./dy1).*(MatQ1*[Susp;x(1:NumCel1)]) - ((Lambda01*(1+(x(NumCel1+1:2*NumCel1)/(k1*rhoD))-((x(NumCel1+1:2*NumCel1)/rhoD).^2)./(k2*(FilPor1-x(NumCel1+1:2*NumCel1)./rhoD))))).*x(1:NumCel1);
     sys(NumCel1+1:2*NumCel1) = (vel/dy1)*MatQ1*[Susp;x(1:NumCel1)];
     sys(2*NumCel1+1:2*NumCel1+NumCel2) = ((vel./(FilPor2-x(2*NumCel1+NumCel2+1:2*NumCel1+2*NumCel2)/rhoD))./dy2).*(MatQ2*[x(NumCel1);x(2*NumCel1+1:2*NumCel1+NumCel2)]) - ((Lambda02*(1+(x(2*NumCel1+NumCel2+1:2*NumCel1+2*NumCel2)/(k1*rhoD))-((x(2*NumCel1+NumCel2+1:2*NumCel1+2*NumCel2)/rhoD).^2)./(k2*(FilPor2-x(2*NumCel1+NumCel2+1:2*NumCel1+2*NumCel2)./rhoD))))).*x(2*NumCel1+1:2*NumCel1+NumCel2);
     sys(2*NumCel1+NumCel2+1:2*NumCel1+2*NumCel2) = (vel/dy2)*MatQ2*[x(NumCel1);x(2*NumCel1+1:2*NumCel1+NumCel2)];
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
  sys(U.Suspended_solids)=x(2*NumCel1+NumCel2)*1000; %Concentratie zwevende stoffen
  % Determine extra measurements
  % eg. sys(U.Number+1) = x(1)/P.Opp;
  sys(U.Number+1:U.Number+NumCel1)= x(1:NumCel1)*1000; %concentratie SS laag 1 [g/m3]
  sys(U.Number+1+NumCel1:U.Number+NumCel1+NumCel2)=x(2*NumCel1+1:2*NumCel1+NumCel2)*1000; %concentratie SS laag 2 [g/m3] 
  sys(U.Number+1+NumCel1+NumCel2:U.Number+2*NumCel1+NumCel2)=cumsum(dy1-I01*dy1*(FilPor1./(FilPor1-x(NumCel1+1:2*NumCel1)/rhoD)).^2); %weerstand tgv accumulatie laag1
  sys(U.Number+1+2*NumCel1+NumCel2:U.Number+2*(NumCel1+NumCel2))= sys(U.Number+2*NumCel1+NumCel2)+cumsum(dy2-I02*dy2*(FilPor2./(FilPor2-x(2*NumCel1+NumCel2+1:2*(NumCel1+NumCel2))/rhoD)).^2); %weerstand tgv accumulatie laag2
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif flag == 0
  % initialize Model
  % [cs,ds,out,in,,direct]
  sys = [B.CStates,B.DStates,U.Number+B.Measurements,U.Number+B.Setpoints, 0, B.Direct,1];
  ts = [B.SampleTime,0];
  str = 'dubfil';
  x0=x0;
else
    % If flag is anything else, no need to return anything
    % since this is a continuous system
    sys = [];
end





function [Lambda0,I0] = d_filcof(T,v,d,P0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function returns the factor coefficient
% for the filtration coefficient
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Kinematic viscosity
nu=(497e-6)/((T+42.5)^1.5);

% Factor coefficient for head loss
I0=(180*nu*(1-P0)^2*v)/(9.81*P0^3*d^2);

Lambda0=(9e-18)/(nu*v*d^3);%Lerk


function val = Matrix(T,N)
a     = 1./T;
v1=[[a.*ones(N,1)], [-a.*ones(N,1)]];
q1=spdiags(v1,[0,1],N,N+1);
val = [q1];

