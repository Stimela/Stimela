function P = modmes_p(modmes_file);
%  P = modmes_p(modmes_file)
%   Parameter initialisation of model modmes
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
modmes_fileEcht = chckFile(modmes_file);
if ~modmes_fileEcht
    error(['Cannot find parameterfile ''' modmes_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(modmes_fileEcht, 'modmes');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;


%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
