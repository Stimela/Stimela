function [PValue, PString]=st_getPdata(fileEcht, modelName)
% PValue=st_getPdata(fileEcht, modelName)
%   convert and check data for parameter list in Stimela model
%
% Stimela, 2004

% © Kim van Schagen,


% load data
try
  load(fileEcht);
catch
  disp(['Warning File Not Found:' fileEcht]);
end

% load modeldata
PInfo = feval([modelName '_d']);

PValue=[];
PString=[];

% default
for i=1:length(PInfo)
  PV = eval(PInfo(i).DefaultValue);
  PValue = setfield(PValue,PInfo(i).Name,PV);
  PString = setfield(PString,PInfo(i).Name,PInfo(i).DefaultValue);
end

% data
if exist('P','var')
  for i=1:length(PInfo)
    % if field existsupdate
    if isfield(P,PInfo(i).Name)
      PVStr =getfield(P,PInfo(i).Name);
      if isnumeric(PVStr)
        PValue = setfield(PValue,PInfo(i).Name,PVStr);
        PString = setfield(PString,PInfo(i).Name,num2str(PVStr));
      else
        try
          PV = eval(PVStr);
          PValue = setfield(PValue,PInfo(i).Name,PV);
          PString = setfield(PString,PInfo(i).Name,PVStr);
        catch
          % is al gevuld
        end
      end
    end
  end
end  
