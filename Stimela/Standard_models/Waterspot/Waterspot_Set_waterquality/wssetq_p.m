function P = wssetq_p(wssetq_file);
%  P = wssetq_p(wssetq_file)
%   Parameter initialisation of model wssetq
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
wssetq_fileEcht = chckFile(wssetq_file);
if ~wssetq_fileEcht
    error(['Cannot find parameterfile ''' wssetq_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(wssetq_fileEcht, 'wssetq');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;
V=st_Varia;
P.uNumber = getfield(V,P.VariaName);

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
