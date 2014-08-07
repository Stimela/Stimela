function PInfo=coagul_d
% PInfo=coagul_d
%   function for definition of the coagul_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description

PInfo = st_addPInfo(PInfo,'Volume',  '5',    -inf,     +inf, 'm3',   'Volume of the reactor:');
PInfo = st_addPInfo(PInfo,'G10',   '100',    -inf,     +inf, '1/s',  'G-value at 10 ^oC:');
PInfo = st_addPInfo(PInfo,'Ka',   '1e-4',    -inf,     +inf, '-',    'Floc aggregation constant, K_a:');
PInfo = st_addPInfo(PInfo,'Kb',   '8e-7',    -inf,     +inf, '-',    'Floc breakup constant, K_b:');
PInfo = st_addPInfo(PInfo,'k1',   '-0.028',    -inf,     +inf, '-',  'Non-adsorbable DOC fraction constant, K1:');
PInfo = st_addPInfo(PInfo,'k2',   '0.23',    -inf,     +inf, '-',    'Non-adsorbable DOC fraction constant, K2:');
PInfo = st_addPInfo(PInfo,'a1',   '280',    -inf,     +inf, '-',     'Max specific DOC adsorption constant, a1:');
PInfo = st_addPInfo(PInfo,'a2',   '73.9',    -inf,     +inf, '-',    'Max specific DOC adsorption constant, a2:');
PInfo = st_addPInfo(PInfo,'a3',   '4.96',    -inf,     +inf, '-',    'Max specific DOC adsorption constant, a3:');
PInfo = st_addPInfo(PInfo,'b',    '0.068',    -inf,     +inf, '-',   'DOC adsorption constant constant, b:');
%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
