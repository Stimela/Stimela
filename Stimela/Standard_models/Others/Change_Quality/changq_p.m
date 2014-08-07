function P = changq_p(changq_file);
%  P = changq_p(changq_file)
%   Parameter initialisation of model changq
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
changq_fileEcht = chckFile(changq_file);
if ~changq_fileEcht
    error(['Cannot find parameterfile ''' changq_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(changq_fileEcht, 'changq');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;
V=st_Varia;
P.uNumber = getfield(V,P.VariaName);

%if ~evalin('base',['exist(''' P.WSTag ''',''var'')'])
%  assignin('base',P.WSTag,P.Default);
%end


%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
