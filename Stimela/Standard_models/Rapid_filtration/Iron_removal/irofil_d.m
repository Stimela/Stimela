function PInfo=irofil_d
% PInfo=irofil_d
%   function for definition of the irofil_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description

PInfo = st_addPInfo(PInfo,'Surf',  '0',    0,     +inf, 'm²',    'Filter surface area:');
PInfo = st_addPInfo(PInfo,'Lwater',  '0',    -inf,     +inf, 'm',    'Water level above the filter bed:');
PInfo = st_addPInfo(PInfo,'Lbed',  '0',    -inf,     +inf, 'm',    'Bed height:');
PInfo = st_addPInfo(PInfo,'Diam',  '0',    0,     +inf, 'mm',    'Grainsize:');
PInfo = st_addPInfo(PInfo,'FilPor',  '0',    -inf,     +inf, '%',    'Filter porosity:');
PInfo = st_addPInfo(PInfo,'nmax',  '0',    -inf,     +inf, '%',    'Maximum porefilling:');
PInfo = st_addPInfo(PInfo,'rhoD',  '0',    -inf,     +inf, 'kg/m³',    'Massdensity of the flocs:');
%PInfo = st_addPInfo(PInfo,'rhoK',  '0',    -inf,     +inf, 'kg/m³',    'Massdensity of the filter grains:');
%PInfo = st_addPInfo(PInfo,'LaShift',  '0',    -inf,     +inf, 'm³/m³',    'Shift of Lambda0:');
PInfo = st_addPInfo(PInfo,'NumCel',  '0',    0,     +inf, '-',    'Number of completely mixed reactors:');
PInfo = st_addPInfo(PInfo,'Lambda_Iron3',  '0.01',    0,     +inf, 'm^-1',    'Lambda Iron3:');
PInfo = st_addPInfo(PInfo,'Kfe',  '0',    0,     +inf, '-',    'Transformation coefficient iron:');
PInfo = st_addPInfo(PInfo,'Kf',  '0',    0,     +inf, '-',    'Freundlich constant Iron2 K:');
PInfo = st_addPInfo(PInfo,'nf',  '0',    0,     +inf, '-',    'Freundlich constant Iron2 n:');
PInfo = st_addPInfo(PInfo,'M',  '0',    0,     +inf, '-',    'Kinetic constant adsorption Iron2:');
PInfo = st_addPInfo(PInfo,'rhoK',  '0',    -inf,     +inf, 'kg/m³',    'Massdensity of the filter grains:');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
