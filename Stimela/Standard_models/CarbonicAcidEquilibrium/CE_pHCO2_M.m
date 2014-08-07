function M=CE_pHCO2_M(pH,CO2,K1,K2,Kw,f)
% calculation of M using pH and CO2
H3O = 10.^(3-pH)./f;
K1=K1./f.^2;K2=K2./f.^4;Kw=Kw./f.^2;
M = -(-2.*K1.*CO2.*K2-K1.*CO2.*H3O-Kw.*H3O+H3O.^3)./H3O.^2;

