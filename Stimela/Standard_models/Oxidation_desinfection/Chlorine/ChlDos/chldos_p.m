function P = chldos_p(chldos_file);
%  P = chldos_p(chldos_file)
%   Parameter initialisation of model chldos
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
chldos_fileEcht = chckFile(chldos_file);
if ~chldos_fileEcht
    error(['Cannot find parameterfile ''' chldos_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(chldos_fileEcht, 'chldos');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
