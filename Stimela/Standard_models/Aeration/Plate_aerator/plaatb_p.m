function P = plaatb_p(plaatb_file);
%  P = plaatb_p(plaatb_file)
%   Parameter initialisation of model plaatb
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
plaatb_fileEcht = chckFile(plaatb_file);
if ~plaatb_fileEcht
    error(['Cannot find parameterfile ''' plaatb_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(plaatb_fileEcht, 'plaatb');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

P.Popp     = P.Lengte*P.Breedte;
P.QgVers   = P.QgTot-P.QgRec;
%P.PercFe   = P.PercFe/100;
P.PercWat  = P.PercWat/100;
%P.PercCa   = P.PercCa/100;

P.QgTot  = P.QgTot/3600;% m3/s
P.QgVers = P.QgVers/3600;
P.QgRec  = P.QgRec/3600;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
