function [sys,x0,str,ts] = chloro_s(t,x,u,flag,B,x0,U,P),
%  [sys,x0,str,ts] = chloro_s(t,x,u,flag,B,x0,U,P),
%    Stimela S-Function
%
% t = time
% x = state vector, filled with continuous states (flag 1) or
%                      discrete states (flag 2)
% u = input vector
%
% P =  proces parameters, filled with chloro_p.m and defined in
%	   chloro_d.m
% B =  Model size, filled with chloro_i.m,
% x0 = initial state, filled with chloro_i.m,
% U = Translationstructure for inout vector, filled in uit
%     Blok00_i.m.
%     Fields are determined by 'st_Varia'
%
% Stimela, 2012

% Martijn Sparnaaij,

% General purpose calculations
if any(abs(flag)==[1 2 3])
  
  vol		= P.Vol;		%[m3]
  bf		= P.BF;			%[-]
  
  temp		= u(U.Temperature);	%[degree C]
  flow		= u(U.Flow);		%[m3/h]
  pH		= u(U.pH);		    %[-]
  giardia	= u(U.Giardia);		%[-]
  viruses	= u(U.Viruses);		%[-]
  doc		= u(U.DOC);		    %[mg/L]
  uv254		= u(U.UV254);		%[1/m]
  bromide	= u(U.Bromide);		%[mg/L]
  ammonia	= u(U.Ammonia);		%[mg/L]
  
  clDose	= u(U.Number+1);	%[g/h]
  suv254	= uv254/doc;		%[L/mg/m]
  uv254		= uv254/100;		%[1/cm]
  clConc	= clDose/flow;		%[mg/L]
  flow		= flow/3600;		%[m3/s]
  bromide	= bromide*1000;		%[mug/L]

end; % of any(abs(flag)==[1 2 3])

if flag == 1, % Continuous states derivative calculation
  
  % default derivative =0;
  sys		= zeros(B.CStates,1);
  
  Aln		= 0.168 - 0.148*log(x(1)/doc) + 0.29*log(uv254) - 0.41*log(x(1)) +...
    0.038*log(bromide) + 0.0554*log(ammonia) + 0.185*log(temp);
  Acalc		= exp(Aln);
  
  A		= Acalc;  
  if A > .999
    A = .999;
  end
  
  k1Ln		= 5.41 - 0.38*log(x(1)/doc) + 0.27*log(ammonia) - 1.12*log(temp) +...
    0.05*log(bromide) - 0.854*log(pH);
  k2Ln		= -7.13 + 0.86*log(x(1)/doc) + 2.63*log(doc) - 2.55*log(x(1)) +...
    0.62*log(suv254) + 0.16*log(bromide) + 0.48*log(ammonia) + 1.03*log(temp);
  k1Calc	= exp(k1Ln);
  k2Calc	= exp(k2Ln);
  
  k1		= k1Calc;
  k2		= k2Calc;
  k1		= k1/3600;
  k2		= k2/3600;
  
  AtthmLn	= -2.11 - 0.87*log(x(1)/doc) - 0.41*log(ammonia) + 0.21*log(x(1)) + 1.98*log(pH);
  AtthmCalc	= exp(AtthmLn);
  BtthmLn	= 1.48 - 1.11*log(suv254) - 0.67*log(x(1)/doc) + 0.27*log(uv254) +...
    0.093*log(bromide) + 1.41*log(pH) + 0.13*log(ammonia);
  BtthmCalc	= exp(BtthmLn);
  
  Atthm		= AtthmCalc;
  Btthm		= BtthmCalc;
  
  Ahaa6Ln	= 3.25 + 0.86*log(x(1)/doc) + 0.066*log(uv254) -...
    0.14*log(bromide) - 0.17*log(ammonia) + 0.25*log(suv254);
  Ahaa6Calc	= exp(Ahaa6Ln);
  Bhaa6Ln	= 4.37 + 1.11*log(x(1)) - 0.30*log(uv254) - 2.47*log(pH);
  Bhaa6Calc	= exp(Bhaa6Ln);
  
  Ahaa6		= Ahaa6Calc;
  Bhaa6		= Bhaa6Calc;
  
  k1a		= Atthm/A*k1;
  k1b		= Btthm/(1-A)*k2;
  k2a		= Ahaa6/A*k1;
  k2b		= Bhaa6/(1-A)*k2;
  % --------------------------------
  
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the derivatives of the continuous states
  % eg. sys(1) = (u(U.Temperature)-x(1))/P.Volume;
  sys(1) = (flow/vol)*(clConc - x(1)) - A*k1*x(1) - (1-A)*k2*x(1);
    
  sys(2) = k1a*x(1) + k2a*x(1) - (flow/vol)*x(2);
  sys(3) = k1b*x(1) + k2b*x(1) - (flow/vol)*x(3);
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  if any( (~isreal(sys)) | isnan(sys))
    disp([gcb ' has complex or nan values in flag=1'])
    sys((~isreal(sys))| isnan(sys))=0;
  end
   
elseif flag ==2, %discrete state determination
  
  % default next sample same states (length is B.DStates)
  sys = x(B.CStates+1:B.CStates+B.DStates);
  
  if any( (~isreal(sys)) | isnan(sys))
    disp([gcb ' has complex or nan values in flag=2'])
    sys((~isreal(sys))| isnan(sys))=0;
  end
  
elseif flag ==4, % next sample hit
  
  % is only called if the sample time equals -2
  %  e.g. sys = t+1;
  
elseif flag ==3, % output data determination
  
  % default equal to the input with zeros for extra measurements
  sys				= [u(1:U.Number*B.WaterOut);zeros(B.Measurements,1)];
  sys(U.Giardia)		= getInactivation(x(1), vol, flow, bf, pH, temp, giardia, 'giardia');
  sys(U.Viruses)		= getInactivation(x(1), vol, flow, bf, pH, temp, viruses, 'viruses');
  sys(U.Residualchlorine)	= x(1);		% mg/l
  sys(U.Totaltrihalomethanes)	= x(2);		% ug/l
  sys(U.Haloaceticacids)	= x(3);		% ug/l

  if any( (~isreal(sys)) | isnan(sys))
    disp([gcb ' has complex or nan values in flag=3'])
    sys((~isreal(sys))| isnan(sys))=0;
  end

  if x(3) > 10
    1;
  end
  
elseif flag == 0
  % initialize Model
  % [cs,ds,out,in,,direct]
  sys   = [B.CStates,B.DStates,U.Number*B.WaterOut+...
    B.Measurements,U.Number*B.WaterIn+B.Setpoints...
    , 0, B.Direct,1];
  ts    = [B.SampleTime,0];
  str   = 'chloro';
  x0    = x0;
else
  % If flag is anything else, no need to return anything
  % since this is a continuous system
  sys = [];
end

end % #chloro_s
%______________________________________________________________
%% #getInactivation
% Calculate the inactivation of Giardia or viruses according
% to the CT method from the US EPA
function pathogen = getInactivation(clRes, vol, flow, bf, pH, temp, pathogen, pathogenType)

flow		= flow*60; %[m3/min]
t		= vol/flow*bf; %[min]
ctCalc		= clRes*t;

switch pathogenType
  case 'giardia'
    ctTable	= epaTable('getCTValue', 'giardia', temp, pH, clRes);
    logInact	= 3*ctCalc/ctTable;
  case 'viruses'
    ctTable	= epaTable('getCTValue', 'viruses', temp, pH);
    logInact	= 4*ctCalc/ctTable;
  otherwise
    error('.')
end

pathogen	= pathogen*(1/10^logInact);

end % #getInactivation
%______________________________________________________________