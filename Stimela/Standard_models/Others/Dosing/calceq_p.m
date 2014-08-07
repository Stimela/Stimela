function P = calceq_p(calceq_file);
%  P = calceq_p(calceq_file)
%   Parameter initialisation of model calceq
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
calceq_fileEcht = chckFile(calceq_file);
if ~calceq_fileEcht
    error(['Cannot find parameterfile ''' calceq_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(calceq_fileEcht, 'calceq');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
