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
  sys = x;
    
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the state value on the next samplemoment (determined by
  % B.SampleTime)
  % eg. sys(1) = (x(1)+u(U.Temperature))/P.Volume;

  % Determine extra measurements
  % eg. sys(U.Number+1) = x(1)/P.Opp;

  % inkomende getallen opslaan
  sys(1) = x(1);

  
  % regeling
  if length(P.WSControlName)>0
    if (t-x(1))>P.WSMinimalT | t<x(1)
      eval(P.WSControlName,['disp([''WSControl Function (' P.WSControlName ') Error : '' lasterr ])']);
      sys(1) = t;
    end
  end

%disp(['@Time  ' sprintf('%g ',clock) ' ==> t = ' sprintf('%g ',t) ]);

      
  if length(P.WSReplayData)>0
    % replay functionaliteit    
    k=max(find(P.ReplayTime<t));
    if isempty(k)
      k = 1;
    end 
      
    for i=1:P.nInputs
      sys(i+1) = P.Inputvalues{i}(k);
    end
  else
    for i=1:length(P.WSInputNames)
      sys(i+1) = evalin('base',P.WSInputNames{i});
    end 
  end
  
  if (P.WSStartTime>=0)
    % synchroniseren met Server
    pause(0.1)
  end

  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if any( (~isreal(sys)) | isnan(sys))
    disp([gcb 'has complex or nan values in flag=2'] )
    sys((~isreal(sys))| isnan(sys))=0;
  end
  
elseif flag ==4, % next sample hit

  minstep=1e-5;
  
  % is only called if the sample time equals -2
  %  e.g. sys = t+1;
  
  if length(P.WSReplayData)>0
    if t<max(P.ReplayTime)
      sys = P.ReplayTime(min(find(P.ReplayTime>t)));
      else
        %assignin('base','WSStopSimulation',1);
        sys=t+365*24*3600;
      end
  else
  if (P.WSStartTime>=0)
    WS = evalin('base','WSServerTime');
    tServer = (WS-P.WSStartTime)*24*3600;
    if tServer<0
      error('back in time!');
    end

    if tServer<=t
      % as slow as possible
      sys = t+minstep;
    else
      sys = tServer;
    end
  else
    sys=t+365*24*3600;
  end
  end
  
%  fid = fopen(['Log-' strrep(gcb,'/','_') '.txt'],'at');
%  fprintf(fid, 'Flag=4 : ',clock);
%  fprintf(fid, '%g ',clock);
%  fprintf(fid, 't=%g;',t);
%  fprintf(fid, 'sys=%g;',sys);
%  fprintf(fid, '\n');
%  fclose(fid);
  
  
elseif flag ==3, % output data determination

  % default equal to the input with zeros for extra measurements
  sys = x;

  % t=0 is uitzondering. Toestanden gelijk zetten.!
  if (t==0)
    for i=1:length(P.WSInputNames)
      sys(i+1) = evalin('base',P.WSInputNames{i});
    end 
  end
  
  % voor stoppen
  sys(1) = evalin('base','WSStopSimulation');
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Determine output for calculated values
  % eg. sys(U.Temparature) = x(1);

  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if any( (~isreal(sys)) | isnan(sys))
    disp('ws2opc has complex or nan values in flag=3')
    sys((~isreal(sys))| isnan(sys))=0;
  end
  
elseif flag == 0
  % initialize Model
  % [cs,ds,out,in,,direct,nots]
  sys = [0,length(P.WSInputNames)+1,length(P.WSInputNames)+1,0, 0, 0, 2];
  ts = [0 1; -2 0];
  x0 = zeros(length(P.WSInputNames)+1,1);
  str = 'opc2ws';
  x0(1) = 0; %tijd
  for i=1:length(P.WSInputNames);
    x0(i+1) = P.WSInputValues(i);
  end
else
    % If flag is anything else, no need to return anything
    % since this is a continuous system
    sys = [];
end



