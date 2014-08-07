function PInfo=sofcon_d
% PInfo=sofcon_d
%   function for definition of the sofcon_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description

PInfo = st_addPInfo(PInfo,'BPFlow',  '100',    0,    [], 'm3/h',    'Bypass flow');
PInfo = st_addPInfo(PInfo,'Soda',  '55',    0,     [], 'l/h',    'Caustic Soda flow');
PInfo = st_addPInfo(PInfo,'vPel',  '10',    0,    [], '1000 grains/sec',    'Pellet discharge speed');


%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
