function PInfo=vacslp_d
% PInfo=vacslp_d
%   function for definition of the vacslp_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description

PInfo = st_addPInfo(PInfo,'Height',    '2',    -inf,  inf, 'm',    'Heigth of the packed bed:');
PInfo = st_addPInfo(PInfo,'Diam',      '1',    -inf,  inf, 'm',    'Diameter of the packed bed:');
PInfo = st_addPInfo(PInfo,'QgTot',    '40',    -inf,  inf, 'm^3/h',    'Total air flow:');
PInfo = st_addPInfo(PInfo,'QgDrag',  '0.5',    -inf,  inf, 'm^3/h',    'Drag air flow:');
PInfo = st_addPInfo(PInfo,'QgRec',     '0',    -inf,  inf, 'm^3/h',    'Recirculation air flow:');
PInfo = st_addPInfo(PInfo,'k2',     '0.05',    -inf,  inf, '1/s',    'Gas transfer coëfficiënt (k_2) for methane:');
PInfo = st_addPInfo(PInfo,'NumCel',    '4',    -inf,  inf, '-',    'Number of completely mixed reactors:');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
