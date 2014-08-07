function P = buffer_p(buffer_file);
%  P = buffer_p(buffer_file)
%   Parameter initialisation of model buffer
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
buffer_fileEcht = chckFile(buffer_file);
if ~buffer_fileEcht
    error(['Cannot find parameterfile ''' buffer_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(buffer_fileEcht, 'buffer');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
