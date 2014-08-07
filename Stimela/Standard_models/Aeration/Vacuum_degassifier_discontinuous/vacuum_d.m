function PInfo=vacuum_d
% PInfo=vacuum_d
%   function for definition of the vacuum_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description

PInfo = st_addPInfo(PInfo,'Height',    '2',    -inf,  +inf, 'm',    'Heigth of the packed bed:');
PInfo = st_addPInfo(PInfo,'Diam',    '1.6',    -inf,  +inf, 'm',    'Diameter of the packed bed:');
PInfo = st_addPInfo(PInfo,'PercOpen', '95',    -inf,  +inf, '%',    'Free volume packing:');
PInfo = st_addPInfo(PInfo,'Percl',    '20',    -inf,  +inf, '%',    'Amount of water in the degassifier (4 - 10):');
PInfo = st_addPInfo(PInfo,'Tvac',    '560',    -inf,  +inf, 's',    'Degassifying time:');
PInfo = st_addPInfo(PInfo,'Tpump',    '30',    -inf,  +inf, 's',    'Vacuum pumping time:');
PInfo = st_addPInfo(PInfo,'k2',     '0.03',    -inf,  +inf, '1/s',    'Gas transfer coëfficiënt (k_2) for methane:');
PInfo = st_addPInfo(PInfo,'NumCel',    '4',    -inf,  +inf, '-',    'Number of completely mixed reactors:');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
