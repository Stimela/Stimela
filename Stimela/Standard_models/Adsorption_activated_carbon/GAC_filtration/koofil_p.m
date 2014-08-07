function P = koofil_p(koofil_file);
%  P = koofil_p(koofil_file)
%   Parameter initialisation of model koofil
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
koofil_fileEcht = chckFile(koofil_file);
if ~koofil_fileEcht
    error(['Cannot find parameterfile ''' koofil_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(koofil_fileEcht, 'koofil');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;
P.dy     = P.Lb/P.NumCel;
P.Diam   = P.Diam/1000;
P.M      = P.M/3600;
P.FilPor = P.FilPor/100;
%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
