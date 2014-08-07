function P = vacuum_p(vacuum_file);
%  P = vacuum_p(vacuum_file)
%   Parameter initialisation of model vacuum
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
vacuum_fileEcht = chckFile(vacuum_file);
if ~vacuum_fileEcht
    error(['Cannot find parameterfile ''' vacuum_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(vacuum_fileEcht, 'vacuum');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;
P.PercOpen = P.PercOpen/100;
P.Percl    = P.Percl/100;
%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
