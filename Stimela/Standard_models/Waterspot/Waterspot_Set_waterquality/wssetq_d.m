function PInfo=wssetq_d
% PInfo=wssetq_d
%   function for definition of the wssetq_d parameters
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

PInfo = st_addPInfo(PInfo,'WSTag',  '''WSTagName''',    0,     1, '',    'Waterspot Tag to read from','text');
PInfo = st_addPInfo(PInfo,'WSDescription',  '''''',    0,     1, '',    'Waterspot Tag description','text');
PInfo = st_addPInfo(PInfo,'VariaName',  '''Flow''',    F,  F2, '', 'Select Flow or Water quality parameter', 'select');
PInfo = st_addPInfo(PInfo,'WSUnit',  '''''',    0,     1, '',    'Unit','text');
PInfo = st_addPInfo(PInfo,'Default',  '1',    0,  NaN, '',    'Default value');
PInfo = st_addPInfo(PInfo,'Minimal',  '0',    0,  NaN, '',    'Minimal normal value');
PInfo = st_addPInfo(PInfo,'Maximal',  'NaN',    0,  NaN, '',    'Maximal normal value');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
