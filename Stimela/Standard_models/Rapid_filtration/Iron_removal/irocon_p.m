function P = irocon_p(irocon_file);
%  P = irocon_p(irocon_file)
%   Parameter initialisation of model irocon
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
irocon_fileEcht = chckFile(irocon_file);
if ~irocon_fileEcht
    error(['Cannot find parameterfile ''' irocon_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(irocon_fileEcht, 'irocon');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
