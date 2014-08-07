function P = ozodo1_p(ozodo1_file);
%  P = ozodo1_p(ozodo1_file)
%   Parameter initialisation of model ozodo1
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
ozodo1_fileEcht = chckFile(ozodo1_file);
if ~ozodo1_fileEcht
    error(['Cannot find parameterfile ''' ozodo1_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(ozodo1_fileEcht, 'ozodo1');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
