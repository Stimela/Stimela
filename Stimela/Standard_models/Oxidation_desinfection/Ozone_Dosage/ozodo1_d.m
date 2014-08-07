function PInfo=ozodo1_d
% PInfo=ozodo1_d
%   function for definition of the ozodo1_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description
% for pulldown box:
% Name, Default, Item descr., Item valuestrings, Unit, Description, 'select'

PInfo = st_addPInfo(PInfo,'AirFlow',  '0.576',     0,     1, 'Nm3/h',    'Gas flow');
PInfo = st_addPInfo(PInfo,'O2Air',    '283.07',    0,     1, 'g/Nm3',    'Oxygen concentration in gas');
PInfo = st_addPInfo(PInfo,'N2Air',    '0',         0,     1, 'g/Nm3',    'Nitrogen concentration in gas');
PInfo = st_addPInfo(PInfo,'O3Air',    '29.3',      0,     1, 'g/Nm3',    'Ozone concentration in gas');
%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
