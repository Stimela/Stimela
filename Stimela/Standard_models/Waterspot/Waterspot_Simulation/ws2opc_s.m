function [sys,x0,str,ts] = ws2opc_s(t,x,u,flag,B,x0,U,P),
%  [sys,x0,str,ts] = ws2opc_s(t,x,u,flag,B,x0,U,P),
%    Stimela S-Function
%
% t = time
% x = state vector, filled with continuous states (flag 1) or
%                      discrete states (flag 2)
% u = input vector
%
% P =  proces parameters, filled with ws2opc_p.m and defined in ws2opc_d.m
% B =  Model size, filled with ws2opc_i.m,
% x0 = initial state, filled with ws2opc_i.m,
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

  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % optional: calculated values used for al flags
  % eg. TempArea = u(U.Temperature)/P.Area;

  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

end; % of any(abs(flag)==[1 2 3])


if flag == 1, % Continuous states derivative calculation

  % default derivative =0;
  sys = zeros(B.CStates,1);
  
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the derivatives of the continuous states
  % eg. sys(1) = (u(U.Temperature)-x(1))/P.Volume;
 
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if any( (~isreal(sys)) | isnan(sys))
    disp([ gcb ' has complex or nan values in flag=1'] )
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

  if any( (~isreal(sys)) | isnan(sys))
    disp([gcb 'has complex or nan values in flag=2'] )
    sys((~isreal(sys))| isnan(sys))=0;
  end
  
elseif flag ==3, % output data determination

  % default equal to the input with zeros for extra measurements

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Determine output for calculated values
  % eg. sys(U.Temparature) = x(1);

  % Determine extra measurements
  % eg. sys(U.Number+1) = x(1)/P.Opp;
  
  % outputs van de vorige stap?
  for i=1:length(P.WSOutputNames)
    assignin('base',P.WSOutputNames{i},u(i+1));
 end
 
  %huidige tijd
  if (P.WSStartTime>=0)
    assignin('base','WSStimelaTime',P.WSStartTime+t/24/3600);  
  else
    assignin('base','WSStimelaTime',t);  
  end  

  sys(1)=0;
  if (P.WSStartTime>=0)
    WS = evalin('base','WSServerTime');
    sys(1)= WS-(P.WSStartTime+t/24/3600);
  end

  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if any( (~isreal(sys)) | isnan(sys))
    disp('ws2opc has complex or nan values in flag=3')
    sys((~isreal(sys))| isnan(sys))=0;
  end
  
elseif flag == 0
  % initialize Model
  % [cs,ds,out,in,,direct]
  sys = [0,0,1,length(P.WSOutputNames)+1, 0, 1, 1];
  ts = [-1 1];
  str = 'ws2opc';
  x0=[];

else
    % If flag is anything else, no need to return anything
    % since this is a continuous system
    sys = [];
end



