function PInfo=dubfil_d
% PInfo=dubfil_d
%   function for definition of the dubfil_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description

PInfo = st_addPInfo(PInfo,'Surf',     '40',    0,     +inf, 'm²',    'Filter surface area:');
PInfo = st_addPInfo(PInfo,'Ls',       '0.4',    0,     +inf, 'm',     'Water level above the filter bed:');
PInfo = st_addPInfo(PInfo,'Lb1',      '1',    0,     +inf, 'm',     'Bed height (upper):');
PInfo = st_addPInfo(PInfo,'Lb2',      '1',    0,     +inf, 'm',     'Bed height (lower):');
PInfo = st_addPInfo(PInfo,'Diam1',    '1.45',    0,     +inf, 'mm',    'Grain size (upper):');
PInfo = st_addPInfo(PInfo,'Diam2',    '1.45',    0,     +inf, 'mm',    'Grain size (lower):');
PInfo = st_addPInfo(PInfo,'FilPor1',  '40',    -inf,  +inf, '%',     'Filter porosity (upper):');
PInfo = st_addPInfo(PInfo,'FilPor2',  '40',    -inf,  +inf, '%',     'Filter porosity (lower):');
PInfo = st_addPInfo(PInfo,'Lambda01', '0.003',    -inf,  +inf, '1/s',   'Lambda (upper):');
PInfo = st_addPInfo(PInfo,'Lambda02', '0003',    -inf,  +inf, '1/s',   'Lambda (lower):');
PInfo = st_addPInfo(PInfo,'n1',       '20',    0,     +inf, '-',     'Clogging constant 1:');
PInfo = st_addPInfo(PInfo,'n2',       '3',    0,     +inf, '-',     'Clogging constant 2:');
PInfo = st_addPInfo(PInfo,'rhoD',     '15',    0,     +inf, 'kg/m³', 'Massdensity of the flocs:');
PInfo = st_addPInfo(PInfo,'NumCel1',  '5',    0,     +inf, '-',     'Number of completely mixed reactors (upper):');
PInfo = st_addPInfo(PInfo,'NumCel2',  '5',    0,     +inf, '-',     'Number of completely mixed reactors (lower):');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
