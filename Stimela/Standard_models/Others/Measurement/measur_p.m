function P = measur_p(measur_file);
%  P = measur_p(measur_file)
%   Parameter initialisation of model measur
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
measur_fileEcht = chckFile(measur_file);
if ~measur_fileEcht
    error(['Cannot find parameterfile ''' measur_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(measur_fileEcht, 'measur');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

V=st_Varia;
P.uNumber = getfield(V,P.VariaName);

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
