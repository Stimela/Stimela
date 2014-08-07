function [sys,x0,str,ts] = chloCT_s(t,x,u,flag,B,x0,U,P),
%  [sys,x0,str,ts] = chloCT_s(t,x,u,flag,B,x0,U,P),
%    Stimela S-Function
%
% t = time
% x = state vector, filled with continuous states (flag 1) or
%                      discrete states (flag 2)
% u = input vector
%
% P =  proces parameters, filled with chloCT_p.m and defined in 
%	   chloCT_d.m
% B =  Model size, filled with chloCT_i.m,
% x0 = initial state, filled with chloCT_i.m,
% U = Translationstructure for inout vector, filled in uit 
%     Blok00_i.m.
%     Fields are determined by 'st_Varia'
%
% Stimela, 2004-2009

% © Kim van Schagen,

% General purpose calculations
if any(abs(flag)==[1 2 3])

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % optional: convert input vector to user names
  % eg. Temp = u(U.Temperature);
  % in the code it is also possible to use u(U.Temparature) 
  % directly.

  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
	vol     = P.vol; %[m3]
	bf      = P.bf; %[-]
	cResidue= P.cResidue; %[mg/L] 
	
	temp    = u(U.Temperature); %[degree C]
	flow    = u(U.Flow); %[m3/h]
	pH      = u(U.pH); %[-]
	giardia = u(U.Giardia); %[-]
	viruses = u(U.Virusses); %[-]

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % optional: calculated values used for al flags
  % eg. TempArea = u(U.Temperature)/P.Area;
  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end; % of any(abs(flag)==[1 2 3])

if flag == 1, % Continuous states derivative calculation

  % default derivative =0;
  sys = zeros(B.CStates,1);
  
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the derivatives of the continuous states
  % eg. sys(1) = (u(U.Temperature)-x(1))/P.Volume;
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if any( (~isreal(sys)) | isnan(sys))
    disp([gcb ' has complex or nan values in flag=1'])
    sys((~isreal(sys))| isnan(sys))=0;
  end
  
elseif flag ==2, %discrete state determination

  % default next sample same states (length is B.DStates)
  sys = x(B.CStates+1:B.CStates+B.DStates);
    
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the state value on the next samplemoment
  % (determined by B.SampleTime)
  % eg. sys(1) = (x(1)+u(U.Temperature))/P.Volume;
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if any( (~isreal(sys)) | isnan(sys))
    disp([gcb ' has complex or nan values in flag=2'])
    sys((~isreal(sys))| isnan(sys))=0;
  end
  
elseif flag ==4, % next sample hit

  % is only called if the sample time equals -2
  %  e.g. sys = t+1;
  
elseif flag ==3, % output data determination

  % default equal to the input with zeros for extra measurements
  sys               = [u(1:U.Number*B.WaterOut); ...
      zeros(B.Measurements,1)];
  sys(U.Giardia)    = getInactivation(cResidue, vol, flow ...
      , bf, pH, temp, giardia, 'giardia');
  sys(U.Virusses)   = getInactivation(cResidue, vol, flow ...
      , bf, pH, temp, viruses, 'viruses');
  
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Determine output for calculated values
  % eg. sys(U.Temparature) = x(1);

  % Determine extra measurements
  % eg. sys(U.Number+1) = x(1)/P.Opp;  
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if any( (~isreal(sys)) | isnan(sys))
    disp([gcb ' has complex or nan values in flag=3'])
    sys((~isreal(sys))| isnan(sys))=0;
  end
  
elseif flag == 0
  % initialize Model
  % [cs,ds,out,in,,direct]
  sys   = [B.CStates,B.DStates,U.Number*B.WaterOut+ ...
           B.Measurements,U.Number*B.WaterIn+B.Setpoints, ...
           0, B.Direct,1];
  ts    = [B.SampleTime,0];
  str   = 'chloCT';
  x0    = x0;
else
    % If flag is anything else, no need to return anything
    % since this is a continuous system
    sys = [];
end
end % #chloCT_s
%______________________________________________________________
%% getInactivation
% Calculate the inactivation of Giardia or viruses according 
% to the CT method from the US EPA 
function pathogen = getInactivation(clRes, vol, flow, bf, ...
    pH, temp, pathogen, pathogenType)

flow    = flow/60; %[m3/min]
t       = vol/flow*bf; %[min]
ctCalc  = clRes*t; 

switch pathogenType
    case 'giardia'
        ctTable     = epaTable('getCTValue', 'giardia', ...
            temp, pH, clRes);
        logInact    = 3*ctCalc/ctTable; 
    case 'viruses'
        ctTable     = epaTable('getCTValue', 'viruses', temp, pH);
        logInact    = 4*ctCalc/ctTable;
    otherwise
        error('.')
end

pathogen = pathogen*(1/10^logInact);
end % #getInactivation
%______________________________________________________________