function [sys,x0,str,ts] = timeds_s(t,x,u,flag,B,x0,U,P),
%  [sys,x0,str,ts] = timeds_s(t,x,u,flag,B,x0,U,P),
%    Stimela S-Function
%
% t = time
% x = state vector, filled with continuous states (flag 1) or
%                      discrete states (flag 2)
% u = input vector
%
% P =  proces parameters, filled with timeds_p.m and defined in timeds_d.m
% B =  Model size, filled with timeds_i.m,
% x0 = initial state, filled with timeds_i.m,
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
  th     = P.th; %hydraulic retention time
  
  Conduc = u(U.Conductivity);
  % in timeds_i.m is 'Temperatuur' opgezocht in de elementen vector.
  Temp   = u(U.Temperature);
  Ql     = u(U.Flow);
  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % optional: calculated values used for al flags
  % eg. TempArea = u(U.Temperature)/P.Area;

  % LET OP, VOOR GEVORDERDEN:
  % Aangepaste verblijftijdspreidingscurven
  % Het volgende blok kan gebruikt worden wanneer het gewenst is de waterstroom niet in allemaal evengrootte
  % gemengde vaten op te delen maar in gemengde vaten van verschillende grootten. Hiermee kan in principe
  % iedere willekeurige verblijftijdspreidingscurve benaderd worden.  
  % Voorbeeld:
  % Aantal = 2, TijdAantal = 0.9, totale verblijftijd = 100 seconden en NumCel = 10 (aantal volledig gemende vaten)
  % in dit geval hebben de eerste 8 volledige gemengde vaten een totale verblijftijd van 0.1 * 100 = 10 seconden
  % dat betekent dat ieder van de eerste 8 vaten een verblijftijd heeft van 10/8 = 1.25 seconde. De laatste
  % twee vaten hebben een totale verblijftijd van 0.9 * 100 = 90 seconden dat betekent dat ieder van de laatste
  % twee vaten een verblijftijd heeft van 90/2 = 45 seconden. Dit zal tot gevolg hebben dat de piek in de
  % verblijftijdspreidingscurve eerder optreedt en lager zal zijn dan bij 10 evengrootte volledig gemengde vaten.
  % Indien dit wordt toegepast moet de stromingsmatrix MatQ3 worden aangepast, zie opmerking bij 'stromingsmatrices'
  %%%%%%%%
  %Aantal     = 4;                        % De laatste volledig gemengde vaten, Aantal ( Aantal =< NumCel), hebben 
  %TijdAantal = 0.8;                      % een deel, TijdAantal (0 =< TijdAantal =< 1) van de totale verblijftijd
  %Tel        = 0;                        % initialiseren teller
  %for Tel=1:1:(NumCel-Aantal)
  %  TijdStap(Tel,1)=((1-TijdAantal)*Tgem)/(NumCel-Aantal);    %Tgem is de gemiddelde verblijftijd
  %end
  %for Tel=(NumCel-Aantal+1):1:NumCel
  %  TijdStap(Tel,1)=(TijdAantal*Tgem)/Aantal;
  %end
  %%%%%%%%

  dt = th/NumCel;   % timestep

    % Stromingsmatrices
  % LET OP, VOOR GEVORDERDEN:
  % Het cascade model heeft de mogelijkheid om de ijzeroxidatie niet alleen in toenemende mate plaats te laten vinden
  % maar ook constant over de waterstroom of geheel geconcentreerd in de laatste stap. Mocht dit wenselijk zijn dan 
  % moet in 'flag == 1' de bijbehorende regels worden gebruikt.
  MatQ1 = Matrix1(dt,NumCel);
  MatQ2 = rot90(eye(NumCel));
  MatQ3 = Matrix1(dt,NumCel+1);
  MatQ4 = Matrix2(dt,NumCel);        % constante ijzeroxidatie over waterstroom (stapjes)
  MatQ5 = Matrix3(dt,NumCel);        % toenemende ijzeroxidatie over waterstroom (stapjes)
  MatQ6 = Matrix1(dt,1);
  MatQ7 = Matrix4(dt,NumCel);        % al het ijzer wordt in de laatste stap geoxideerd
% Indien aangepaste verblijftijdsspreidingscurven worden toegepast moet de bovenstaande MatQ3, MatQ4 en MatQ7
% worden uitgezet en moeten de twee onderstaande regels met MatQ3 worden gebruikt. Het is dus alleen mogelijk
% met de aangepaste verblijftijdspreidingscurven te werken bij toenemende oxidatie over de waterstroom, 
% zie ook 'aangepaste verblijftijdsspreidingscurven'.
%  TijdStapVblT = [dt;1]; 
%  MatQ3 = M1gasuit(dt,NumCel+1);
  
  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

end; % of any(abs(flag)==[1 2 3])


if flag == 1, % Continuous states derivative calculation

  % default derivative =0;
  sys = zeros(B.CStates,1);
  
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the derivatives of the continuous states
  % eg. sys(1) = (u(U.Temperature)-x(1))/P.Volume;
  sys(1:NumCel) = MatQ1*[Conduc;x(1:NumCel)];
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
  sys(U.Conductivity)=x(NumCel);

  % Determine extra measurements
  % eg. sys(U.Number+1) = x(1)/P.Opp;
%  %sys(U.Number+1:U.Number+NumCel+1) = [Conduc;x(1:NumCel)];
  sys(U.Number+1:U.Number+NumCel+1) = MatQ3*[Conduc;x(1:NumCel);x(NumCel)];
  
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif flag == 0
  % initialize Model
  % [cs,ds,out,in,,direct]
  sys = [B.CStates,B.DStates,U.Number+B.Measurements,U.Number+B.Setpoints, 0, B.Direct,1];
  ts = [B.SampleTime,0];
  str = 'timeds';
  x0=x0;
else
    % If flag is anything else, no need to return anything
    % since this is a continuous system
    sys = [];
end



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



% The following function returns the matrix Q1 for aeration

function val = Matrix1(T,N)

a     = 1./T;
v1=[[a.*ones(N,1)], [-a.*ones(N,1)]];
q1=spdiags(v1,[0,1],N,N+1);
val = [q1];


% The following function returns the matrix Q2 for aeration

function val = Matrix2(T,N)

a     = 1./T;
v1=[-a.*ones(N,1)];
q1=spdiags(v1,[1],N,N+1);
Tel=0;
for p=1:N
  Tel=Tel+1;
  q1(Tel,1)=1/T;
end
val = [q1];


% The following function returns the matrix Q3 for aeration

function val = Matrix3(T,N)

a     = 1./T;
v1=[[a.*ones(N,1)], [-a.*ones(N,1)]];
q1=spdiags(v1,[0,N],N,2*N);
val = [q1];


% The following function returns the matrix Q4 for aeration

function val = Matrix4(T,N)

a     = 1./T;
v1=[-a.*ones(N,1)];
q1=spdiags(v1,[1],N,N+1);
Tel=0;
for p=1:N-1
  Tel=Tel+1;
  q1(Tel,1)=0;
end
q1(N,1)=1/T;
val = [q1];







