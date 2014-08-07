function PInfo=doscon_d
% PInfo=doscon_d
%   function for definition of the doscon_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description

PInfo = st_addPInfo(PInfo,'HCl',  '0',    0,     [], 'mmol/l',    'HCl dosing in main flow');
PInfo = st_addPInfo(PInfo,'H2SO4',  '0',    0,     [], 'mmol/l',    'H2SO4 dosing in main flow');
PInfo = st_addPInfo(PInfo,'CO2',  '0',    0,     [], 'mmol/l',    'CO2 dosing in main flow');
PInfo = st_addPInfo(PInfo,'NaOH',  '0',    0,     [], 'mmol/l',    'NaOH dosing in main flow');
PInfo = st_addPInfo(PInfo,'CaOH2',  '0',    0,     [], 'mmol/l',    'CaOH2 dosing in main flow');
PInfo = st_addPInfo(PInfo,'Na2CO3',  '0',    0,     [], 'mmol/l',    'Na2CO3 dosing in main flow');
PInfo = st_addPInfo(PInfo,'CaCO3',  '0',    0,     [], 'mmol/l',    'CaCO3 dosing in main flow');
PInfo = st_addPInfo(PInfo,'FeCl3',  '0',    0,     [], 'mmol/l',    'FeCl3 dosing in main flow');
PInfo = st_addPInfo(PInfo,'Fe2SO43',  '0',    0,     [], 'mmol/l',    'Fe2SO43 dosing in main flow');
PInfo = st_addPInfo(PInfo,'Al2SO43',  '0',    0,     [], 'mmol/l',    'Al2SO43 dosing in main flow');
