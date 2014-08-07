function PInfo=pels25_d
% PInfo=pels25_d
%   function for definition of the pels25_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description

PInfo = st_addPInfo(PInfo,'A',       '5',          0,    20, 'm2',           'Bottom surface of reactor');
PInfo = st_addPInfo(PInfo,'Angle',   '0',          0,    89, 'o',            'Conic angle of the reactor (0 degrees is vertical)');
PInfo = st_addPInfo(PInfo,'d0',      '0.25',       0,  1000, 'mm',           'Initial grain size');
PInfo = st_addPInfo(PInfo,'rhog',    '4100',       0,  1000, 'kg/m3',        'Density grains');
PInfo = st_addPInfo(PInfo,'rhos',    '2500',       0,  1000, 'kg/m3',        'Density Calcium Carbonate');
PInfo = st_addPInfo(PInfo,'rhol',    '1270',       0,  1000, 'kg/m3',        'Density Caustic Soda Solution');
PInfo = st_addPInfo(PInfo,'sl',      '0.25',       0,  1000, 'kg/kg',        'Strength Caustic Soda Solution');
PInfo = st_addPInfo(PInfo,'NumCel',  '10',         0,  1000, '-',            'Number of completely mixed reactors');
PInfo = st_addPInfo(PInfo,'kg0',     '3000',       0,  1000, 'kg',           'Initial grain mass in reactor');
PInfo = st_addPInfo(PInfo,'d',       '[]',         0,  1000, '-',            'Initial diameter per reactor');
PInfo = st_addPInfo(PInfo,'KT20',    '0.0254',      0,  1000, 'm3 m/ mol s',  'Cristalisation constant');
PInfo = st_addPInfo(PInfo,'Df',      '2.67e-11',  0,  1000, '-',            'Diffusion');
PInfo = st_addPInfo(PInfo,'IoEc',    '0.183',      0,  1000, '-',            'EGV to IS conversion');
PInfo = st_addPInfo(PInfo,'FB',      '0',          0,  1000, '-',            '0:bed model 1:no bed growth');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
