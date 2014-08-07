function P = cascad_p(cascad_file);
%  P = cascad_p(cascad_file)
%   Parameter initialisation of model cascad
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
cascad_fileEcht = chckFile(cascad_file);
if ~cascad_fileEcht
    error(['Cannot find parameterfile ''' cascad_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(cascad_fileEcht, 'cascad');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

%P.PercFe = P.PercFe/100;
%P.PercCa = P.PercCa/100;
%P.QgTot  = P.QgTot/3600;% m3/s

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
