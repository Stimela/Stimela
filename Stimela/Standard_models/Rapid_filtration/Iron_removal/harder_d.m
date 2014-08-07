function PInfo=harder_d
% PInfo=harder_d
%   function for definition of the harder_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description

PInfo = st_addPInfo(PInfo,'Surf',  '20',    0,     +inf, 'm²',    'Filter surface area:');
PInfo = st_addPInfo(PInfo,'Lwater',  '1',    -inf,     +inf, 'm',    'Water level above the filter bed:');
PInfo = st_addPInfo(PInfo,'Lbed',  '1.5',    -inf,     +inf, 'm',    'Clean bed height:');
PInfo = st_addPInfo(PInfo,'Diam',  '1',    0,     +inf, 'mm',    'Clean bed Grainsize:');
PInfo = st_addPInfo(PInfo,'FilPor',  '39',    -inf,     +inf, '%',    'Clean bed Filter porosity:');
PInfo = st_addPInfo(PInfo,'nmax',  '75',    -inf,     +inf, '%',    'Maximum porefilling:');
PInfo = st_addPInfo(PInfo,'rhoD',  '10',    -inf,     +inf, 'kg/m³',    'Massdensity of the ironIII flocs:');
PInfo = st_addPInfo(PInfo,'Lambda_Iron3',  '100',    0,     +inf, 'm^-1',    'Clean bed Lambda IronIII:');
PInfo = st_addPInfo(PInfo,'rhoK',  '10',    -inf,     +inf, 'kg/m³',    'Massdensity of the IronII coating:');
PInfo = st_addPInfo(PInfo,'NumCel',  '5',    0,     +inf, '-',    'Number of completely mixed reactors:');
PInfo = st_addPInfo(PInfo,'k0',  '2.3e5',    0,     +inf, '-',    'Kinetic constant conversion ironII:');
PInfo = st_addPInfo(PInfo,'Df',      '2.67e-11',  0,  1000, '-', 'Diffusion constant ironII');
PInfo = st_addPInfo(PInfo,'Kauto',  '1.4067e-008',    0,     +inf, '-',    'Kinetic constant adsorption IronII:');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
