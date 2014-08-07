function P = buffal_p(buffal_file);
%  P = buffal_p(buffal_file)
%   Parameter initialisation of model buffal
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
buffal_fileEcht = chckFile(buffal_file);
if ~buffal_fileEcht
    error(['Cannot find parameterfile ''' buffal_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(buffal_fileEcht, 'buffal');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
