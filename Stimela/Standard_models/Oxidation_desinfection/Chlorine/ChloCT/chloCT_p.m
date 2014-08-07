function P = chloCT_p(chloCT_file);
%  P = chloCT_p(chloCT_file)
%   Parameter initialisation of model chloCT
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
chloCT_fileEcht = chckFile(chloCT_file);
if ~chloCT_fileEcht
    error(['Cannot find parameterfile ''' chloCT_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(chloCT_fileEcht, 'chloCT');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
