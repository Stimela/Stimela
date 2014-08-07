function [sys,x0,str,ts] = invruw_s(t,x,u,flag,B,x0,U,P),
%  [sys,x0,str,ts] = invruw_s(t,x,u,flag,B,x0,U,P),
%    Stimela S-Function
%
% t = time
% x = state vector, filled with continuous states (flag 1) or
%                      discrete states (flag 2)
% u = input vector
%
% P =  proces parameters, filled with invruw_p.m and defined in invruw_d.m
% B =  Model size, filled with invruw_i.m,
% x0 = initial state, filled with invruw_i.m,
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
  sys = [u; zeros(B.Measurements,1)];

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Determine output for calculated values
  % eg. sys(U.Temparature) = x(1);

  sys = P.Constant;

  for i = P.VariabelLoop
      PM = P.Variabel{i};
      % tijdreeks
      if t<PM(1,1)
        sys(i)=PM(1,1); % t voor het begin dan onderdrukken
      else
        nT = size(PM,1);
        sys(i)=interp1(PM(:,1)-PM(1,1),PM(:,2),rem(t-PM(1,1),PM(nT,1)-PM(1,1))); % cyclisch uitlezen xv
      end
  end
  
%   PF=fieldnames(P);
%   for i = 1:length(PF)
%     PM = getfield(P,PF{i});
%     if length(PM)==1
%       sys(getfield(U,PF{i}))=PM;
%     else
%       % tijdreeks
%       if t<PM(1,1)
%         sys(i)=PM(1,1); % t voor het begin dan onderdrukken
%       else
%         nT = size(PM,1);
%         sys(i)=interp1(PM(:,1)-PM(1,1),PM(:,2),rem(t-PM(1,1),PM(nT,1)-PM(1,1))); % cyclisch uitlezen xv
%       end
%     end      
%   end
% 
  
  % Determine extra measurements
  % eg. sys(U.Number+1) = x(1)/P.Opp;
  
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif flag == 4

  % bepaal volgend sample. DAn in ieder geval!
  sys=inf;
  
  
  for i = P.VariabelLoop
    PM = P.Variabel{i};
      
    nT = size(PM,1);
    dt = rem(t,PM(nT,1)-PM(1,1));
    t0 = t-dt;
    
    n = find(dt<PM(:,1)-PM(1,1)); % cyclisch uitlezen xv
    if length(n)>0
      newTime = t0 + PM(n(1),1)-PM(1,1);
    else
      newTime = t0 + PM(nT,1)-PM(1,1)
    end
  
    if (newTime<sys)
      sys=newTime;
    end
 end
  
  if isinf(sys)
        sys=t+365*24*3600;
  end
  

elseif flag == 0
  % initialize Model
  % [cs,ds,out,in,,direct]
%  sys = [B.CStates,B.DStates,U.Number+B.Measurements,U.Number+B.Setpoints, 0, B.Direct,1];
  sys = [B.CStates,B.DStates,U.Number+B.Measurements,0, 0, B.Direct,2];
%  ts = [B.SampleTime,1]; % ,1 zorgt voor alleen update bij major time steps.
  ts = [0 1; -2 0]; % continuous/MajorUpdte + Flag=4
  str = 'invruw';
  x0=x0;
else
    % If flag is anything else, no need to return anything
    % since this is a continuous system
    sys = [];
end



