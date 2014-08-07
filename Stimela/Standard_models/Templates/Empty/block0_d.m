function PInfo=block0_d
% PInfo=block0_d
%   function for definition of the block0_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description
% for pulldown box:
% Name, Default, Item descr., Item valuestrings, Unit, Description, 'select'

PInfo = st_addPInfo(PInfo,'Ex1',  '0',    0,     1, 'Unit',    'Parameter example 1');
PInfo = st_addPInfo(PInfo,'Ex2',  '1',    0,  1000, 'Unit',    'Parameter example 2');
PInfo = st_addPInfo(PInfo,'Ex3',  '1',    {'Direct1','Direct2'},  {'-1','1'}, 'Unit', 'Parameter example 3: pull-down box', 'select');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
