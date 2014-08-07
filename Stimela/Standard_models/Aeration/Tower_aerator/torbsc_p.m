function P = torbsc_p(torbsc_file);
%  P = torbsc_p(torbsc_file)
%   Parameter initialisation of model torbsc
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
torbsc_fileEcht = chckFile(torbsc_file);
if ~torbsc_fileEcht
    error(['Cannot find parameterfile ''' torbsc_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(torbsc_fileEcht, 'torbsc');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

P.QgVers   = P.QgTot-P.QgRec;

P.QgTot  = P.QgTot/3600;% m3/s
P.QgVers = P.QgVers/3600;
P.QgRec  = P.QgRec/3600;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
