function PInfo=koofil_d
% PInfo=koofil_d
%   function for definition of the koofil_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description

PInfo = st_addPInfo(PInfo,'Area',  '50',    -inf,     +inf, 'm²',    'Filter surface area:');
PInfo = st_addPInfo(PInfo,'Lb',  '2',    -inf,     +inf, 'm',    'Bed height:');
PInfo = st_addPInfo(PInfo,'Diam',  '2',    -inf,     +inf, 'mm',    'Grainsize:');
PInfo = st_addPInfo(PInfo,'FilPor',  '50',    -inf,     +inf, '%',    'Filter porosity:');
PInfo = st_addPInfo(PInfo,'n',  '0.5',    -inf,     +inf, '-',    'Freundlich constant n:');
PInfo = st_addPInfo(PInfo,'rhoK',  '500',    -inf,     +inf, 'kg/m³',    'Massdensity of the activated carbon:');
PInfo = st_addPInfo(PInfo,'K',  '20',    -inf,     +inf, 'g/kg)*(m³/g)^n',    'Freundlich constante K:');
PInfo = st_addPInfo(PInfo,'M',  '10',    -inf,     +inf, '1/h',    'Mass transfer coëfficiënt k2:');
PInfo = st_addPInfo(PInfo,'NumCel',  '5',    -inf,     +inf, '-',    'Number of completely mixed reactors:');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
