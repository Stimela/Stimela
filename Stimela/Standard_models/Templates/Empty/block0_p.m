function P = block0_p(block0_file);
%  P = block0_p(block0_file)
%   Parameter initialisation of model block0
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
block0_fileEcht = chckFile(block0_file);
if ~block0_fileEcht
    error(['Cannot find parameterfile ''' block0_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(block0_fileEcht, 'block0');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
