function PInfo=chloCT_d
% PInfo=chloCT_d
%   function for definition of the chloCT_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description
% for pulldown box:
% Name, Default, Item descr., Item valuestrings, Unit, Description, 'select'

PInfo = st_addPInfo(PInfo,'cResidue', '0.5'	, 0, inf, 'mg/L', 'Concentration chlorine residue');
PInfo = st_addPInfo(PInfo,'vol'		, '1000', 0, inf, 'm3'	, 'Volume of contact tank');
PInfo = st_addPInfo(PInfo,'bf'		, '0.5'	, 0, 1	, '-'	, 'Baffeling factor of tank');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
