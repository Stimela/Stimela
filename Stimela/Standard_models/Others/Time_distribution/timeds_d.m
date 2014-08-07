function PInfo=timeds_d
% PInfo=timeds_d
%   function for definition of the timeds_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description

PInfo = st_addPInfo(PInfo,'th',  '0',    -inf,     +inf, 's',    'Hydraulic retention time:');
PInfo = st_addPInfo(PInfo,'NumCel',  '0',    1,     +inf, '-',    'Number of completely mixed reactors:');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
