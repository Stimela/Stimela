function P = sofcon_p(sofcon_file);
%  P = sofcon_p(sofcon_file)
%   Parameter initialisation of model sofcon
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
sofcon_fileEcht = chckFile(sofcon_file);
if ~sofcon_fileEcht
    error(['Cannot find parameterfile ''' sofcon_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(sofcon_fileEcht, 'sofcon');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
