function [sys,x0,str,ts] = regena_s(t,x,u,flag,B,x0,U,P),
%  [sys,x0,str,ts] = regena_s(t,x,u,flag,B,x0,U,P),
%    Stimela S-Function
%
% t = time
% x = state vector, filled with continuous states (flag 1) or
%                      discrete states (flag 2)
% u = input vector
%
% P =  proces parameters, filled with regena_p.m and defined in regena_d.m
% B =  Model size, filled with regena_i.m,
% x0 = initial state, filled with regena_i.m,
% U = Translationstructure for inout vector, filled in uit Blok00_i.m.
%     Fields are determined by 'st_Varia'
%
% Stimela, 2004

% © Kim van Schagen,

% General purpose calculations
if any(abs(flag)==[1 2 3 4])
    

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % optional: convert input vector to user names
  % eg. Temp = u(U.Temperature);
  % in the code it is also possible to use u(U.Temparature) directly.

  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % optional: calculated values used for al flags
  % eg. TempArea = u(U.Temperature)/P.Area;

  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

end; % of any(abs(flag)==[1 2 3 4])


if flag == 1, % Continuous states derivative calculation

  % default derivative =0;
  sys = zeros(B.CStates,1);
  
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the derivatives of the continuous states
  % eg. sys(1) = (u(U.Temperature)-x(1))/P.Volume;

  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif flag ==2, %discrete state determination

  % default next sample same states (length is B.DStates)
  sys = x(B.CStates+1:B.CStates+B.DStates);
    
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the state value on the next samplemoment (determined by
  % B.SampleTime)
  % eg. sys(1) = (x(1)+u(U.Temperature))/P.Volume;

  if t >= x(1)+P.TL
      sys(1)=t;
  end
  if t < x(1)
    % old state information
      sys(1)=t+P.Tst;
  end
  
      
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif flag ==3, % output data determination

  % default equal to the input with zeros for extra measurements
  sys = [u(1:U.Number*B.WaterOut); zeros(B.Measurements,1)];

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Determine output for calculated values
  % eg. sys(U.Temparature) = x(1);

  % Determine extra measurements
  % eg. sys(U.Number+1) = x(1)/P.Opp;
  
  if t < x(1)+P.Tsp
      sys(1)=1;
  end
  
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
elseif flag == 4 % calculation of next sample hit
  
   % To determine if the system is at the end of the backwash cycle or at
   % the beginning. First equation represents the beginning and second
   % equation the end of the backwash cycle.
      
   sys(1)=x(1)+P.TL;
   
   if t<x(1)+P.Tsp 
       sys(1)=x(1)+P.Tsp;
   end
   if t>=sys(1)
     % old state information
     sys=t+1;
   end
   
elseif flag == 0
  % initialize Model
  % [cs,ds,out,in,,direct]
  sys = [B.CStates,B.DStates,U.Number*B.WaterOut+B.Measurements,U.Number*B.WaterIn+B.Setpoints, 0, B.Direct,1];
  ts = [B.SampleTime,0];
  str = 'regena';
  x0=x0;
else
    % If flag is anything else, no need to return anything
    % since this is a continuous system
    sys = [];
end



