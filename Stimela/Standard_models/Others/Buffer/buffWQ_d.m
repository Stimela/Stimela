function PInfo=buffWQ_d
% PInfo=buffWQ_d
%   function for definition of the buffWQ_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description
% for pulldown box:
% Name, Default, Item descr., Item valuestrings, Unit, Description, 'select'

PInfo = st_addPInfo(PInfo,'Surface',  '1',    1,     1, 'm2',    'Surface of the buffWQ');
PInfo = st_addPInfo(PInfo,'InitialH',  '1',    1,     1, 'm',    'Initital height of the buffWQ');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
