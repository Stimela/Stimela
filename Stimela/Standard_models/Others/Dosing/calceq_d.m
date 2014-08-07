function PInfo=calceq_d
% PInfo=calceq_d
%   function for definition of the calceq_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description

 
PInfo = st_addPInfo(PInfo,'ParEq',  '1',  ...
    ...
    {'pH and HCO3', 'pH and M', 'pH and P', 'pH and CO2', 'M and P'}, ...
    {'1','2','3','4','5'}, ...
    '', 'Parameters to determine carbonic acid equilibrium', 'select');
PInfo = st_addPInfo(PInfo,'ParIon', '2', ...
    {'Ion Strength','EGV'}, ...
    {'1','2'}, ...
    '', 'Parameter to determine Ion strength', 'select'); 
PInfo = st_addPInfo(PInfo,'TACCacc',  '0',    0,     [], 'mmol/l',    'Accepted oversaturated calcium');
%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
