function P = vlokvo_p(vlokvo_file);
%  P = vlokvo_p(vlokvo_file)
%   Parameter initialisation of model vlokvo
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
vlokvo_fileEcht = chckFile(vlokvo_file);
if ~vlokvo_fileEcht
    error(['Cannot find parameterfile ''' vlokvo_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(vlokvo_fileEcht, 'vlokvo');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;
P.dy     = P.Length/P.NumCel;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
