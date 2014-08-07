function P = enkfil_p(enkfil_file);
%  P = enkfil_p(enkfil_file)
%   Parameter initialisation of model enkfil
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
enkfil_fileEcht = chckFile(enkfil_file);
if ~enkfil_fileEcht
    error(['Cannot find parameterfile ''' enkfil_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(enkfil_fileEcht, 'enkfil');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;


%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
