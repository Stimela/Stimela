function P = wsgetq_p(wsgetq_file);
%  P = wsgetq_p(wsgetq_file)
%   Parameter initialisation of model wsgetq
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
wsgetq_fileEcht = chckFile(wsgetq_file);
if ~wsgetq_fileEcht
    error(['Cannot find parameterfile ''' wsgetq_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(wsgetq_fileEcht, 'wsgetq');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

V=st_Varia;
P.uNumber = getfield(V,P.VariaName);

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
