function StimelaSaveState(StateName)
% StimelaSaveState(StateName)
%  save the current xFinal and StimelaData


if ~isdir('./StimelaStates/')
  mkdir('StimelaStates')
end

if exist(['./StimelaStates/' StateName '.mat'],'file')
  error(['State "' StateName '" already exists!'])
end

% state file laden
try
  xFinal = evalin('base','xFinal');
catch
  xFinal=[];
end

% opslaan state
vr = ver('matlab');
if vr.Version(1)=='6'
  save(['./StimelaStates/' StateName '.mat'],'xFinal');
else
  %hogere versies
  save(['./StimelaStates/' StateName '.mat'],'-V6','xFinal');
end 

% directory maken
mkdir (['./StimelaStates/' StateName '_StimelaData/']);

% kopieren Stimeladata
a = dir('./StimelaData/*.mat');
for i=1:length(a)
  copyparfile(['./StimelaData/' a(i).name],['./StimelaStates/' StateName '_StimelaData/' a(i).name]);
end

function copyparfile(nm1,nm2)
  % kopieren naar nieuwe dir!
  load (nm1)
  if exist('P','var')
    if ~exist('AdditionalData','var')
      AdditionalData=[];
    end
    
    % opslaan versie afhankelijk!
    vr = ver('matlab');
    if vr.Version(1)=='6'
      save(nm2,'P','AdditionalData');
    else
      %hogere versies
      save(nm2,'-V6','P','AdditionalData');
    end 
    
  end

