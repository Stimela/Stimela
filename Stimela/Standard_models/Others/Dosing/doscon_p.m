function P = doscon_p(doscon_file);
%  P = doscon_p(doscon_file)
%   Parameter initialisation of model doscon
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
doscon_fileEcht = chckFile(doscon_file);
if ~doscon_fileEcht
    error(['Cannot find parameterfile ''' doscon_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(doscon_fileEcht, 'doscon');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
