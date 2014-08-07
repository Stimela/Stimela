function P = chloro_p(chloro_file)
%  P = chloro_p(chloro_file)
%   Parameter initialisation of model chloro
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
chloro_fileEcht = chckFile(chloro_file);
if ~chloro_fileEcht
    error(['Cannot find parameterfile ''' chloro_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(chloro_fileEcht, 'chloro');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
