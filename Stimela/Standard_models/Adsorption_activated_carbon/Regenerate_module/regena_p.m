function P = regena_p(regena_file);
%  P = regena_p(regena_file)
%   Parameter initialisation of model regena
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
regena_fileEcht = chckFile(regena_file);
if ~regena_fileEcht
    error(['Cannot find parameterfile ''' regena_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(regena_fileEcht, 'regena');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

% all in secs
P.TL  = P.TL*3600*24;
P.Tsp = P.Tsp*3600*24;
P.Tst = P.Tst*3600*24;


%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
