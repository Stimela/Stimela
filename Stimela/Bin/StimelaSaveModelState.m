function StimelaSaveModelState(nm)
% save model and state


StimelaSaveState(nm);

dircd = cd;
nn = findstr(dircd,'\');

sysnm = dircd(nn(end)+1:end);
open_system([ dircd '\' sysnm]);

vr = ver('matlab');
if (vr.Version(1)=='6')
  save_system(sysnm,['./StimelaStates/' nm ])
else
  save_system(sysnm,['./StimelaStates/' nm ],'SaveAsVersion','R13')
end

% wel altijd de goede open!
close_system(nm,0);
open_system([ dircd '\' sysnm]);
