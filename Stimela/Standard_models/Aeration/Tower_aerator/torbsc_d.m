function PInfo=torbsc_d
% PInfo=torbsc_d
%   function for definition of the torbsc_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description

PInfo = st_addPInfo(PInfo,'Hoogte',  '2.6',    0,     [], 'm',    'Heigth of the packed bed');
PInfo = st_addPInfo(PInfo,'Diam',  '1',        0,  [], 'm',    'Diameter of the packed bed');
PInfo = st_addPInfo(PInfo,'QgTot',  '2000',    0,  [], 'm^3/h',    'Total air flow');
PInfo = st_addPInfo(PInfo,'QgRec',  '0.4',    0,  [], 'm^3/h',    'Recirculation air flow');
PInfo = st_addPInfo(PInfo,'MeeTe',   '0',    {'Cocurrent','Countercurrent'},   {'1','0'}, '-', 'Flow direction','select');
PInfo = st_addPInfo(PInfo,'k2',  '0.05',    0,  [], '1/s',    'Gas transfer coëfficiënt (k_2)');
PInfo = st_addPInfo(PInfo,'kD',  '0.05',    0,  [], '-',    'Distribution coëfficiënt (kD)');
PInfo = st_addPInfo(PInfo,'NumCel',  '5',    0,  [], '-',    'Number of completely mixed reactors');

%PInfo = st_addPInfo(PInfo,'PercFe',  '4',    0,  [], '%',    'During aeration oxidated iron');
%PInfo = st_addPInfo(PInfo,'PercCa',  '2',    0,  [], '%',    'During aeration converted calcium');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
