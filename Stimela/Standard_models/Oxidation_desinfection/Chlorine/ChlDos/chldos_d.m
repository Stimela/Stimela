function PInfo = chldos_d
% PInfo=chldos_d
%   function for definition of the chldos_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description
% for pulldown box:
% Name, Default, Item descr., Item valuestrings, Unit, Description, 'select'

PInfo = st_addPInfo(PInfo, 'clDos', '2000', 0, inf, 'g/h', 'Chlorine dosage');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
