function PInfo=measur_d
% PInfo=measur_d
%   function for definition of the measur_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

V=st_Varia;
F=fieldnames(V);
for i=1:length(F)-1;
  F2{i}=['''' F{i} ''''];
end

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description
% for pulldown box:
% Name, Default, Item descr., Item valuestrings, Unit, Description, 'select'

PInfo = st_addPInfo(PInfo,'VariaName',  '''Flow''',    F,  F2, '', 'Select Flow or Water quality parameter', 'select');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
