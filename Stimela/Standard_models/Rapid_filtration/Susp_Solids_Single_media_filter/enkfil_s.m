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
  NumCel  = P.NumCel;
  Surf    = P.Surf;
  Diam    = P.Diam/1000.0;
  nmax    = P.nmax/100.0;
  rhoD    = P.rhoD;
  FilPor0 = P.FilPor0/100.0;
  Lwater  = P.Lwater;
  Lambda0 = P.Lambda0;
  Lbed	  = P.Lbed;
  n1      = P.n1;
  n2      = P.n2;
  
  dy      = Lbed/NumCel;
%5  k1=1/n1;
%  k2=1/n2;

  %LogPr('NumCel',NumCel);
  %LogPr('Surf',Surf);
  %LogPr('Diam',Diam);
  %LogPr('nmax',nmax);
  %LogPr('rhoD',rhoD);
  %LogPr('FilPor0',FilPor0);
  %LogPr('Lwater',Lwater);
  %LogPr('Lambda0',Lambda0);
  %LogPr('Lbed',Lbed);
  %LogPr('n1',n1);
  %LogPr('n2',n2);
  %LogPr('dy',dy);

  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % optional: calculated values used for al flags
  % eg. TempArea = u(U.Temperature)/P.Area;
  Susp   = u(U.Suspended_solids);		%mg/l
  Susp   = Susp/1000;					%kg/m3
  Temp   = u(U.Temperature);
  Flow = u(U.Flow);
  
  %LogPr('Susp',Susp);
  %LogPr('Temp',Temp);
  %LogPr('Flow',Flow);

  vel = Flow/(Surf*3600);               %surface loading
  
  %LogPr('vel',vel);

  
  nu=(497e-6)/((Temp+42.5)^1.5);
  I0=(180*nu*(1-FilPor0)^2*vel)./(9.81*FilPor0^3*Diam.^2);
  
  %LogPr('nu',nu);
  %LogPr('I0',I0);
  LogPr('t',t);
  
  MatQ1 = Matrix(1,NumCel);      %Concentratie/accumulatie laag1
  
  
  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

end; % of any(abs(flag)==[1 2 3])


if flag == 1, % Continuous states derivative calculation

  % default derivative =0;
  sys = zeros(B.CStates,1);
  
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the derivatives of the continuous states
  % eg. sys(1) = (u(U.Temperature)-x(1))/P.Volume;
  
  FilPor=FilPor0-(x(NumCel+1:2*NumCel)/rhoD);

  
  
  spoelen = u(U.Number+1);
  
    
  if spoelen == 1
     sys(1:2*NumCel)=-(1/90)*x(1:2*NumCel);
	 
  else
  
	%suspended solids
     sys(1:NumCel) = ((vel./FilPor)/dy).*(MatQ1*[Susp;x(1:NumCel)]) - (vel./FilPor).*((Lambda0*(1+(x(NumCel+1:2*NumCel)*n1/(rhoD))-((x(NumCel+1:2*NumCel)/rhoD).^2)*n2./((FilPor))))).*x(1:NumCel);
     
	 %dSolids1=((vel./FilPor)/dy).*(MatQ1*[Susp;x(1:NumCel)]);
	 dSolids2=sys(1:NumCel);
	 
	 %LogPr('dSolids2',dSolids2);
	 
	%accumulation solids 
	 sys(NumCel+1:2*NumCel) = (vel).*((Lambda0*(1+(x(NumCel+1:2*NumCel)*n1/(rhoD))-((x(NumCel+1:2*NumCel)/rhoD).^2)*n2./((FilPor))))).*x(1:NumCel);
	
	sigma=(x(NumCel+1:2*NumCel));
	dsigma=sys(NumCel+1:2*NumCel);
	
     %LogPr('FilPor',FilPor);
	 %LogPr('dSolids1',dSolids1);
	 
	%LogPr('sigma',sigma);
	%LogPr('dsigma',dsigma);

	 
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

  concentratie=sys(U.Suspended_solids);
  LogPr('concentratie', concentratie);

  
  % Determine extra measurements
  % eg. sys(U.Number+1) = x(1)/P.Opp;
  sys(U.Number+1:U.Number+NumCel)= x(1:NumCel)*1000; %concentratie SS [mg/l]
  sys(U.Number+1+NumCel:U.Number+2*NumCel)=cumsum(dy-I0.*dy.*(FilPor0./(FilPor0-x(NumCel+1:2*NumCel)/rhoD)).^2); %weerstand tgv accumulatie laag1
  %temp1=(FilPor0./(FilPor0-x(NumCel+1:2*NumCel)/rhoD));
  %LogPr('temp1', temp1);

 ConcentratieSS=sys(U.Number+1:U.Number+NumCel);
 weerstand=sys(U.Number+1+NumCel:U.Number+2*NumCel);
 LogPr('ConcentratieSS',ConcentratieSS);
 LogPr('weerstand', weerstand);
 
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







function val = Matrix(T,N)
a     = 1./T;
v1=[[a.*ones(N,1)], [-a.*ones(N,1)]];
q1=spdiags(v1,[0,1],N,N+1);
val = [q1];

function LogPr(name, d)

    fid=fopen('enkfil_s.log','at');
	if (fid~=0)
      fprintf(fid,'%s',name);
      fprintf(fid,'\t%g',d);

      fprintf(fid,'\n');
      fclose(fid);
  end




