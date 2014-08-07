function P = harder_p(harder_file);
%  P = harder_p(harder_file)
%   Parameter initialisation of model harder
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
harder_fileEcht = chckFile(harder_file);
if ~harder_fileEcht
    error(['Cannot find parameterfile ''' harder_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(harder_fileEcht, 'harder');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
