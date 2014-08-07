function P = wsgetm_p(wsgetm_file);
%  P = wsgetm_p(wsgetm_file)
%   Parameter initialisation of model wsgetm
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
wsgetm_fileEcht = chckFile(wsgetm_file);
if ~wsgetm_fileEcht
    error(['Cannot find parameterfile ''' wsgetm_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(wsgetm_fileEcht, 'wsgetm');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
