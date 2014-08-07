function P = iexexc_p(iexexc_file);
%  P = iexexc_p(iexexc_file)
%   Parameter initialisation of model iexexc
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
iexexc_fileEcht = chckFile(iexexc_file);
if ~iexexc_fileEcht
    error(['Cannot find parameterfile ''' iexexc_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(iexexc_fileEcht, 'iexexc');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;
P.dy     = P.Lb/P.NumCel;
P.Diam   = P.Diam/1000;
P.M      = P.M/3600;
P.FilPor = P.FilPor/100;
%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
