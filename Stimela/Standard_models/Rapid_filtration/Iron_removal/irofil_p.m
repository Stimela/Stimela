function P = irofil_p(irofil_file);
%  P = irofil_p(irofil_file)
%   Parameter initialisation of model irofil
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
irofil_fileEcht = chckFile(irofil_file);
if ~irofil_fileEcht
    error(['Cannot find parameterfile ''' irofil_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(irofil_fileEcht, 'irofil');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;
P.dy     = P.Lbed/P.NumCel;
P.Diam   = P.Diam/1000;
P.FilPor = P.FilPor/100;
P.nmax   = P.nmax/100;
%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
