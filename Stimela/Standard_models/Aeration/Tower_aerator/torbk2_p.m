function P = torbk2_p(torbk2_file);
%  P = torbk2_p(torbk2_file)
%   Parameter initialisation of model torbk2
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
torbk2_fileEcht = chckFile(torbk2_file);
if ~torbk2_fileEcht
    error(['Cannot find parameterfile ''' torbk2_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(torbk2_fileEcht, 'torbk2');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

%P.QgVers   = P.QgTot-P.QgRec;
P.PercFe   = P.PercFe/100;
P.PercCa   = P.PercCa/100;

P.QgTot  = P.QgTot/3600;% m3/s
%P.QgVers = P.QgVers/3600;
%P.QgRec  = P.QgRec/3600;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
