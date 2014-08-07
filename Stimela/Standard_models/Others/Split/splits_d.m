function PInfo=splits_d
% PInfo=splits_d
%   function for definition of the splits_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description

PInfo = st_addPInfo(PInfo,'f1',  '1',    0,  inf, '-',    'Ratio (stream 1: stream 2) going to outgoing stream 1:');
PInfo = st_addPInfo(PInfo,'f2',  '1',    0,  inf, '-',    'Ratio (stream 1: stream 2) going to outgoing stream 2:');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
