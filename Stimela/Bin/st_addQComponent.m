function Q = st_addQComponent(Q,LongName,ShortName,Unit,Description)
% Q = st_addQComponent(Q,LongName,ShortName,Unit,Description)
%   Add Standard variabele list
%
% Stimela, 2004

% © Kim van Schagen,

% namen moeten uniek zijn!
for i =1:length(Q)
    if strcmp(Q(i).LongName,LongName)
        error(['Component LongName "' LongName '" already exists']);
    end    
    if strcmp(Q(i).ShortName,ShortName)
        error(['Component ShortName "' ShortName '" already exists']);
    end    
end    

% ok , toevoegen
V1.LongName = LongName;
V1.ShortName = ShortName;
V1.Unit = Unit;
if nargin<5
  V1.Description = LongName;
else  
  V1.Description = Description;
end
Q = [Q;V1];
