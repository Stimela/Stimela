function PInfo=enkfil_d
% PInfo=enkfil_d
%   function for definition of the enkfil_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description

PInfo = st_addPInfo(PInfo,'Surf',   '20',    0,     +inf, 'm²',          'Filter surface area:');
PInfo = st_addPInfo(PInfo,'Lwater',  '1',    -inf,     +inf, 'm',        'Water level above the filter bed:');
PInfo = st_addPInfo(PInfo,'Lbed',  '1.5',    -inf,     +inf, 'm',        'Bed height:');
PInfo = st_addPInfo(PInfo,'Diam',    '1',    0,     +inf, 'mm',          'Grainsize:');
PInfo = st_addPInfo(PInfo,'FilPor0', '39',    -inf,     +inf, '%',        'Filter porosity:');
PInfo = st_addPInfo(PInfo,'nmax',   '75',    -inf,     +inf, '%',        'Maximum porefilling:');
PInfo = st_addPInfo(PInfo,'rhoD',   '30',    -inf,     +inf, 'kg/m³',    'Massdensity of the flocs:');
PInfo = st_addPInfo(PInfo,'Lambda0', '0.15',    -inf,     +inf, '1/m',   'Lambda0:');
PInfo = st_addPInfo(PInfo,'n1','290',-inf, +inf, '-',                    'clogging constant 1:');
PInfo = st_addPInfo(PInfo,'n2','310',-inf, +inf, '-',                    'clogging constant 2:');
PInfo = st_addPInfo(PInfo,'NumCel',  '6',    0,     +inf, '-',           'Number of completely mixed reactors:');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
