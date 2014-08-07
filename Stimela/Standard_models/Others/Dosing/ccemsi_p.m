function P = ccemsi_p(ccemsi_file);
%  P = ccemsi_p(ccemsi_file)
%   Parameter initialisation of model ccemsi
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
ccemsi_fileEcht = chckFile(ccemsi_file);
if ~ccemsi_fileEcht
    error(['Cannot find parameterfile ''' ccemsi_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(ccemsi_fileEcht, 'ccemsi');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
