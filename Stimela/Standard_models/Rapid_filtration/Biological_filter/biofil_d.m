function PInfo=biofil_d
% PInfo=biofil_d
%   function for definition of the biofil_d parameters
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
PInfo = st_addPInfo(PInfo,'X0_DOC',           '10',    -inf,     inf, 'ng ATP/m³',    'X0DOC:');
% PInfo = st_addPInfo(PInfo,'X0_Nb',           '10',    -inf,     inf, 'g/m³',    'X0nb:');
% PInfo = st_addPInfo(PInfo,'MuMax15_Ns',  '5e-006',    -inf,     inf, '1/s',    'mumax15ns:');
PInfo = st_addPInfo(PInfo,'MuMax15_DOC',  '9e-006',    -inf,     inf, '1/s',    'mumax15DOC:');
% PInfo = st_addPInfo(PInfo,'B_Ns',        '2e-007',    -inf,     inf, '1/s',    'Bns:');
PInfo = st_addPInfo(PInfo,'B_DOC',        '2e-007',    -inf,     inf, '1/s',    'Decay');
PInfo = st_addPInfo(PInfo,'Y_DOC',          '0.15',    -inf,     inf, 'ng ATP/mg C',    'Yield');
PInfo = st_addPInfo(PInfo,'Y_O2',          '2.5',    -inf,     inf, 'mg O2/mg C',    'YieldO2');
PInfo = st_addPInfo(PInfo,'Y_CO2',          '2',    -inf,     inf, 'mg CO2/mg C',    'YieldCO2');
PInfo = st_addPInfo(PInfo,'Y_PO4',          '0.0001',    -inf,     inf, 'mg PO4/mg C',    'YieldPO4');
% PInfo = st_addPInfo(PInfo,'Y_Nb',          '0.06',    -inf,     inf, '-',    'Ynb');
% PInfo = st_addPInfo(PInfo,'KsPO4_Ns',     '0.005',    -inf,     inf, 'g/m³',    'KsPO4ns');
PInfo = st_addPInfo(PInfo,'KsDOC',     '0.1',    -inf,     inf, 'g/m³',    'KsDOC');
PInfo = st_addPInfo(PInfo,'KsPO4',     '0.005',    -inf,     inf, 'g/m³',    'KsPO4');
PInfo = st_addPInfo(PInfo,'KsO2',        '0.5',    -inf,     inf, 'g/m³',    'KsO2');
% PInfo = st_addPInfo(PInfo,'KsO2_Nb',       '1.05',    -inf,     inf, 'g/m³',    'KsO2nb');
% PInfo = st_addPInfo(PInfo,'AlfaT_Ns',      '1.05',    -inf,     inf, '-',    'alphaTns');
PInfo = st_addPInfo(PInfo,'AlfaT_DOC',         '6',    -inf,     inf, '-',    'alphaTDOC');
PInfo = st_addPInfo(PInfo,'PercBDOC',           '20',    -inf,     inf, '-',    'Percentage biodegradable DOC: ');
PInfo = st_addPInfo(PInfo,'NumCel',           '4',    -inf,     inf, '-',    'Number of completely mixed reactors: ');


%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
