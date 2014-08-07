function PInfo = chloro_d
% PInfo=chloro_d
%   function for definition of the chloro_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description
% for pulldown box:
% Name, Default, Item descr., Item valuestrings, Unit, Description, 'select'

PInfo = st_addPInfo(PInfo,'Vol', '1000', 0, inf, 'm3', 'Volume of contact tank');
PInfo = st_addPInfo(PInfo,'BF' , '0.5' , 0, 1  , '-' , 'Baffling factor');
% PInfo = st_addPInfo(PInfo,'kc1',     '0.01', -inf,   inf,    'min-1','Chlorine fast decay factor');
% PInfo = st_addPInfo(PInfo,'kc2',     '0.001', -inf,   inf,    'min-1','Chlorine slow decay factor');
% PInfo = st_addPInfo(PInfo,'A',     '0.6', 0,   1,    '-','');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
