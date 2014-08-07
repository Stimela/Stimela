function [sys,x0,str,ts] = vlokvo_s(t,x,u,flag,B,x0,U,P),
%  [sys,x0,str,ts] = vlokvo_s(t,x,u,flag,B,x0,U,P),
%    Stimela S-Function
%
% t = time
% x = state vector, filled with continuous states (flag 1) or
%                      discrete states (flag 2)
% u = input vector
%
% P =  proces parameters, filled with vlokvo_p.m and defined in vlokvo_d.m
% B =  Model size, filled with vlokvo_i.m,
% x0 = initial state, filled with vlokvo_i.m,
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
  G10    = P.G10;
  Ka     = P.Ka;
  Kb     = P.Kb;
  dy     = P.dy;
  
  Susp   = u(U.Suspended_solids);%mg/l
  Susp   = Susp/1000;%kg/m3
  Temp   = u(U.Temperature);
  Debiet = u(U.Flow);

  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % optional: calculated values used for al flags
  % eg. TempArea = u(U.Temperature)/P.Area;
  vel          = Debiet/(Opp*3600); %oppervlakte filtratiesnelheid
  VelReal      = vel;  
  MatQ1        = Matrix(NumCel);       %Concentratie/laag1
  % Kinematic viscosity
  nu=(497e-6)/((Temp+42.5)^1.5);
  nu10=(497e-6)/((10+42.5)^1.5);
  G=G10*(nu10/nu)^0.5;
  
  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

end; % of any(abs(flag)==[1 2 3])


if flag == 1, % Continuous states derivative calculation

  % default derivative =0;
  sys = zeros(B.CStates,1);
  
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the derivatives of the continuous states
  % eg. sys(1) = (u(U.Temperature)-x(1))/P.Volume;
  
    sys(1:NumCel) = (VelReal/dy)*MatQ1*[Susp;x(1:NumCel)] - Ka*G*x(1:NumCel) + Kb*G^2*x(1:NumCel);
    
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

  % Determine extra measurements
  % eg. sys(U.Number+1) = x(1)/P.Opp;
  
  %sys(U.Number+1:U.Number+(NumCel+1))= [Susp;x(1:NumCel)*1000]; %concentratie SS [mg/l]
  sys(U.Number+1:U.Number+(NumCel))= x(1:NumCel)*1000; %concentratie SS [mg/l]
  
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif flag == 0
  % initialize Model
  % [cs,ds,out,in,,direct]
  sys = [B.CStates,B.DStates,U.Number+B.Measurements,U.Number+B.Setpoints, 0, B.Direct,1];
  ts = [B.SampleTime,0];
  str = 'vlokvo';
  x0=x0;
else
    % If flag is anything else, no need to return anything
    % since this is a continuous system
    sys = [];
end



function val = Matrix(N)

v1=[[ones(N,1)], [-ones(N,1)]];
q1=spdiags(v1,[0,1],N,N+1);
val = [q1];







