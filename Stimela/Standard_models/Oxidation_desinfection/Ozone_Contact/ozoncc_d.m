function PInfo=ozoncc_d
% PInfo=ozoncc_d
%   function for definition of the ozoncc_d parameters
%
% Stimela, 2004

% © Kim van Schagen,

PInfo=[];

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make PInfo array with wanted parameters.
% Name, Default, Lower bound, Upper bound, Unit, Description

PInfo = st_addPInfo(PInfo,'Hreact',      '5.5',       0,                                   1,         'm',                           'Heigth of reactor');
PInfo = st_addPInfo(PInfo,'Areact',      '0.028353',  0,                                   1,         'm2',                          'Surface of reactor');
PInfo = st_addPInfo(PInfo,'kUV_Sel',     '1',                                                        {'kUV manual','kUV model'},          {'1','0'}, '-',                           'kUV selection for manual or model input','select');
PInfo = st_addPInfo(PInfo,'kUV',         '0.5',                                                      0,                                   1000,      '1/s',                         'UVA254 decay rate, kUVA');
PInfo = st_addPInfo(PInfo,'Y',           '0.2',                                                      0,                                   1000,      '(mg/l)/(1/m)',                'Yield factor for ozone use per UVA decrease, Y');
PInfo = st_addPInfo(PInfo,'KafbO3_Sel',  '1',                                                        {'kO3 manual','kO3 model'},          {'1','0'}, '-',                           'kO3 selection for manual or model input','select');
PInfo = st_addPInfo(PInfo,'KafbO3',      '0.008',                                                    0,                                   1000,      '1/s',                         'Slow ozone decay rate, kO3');
PInfo = st_addPInfo(PInfo,'ceUVA254_Sel','1',                                                        {'UVAo manual','UVAo model'},        {'1','0'}, '-',                           'UVAo selection for manual or model input','select');
PInfo = st_addPInfo(PInfo,'ceUV254',     '3.0',                                                      0,                                   1000,      '1/m',                         'Stable UVA (254 nm) after ozonation, UVAo');
PInfo = st_addPInfo(PInfo,'F_BrO3init',  '2.5',                                                      0,                                   1000,      '(ug-BrO3/l)/(mg-O3/l)',       'FBrO3,ini constant for initial bromate formation (F*ozone dosage)');
PInfo = st_addPInfo(PInfo,'kCt_BrO3_Sel','1',                                                        {'kBrO3 manual','kBrO3 model'},      {'1','0'}, '-',                           'kBrO3 selection for manual or model input','select');
PInfo = st_addPInfo(PInfo,'kCt_BrO3',    '3.0',                                                      0,                                   1000,      '(ug-BrO3/l)/((mg-O3/l)*min)', 'kBrO3 bromate formation rate constant');
PInfo = st_addPInfo(PInfo,'F_AOC_Sel',   '1',                                                        {'FAOC manual','FAOC model'},        {'1','0'}, '-',                           'FACO selection for manual or model input','select');
PInfo = st_addPInfo(PInfo,'F_AOC',       '50',                                                       0,                                   200,       '(ug-C/l)/(mg-O3/l)',          'FAOC constant for AOC formation (F*ozone dosage)');
PInfo = st_addPInfo(PInfo,'kEc_Sel',     '1',                                                        {'k E.coli manual','k E.coli model'},{'1','0'}, '-',                           'k for E.coli selection for manual or model input','select');
PInfo = st_addPInfo(PInfo,'kEc',         '300',                                                      0,                                   1000,      '(l/mg-O3)*1/min',             'k inactivation rate for E.coli');
PInfo = st_addPInfo(PInfo,'Ct_lagEc',    '0.01',                                                     0,                                   1000,      '(mg-O3/l)*min',               'Ctlag for E.coli');
PInfo = st_addPInfo(PInfo,'NumCel',      '4',        0,                                   1,         '-',                           'Number of CSTRs between sampling points');


%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
