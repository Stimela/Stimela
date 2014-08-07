function PInfo=nitfil_d
% PInfo=nitfil_d
%   function for definition of the nitfil_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description

PInfo = st_addPInfo(PInfo,'Surf',            '40',    -inf,     inf, 'm²',    'Filter surface area:');
PInfo = st_addPInfo(PInfo,'Lbed',           '1.5',    -inf,     inf, 'm',    'Bed height:');
PInfo = st_addPInfo(PInfo,'Diam',             '1',    -inf,     inf, 'mm',    'Grain size:');
PInfo = st_addPInfo(PInfo,'FilPor',          '39',    -inf,     inf, '%',    'Porosity:');
PInfo = st_addPInfo(PInfo,'X0_Ns',           '10',    -inf,     inf, 'g/m³',    'X0ns:');
PInfo = st_addPInfo(PInfo,'X0_Nb',           '10',    -inf,     inf, 'g/m³',    'X0nb:');
PInfo = st_addPInfo(PInfo,'MuMax15_Ns',  '5e-006',    -inf,     inf, '1/s',    'mumax15ns:');
PInfo = st_addPInfo(PInfo,'MuMax15_Nb',  '9e-006',    -inf,     inf, '1/s',    'mumax15nb:');
PInfo = st_addPInfo(PInfo,'B_Ns',        '2e-007',    -inf,     inf, '1/s',    'Bns:');
PInfo = st_addPInfo(PInfo,'B_Nb',        '2e-007',    -inf,     inf, '1/s',    'Bnb');
PInfo = st_addPInfo(PInfo,'Y_Ns',          '0.15',    -inf,     inf, '-',    'Yns');
PInfo = st_addPInfo(PInfo,'Y_Nb',          '0.06',    -inf,     inf, '-',    'Ynb');
PInfo = st_addPInfo(PInfo,'KsPO4_Ns',     '0.005',    -inf,     inf, 'g/m³',    'KsPO4ns');
PInfo = st_addPInfo(PInfo,'KsPO4_Nb',     '0.005',    -inf,     inf, 'g/m³',    'KsPO4nb');
PInfo = st_addPInfo(PInfo,'KsO2_Ns',        '0.5',    -inf,     inf, 'g/m³',    'KsO2ns');
PInfo = st_addPInfo(PInfo,'KsO2_Nb',        '0.5',    -inf,     inf, 'g/m³',    'KsO2nb');
PInfo = st_addPInfo(PInfo,'AlfaT_Ns',      '1.05',    -inf,     inf, '-',    'alphaTns');
PInfo = st_addPInfo(PInfo,'AlfaT_Nb',      '1.05',    -inf,     inf, '-',    'alphaTnb');
PInfo = st_addPInfo(PInfo,'NumCel',           '6',    -inf,     inf, '-',    'umber of completely mixed reactors: ');


%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
