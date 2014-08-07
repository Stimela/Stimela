function PInfo=plaatb_d
% PInfo=plaatb_d
%   function for definition of the plaatb_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description

PInfo = st_addPInfo(PInfo,'Lengte',  '4',    0,  [], 'm',     'Length of perforated plate');
PInfo = st_addPInfo(PInfo,'Breedte', '2',    0,  [], 'm',     'Width of perforated plate');
PInfo = st_addPInfo(PInfo,'Htot',    '0.35', 0,  [], 'm',     'Height of foam layer');
PInfo = st_addPInfo(PInfo,'PercWat', '50',   0, 100, '%',     'Water percentage in foam layer');
PInfo = st_addPInfo(PInfo,'QgTot',   '4000', 0,  [], 'Nm^3/h', 'Total airflow');
PInfo = st_addPInfo(PInfo,'QgRec',   '3600', 0,  [], 'Nm^3/h', 'Recirculation air flow:');
PInfo = st_addPInfo(PInfo,'k2',      '0.1',  0,   1, '1/s',   'Gas transfer coefficient (k_2) for methane');
PInfo = st_addPInfo(PInfo,'NumCel',  '5',    1,  [], '-',     'Number of completely mixed reactors');
%PInfo = st_addPInfo(PInfo,'PercFe',  '5',    0,  [], '%',     'During aeration oxidised iron');
%PInfo = st_addPInfo(PInfo,'PercCa',  '2',    0,  [], '%',     'During aeration converted calcium');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
