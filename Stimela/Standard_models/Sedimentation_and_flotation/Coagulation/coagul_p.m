function P = coagul_p(coagul_file);
%  P = coagul_p(coagul_file)
%   Parameter initialisation of model coagul
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
coagul_fileEcht = chckFile(coagul_file);
if ~coagul_fileEcht
    error(['Cannot find parameterfile ''' coagul_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(coagul_fileEcht, 'coagul');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
