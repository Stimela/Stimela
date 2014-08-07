function winhelp(naam,filenm)
% help in dir van naam
% als niet opgegegeven in naam anders in filenm

dirnm = which(naam);
l = findstr(dirnm,naam);

dirnm = dirnm(1:l(length(l))-1);

if nargin < 2
  [direc,filenm]=Fileprop(naam);
  helpnm = [dirnm direc filenm '.hlp'];
else
  helpnm = [dirnm filenm];
end

dos(upper(['winhelp '  helpnm]));
