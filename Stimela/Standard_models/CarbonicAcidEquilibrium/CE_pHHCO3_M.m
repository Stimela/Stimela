function M=CE_pHHCO3_M(pH,HCO3,K1,K2,Kw,f)
% calculation of M using pH and HCO3
H3O = 10.^(3-pH)./f;
K1=K1./f.^2;K2=K2./f.^4;Kw=Kw./f.^2;
M = -(-2.*K2.*HCO3-HCO3.*H3O-Kw+H3O.^2)./H3O;

