function PInfo=wssetc_d
% PInfo=wssetc_d
%   function for definition of the wssetc_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description
% for pulldown box:
% Name, Default, Item descr., Item valuestrings, Unit, Description, 'select'

PInfo = st_addPInfo(PInfo,'WSTag',  '''WSTagName''',    0,     1, '',    'Waterspot Tag to read from','text');
PInfo = st_addPInfo(PInfo,'WSDescription',  '''''',    0,     1, '',    'Waterspot Tag description','text');
PInfo = st_addPInfo(PInfo,'WSUnit',  '''''',    0,     1, '',    'Unit','text');
PInfo = st_addPInfo(PInfo,'Default',  '1',    0,  NaN, '',    'Default value');
PInfo = st_addPInfo(PInfo,'Minimal',  '0',    0,  NaN, '',    'Minimal normal value');
PInfo = st_addPInfo(PInfo,'Maximal',  'NaN',    0,  NaN, '',    'Maximal normal value');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
