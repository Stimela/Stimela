function P = mengpH_p(mengpH_file);
%  P = mengpH_p(mengpH_file)
%   Parameter initialisation of model mengpH
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
mengpH_fileEcht = chckFile(mengpH_file);
if ~mengpH_fileEcht
    error(['Cannot find parameterfile ''' mengpH_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(mengpH_fileEcht, 'mengpH');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
