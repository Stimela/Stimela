function PInfo=cascad_d
% PInfo=cascad_d
%   function for definition of the cascad_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[]; 

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description

PInfo = st_addPInfo(PInfo,'NumCel',    '6',    1,  [], '-',    'Number of cascades');
PInfo = st_addPInfo(PInfo,'VBak',    '0.5',    0,  [], 'm^3',  'Volume of one cascade chamber');
%PInfo = st_addPInfo(PInfo,'QgTot',  '1000', 0,  [], 'm^3/h',   'Total airflow');
PInfo = st_addPInfo(PInfo,'RQeff',   '0.4', 0.3,  0.5, '-',    'Effective air to water ratio');
%PInfo = st_addPInfo(PInfo,'MeeTe',     '1',    {'Cocurrent','Countercurrent'},   {'1','0'}, '-', 'Flow direction','select');
PInfo = st_addPInfo(PInfo,'k2CH4',  '0.04',  0,   1, '1/s',    'Gas transfer coëfficient (k_2) for methane');
%PInfo = st_addPInfo(PInfo,'PercFe',    '0',    0,  [], '%',    'During aeration oxidated iron');
%PInfo = st_addPInfo(PInfo,'PercCa',    '0',    0,  [], '%',    'During aeration converted calcium');
PInfo = st_addPInfo(PInfo,'Vair',  '0',  0,   [], 'm^3',    'Air volume above cascade');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
