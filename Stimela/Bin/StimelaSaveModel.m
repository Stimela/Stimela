function StimelaSaveModel(nm)
% save model and state

if ~isdir('./StimelaStates/')
  mkdir('StimelaStates')
end

dircd = cd;
nn = findstr(dircd,'\');

sysnm = dircd(nn(end)+1:end);
open_system([ dircd '\' sysnm]);

vr = ver('matlab');
if (vr.Version(1)=='6')
  save_system(sysnm,['./StimelaStates/' sysnm '_' nm ])
else
  save_system(sysnm,['./StimelaStates/' sysnm '_' nm ],'SaveAsVersion','R2007a')
end

% wel altijd de goede open!
close_system(nm,0);
open_system([ dircd '\' sysnm]);
