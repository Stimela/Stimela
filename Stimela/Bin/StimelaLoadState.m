function StimelaLoadState(StateName)
% StimelaLoadState(StateName)
%  load  xFinal and StimelaData


if ~exist(['./StimelaStates/' StateName '.mat'],'file')
  error(['State "' StateName '" not found!'])
end

load(['./StimelaStates/' StateName '.mat'],'xFinal')
assignin('base','xFinal',xFinal);

% kopieren Stimeladata
a = dir(['./StimelaStates/' StateName '_StimelaData/*.mat']);
for i=1:length(a)
  copyparfile(['./StimelaStates/' StateName '_StimelaData/' a(i).name],['./StimelaData/' a(i).name]);
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

