function PInfo=ws2opc_d
% PInfo=ws2opc_d
%   function for definition of the ws2opc_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description
% for pulldown box:
% Name, Default, Item descr., Item valuestrings, Unit, Description, 'select'

PInfo = st_addPInfo(PInfo,'WSControlName',    '''WSControl''',     0, 1,    '',     'Name of Control Function','text');
PInfo = st_addPInfo(PInfo,'WSMinimalT',  '300',    0,  NaN, '',    'Minimal sample time control (seconds)');
PInfo = st_addPInfo(PInfo,'WSReplayData', '''''',  0,1,'','Replay Waterspot Data','text');
PInfo = st_addPInfo(PInfo,'WSInitState', '''''',  0,1,'','Replay Initial State','text');

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
