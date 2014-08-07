function PInfo=invruw_d
% PInfo=invruw_d
%   function for definition of the invruw_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description

%Parameters are equal to water quality
V = st_Variabelen;

for i=1 :length(V)
  PInfo = st_addPInfo(PInfo,V(i).LongName,  '0',    0,     [], V(i).Unit,    V(i).Description);
end  

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
