function PInfo=regena_d
% PInfo=regena_d
%   function for definition of the regena_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description

PInfo = st_addPInfo(PInfo,'TL',  '300',    -inf,     +inf, 'days',    'Filter run time:');
PInfo = st_addPInfo(PInfo,'Tsp',  '1',    -inf,     +inf, 'days',    'Regeneration time:');
PInfo = st_addPInfo(PInfo,'Tst',  '0',    -inf,     +inf, 'days',    'Start time for regenerating:');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
