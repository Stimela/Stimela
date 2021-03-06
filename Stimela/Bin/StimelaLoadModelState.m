function StimelaLoadModelState(nm)
% load model and state


StimelaLoadState(nm);

dircd = cd;
nn = findstr(dircd,'\');

sysnm = dircd(nn(end)+1:end);
close_system([sysnm],0);
copyfile(['./StimelaStates/' nm '.mdl'],[sysnm '.mdl'],'f');

open_system([ dircd '\' sysnm]);
