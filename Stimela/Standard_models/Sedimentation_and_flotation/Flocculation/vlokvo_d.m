function PInfo=vlokvo_d
% PInfo=vlokvo_d
%   function for definition of the vlokvo_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description

PInfo = st_addPInfo(PInfo,'Length',  '5',    -inf,     +inf, 'm',    'Length of the reactor:');
PInfo = st_addPInfo(PInfo,'Surf',   '10',    -inf,     +inf, 'm²',   'Cross section of the reactor:');
PInfo = st_addPInfo(PInfo,'G10',   '100',    -inf,     +inf, '1/s',  'G-value at 10 ^oC:');
PInfo = st_addPInfo(PInfo,'Ka',   '1e-4',    -inf,     +inf, '-',    'Floc aggregation constant, K_a:');
PInfo = st_addPInfo(PInfo,'Kb',   '8e-7',    -inf,     +inf, '-',    'Floc breakup constant, K_b:');
PInfo = st_addPInfo(PInfo,'NumCel', '10',    -inf,     +inf, '-',    'Number of completely mixed reactors:');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
