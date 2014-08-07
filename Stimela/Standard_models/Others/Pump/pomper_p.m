function P = pomper_p(pomper_file);
%  P = pomper_p(pomper_file)
%   Parameter initialisation of model pomper
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
pomper_fileEcht = chckFile(pomper_file);
if ~pomper_fileEcht
    error(['Cannot find parameterfile ''' pomper_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(pomper_fileEcht, 'pomper');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
