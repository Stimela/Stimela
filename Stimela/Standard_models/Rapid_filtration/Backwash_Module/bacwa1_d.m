function PInfo=bacwa1_d
% PInfo=bacwa1_d
%   function for definition of the bacwa1_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description
% for pulldown box:
% Name, Default, Item descr., Item valuestrings, Unit, Description, 'select'

PInfo = st_addPInfo(PInfo,'TL',  '24',    0,     +inf, 'h',    'Filter run time:');
PInfo = st_addPInfo(PInfo,'Tsp',  '30',    0,     +inf, 'min',    'Backwash time:');
PInfo = st_addPInfo(PInfo,'Tst',  '24',    -inf,     +inf, 'h',    'Start time for backwashing:');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
