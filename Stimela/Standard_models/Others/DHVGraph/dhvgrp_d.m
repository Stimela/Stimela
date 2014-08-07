function PInfo=dhvgrp_d
% PInfo=dhvgrp_d
%   function for definition of the dhvgrp_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description
% for pulldown box:
% Name, Default, Item descr., Item valuestrings, Unit, Description, 'select'

PInfo = st_addPInfo(PInfo,'PosF',  '[2,2,2]',    0,     1, '',    'Position Graph (relative)');
PInfo = st_addPInfo(PInfo,'dt',  '2',    0,  1000, '',    'Time Scope');
PInfo = st_addPInfo(PInfo,'ss',  '1',    {'Seconds','Hour','Days'},  {'1','3600','86400'}, '', 'Time scale', 'select');
PInfo = st_addPInfo(PInfo,'ry',  '[0 10]',    0,     1, '',    'Limits');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
