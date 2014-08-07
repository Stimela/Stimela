function P = splits_p(splits_file);
%  P = splits_p(splits_file)
%   Parameter initialisation of model splits
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
splits_fileEcht = chckFile(splits_file);
if ~splits_fileEcht
    error(['Cannot find parameterfile ''' splits_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(splits_fileEcht, 'splits');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
