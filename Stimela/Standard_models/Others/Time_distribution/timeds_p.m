function P = timeds_p(timeds_file);
%  P = timeds_p(timeds_file)
%   Parameter initialisation of model timeds
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
timeds_fileEcht = chckFile(timeds_file);
if ~timeds_fileEcht
    error(['Cannot find parameterfile ''' timeds_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(timeds_fileEcht, 'timeds');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
