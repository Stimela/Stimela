function [sys,x0,str,ts] = koofil_s(t,x,u,flag,B,x0,U,P),
%  [sys,x0,str,ts] = koofil_s(t,x,u,flag,B,x0,U,P),
%    Stimela S-Function
%
% t = time
% x = state vector, filled with continuous states (flag 1) or
%                      discrete states (flag 2)
% u = input vector
%
% P =  proces parameters, filled with koofil_p.m and defined in koofil_d.m
% B =  Model size, filled with koofil_i.m,
% x0 = initial state, filled with koofil_i.m,
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
  Opp    = P.Area;
  Diam   = P.Diam;
  n      = P.n;
  rhoK   = P.rhoK;
  FilPor = P.FilPor;
  dy     = P.dy;
  K      = P.K;
  M      = P.M;
  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % optional: calculated values used for al flags
  % eg. TempArea = u(U.Temperature)/P.Area;
  Tl      = u(U.Temperature);         %watertemperatuur            [Celsius]
  Ql      = u(U.Flow);         %waterdebiet                 [m3/h]
  coDOC   = u(U.DOC);         %dissolved organic carbon    [mg/l]
  

  vel     = Ql/(Opp*3600);                          %oppervlakte filtratiesnelheid
  VelReal = vel/FilPor;                             %poriesnelheid
  MatQ1   = d_filmat1(dy,VelReal,vel/rhoK,NumCel);   %
  MatQ2   = d_filmat2(dy,NumCel);
  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

end; % of any(abs(flag)==[1 2 3])


if flag == 1, % Continuous states derivative calculation

  % default derivative =0;
  sys = zeros(B.CStates,1);
  
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the derivatives of the continuous states
  % eg. sys(1) = (u(U.Temperature)-x(1))/P.Volume;
  Spoel=u(U.Number+1);  
  
  if Spoel==1
    sys(1:2*NumCel)=-(1/90)*x(1:2*NumCel); 
  else
   sys(1:NumCel)=VelReal*MatQ2*[coDOC;x(1:NumCel)]-(1-FilPor)/FilPor*(rhoK*M)*[K*(sign(x(1:NumCel)).*(abs(x(1:NumCel))).^n)-x(NumCel+1:2*NumCel)];
   sys(NumCel+1:2*NumCel)=M*[K*(sign(x(1:NumCel)).*(abs(x(1:NumCel))).^n)-x(NumCel+1:2*NumCel)];
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
  sys(U.DOC)=x(NumCel);
  
  % Determine extra measurements
  % eg. sys(U.Number+1) = x(1)/P.Opp;
  Spoel1=u(U.Number+1);  
  
  sys(U.Number+1:U.Number+(NumCel+2))= [coDOC;x(1:NumCel);Spoel1];
  sys(U.Number+1+(NumCel+2):U.Number+2*(NumCel+2))=[0;x(NumCel+1:2*NumCel);Spoel1];
  
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif flag == 0
  % initialize Model
  % [cs,ds,out,in,,direct]
  sys = [B.CStates,B.DStates,U.Number+B.Measurements,U.Number+B.Setpoints, 0, B.Direct,1];
  ts = [B.SampleTime,0];
  str = 'koofil';
  x0=x0;
else
    % If flag is anything else, no need to return anything
    % since this is a continuous system
    sys = [];
end


%%Functions

function val = d_filmat(dy,vp,v,N)

b     = -vp/(2*dy);
c     = vp/(2*dy);
e     = v/(2*dy);
alpha = -vp/dy;
beta  = vp/dy; 
v1=[[c*ones(N-1,1);beta], [zeros(N-1,1);alpha], [b*ones(N-1,1);0]];
q1=spdiags(v1,[0,1,2],N,N+1);

v2=[[e*ones(N-1,1);2*e], [zeros(N-1,1);-2*e], [-e*ones(N-1,1);0]];
q2=spdiags(v2,[0,1,2],N,N+1);

val = [q1;q2];

function val = d_filmat1(dy,vp,v,N)

c     = vp/(dy);
e     = v/(dy);
v1=[[c.*ones(N,1)], [-c.*ones(N,1)]];
q1=spdiags(v1,[0,1],N,N+1);
v2=[[e.*ones(N,1)], [-e.*ones(N,1)]];
q2=spdiags(v2,[0,1],N,N+1);
val = [q1;q2];

function val = d_filmat2(dy,N)
a1     = 1/dy;
a2    = -1/dy;
alpha = -1/dy;
beta  = 1/dy;
v1=[[a1*ones(N-1,1);beta], [a2*ones(N-1,1);alpha]];
q1=spdiags(v1,[0,1],N,N+1);
val = [q1];
