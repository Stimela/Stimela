function P = wssetc_p(wssetc_file);
%  P = wssetc_p(wssetc_file)
%   Parameter initialisation of model wssetc
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
wssetc_fileEcht = chckFile(wssetc_file);
if ~wssetc_fileEcht
    error(['Cannot find parameterfile ''' wssetc_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(wssetc_fileEcht, 'wssetc');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
