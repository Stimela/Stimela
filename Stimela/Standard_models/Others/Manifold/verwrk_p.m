function P = verwrk_p(verwrk_file);
%  P = verwrk_p(verwrk_file)
%   Parameter initialisation of model verwrk
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
verwrk_fileEcht = chckFile(verwrk_file);
if ~verwrk_fileEcht
    error(['Cannot find parameterfile ''' verwrk_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(verwrk_fileEcht, 'verwrk');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
