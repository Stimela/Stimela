function M=CE_pHCO3_M(pH,CO3,K1,K2,Kw,f)
% calculation of M using pH and CO3
H3O = 10.^(3-pH)./f;
K1=K1./f.^2;K2=K2./f.^4;Kw=Kw./f.^2;
M = (2.*CO3.*K2.*H3O+CO3.*H3O.^2+Kw.*K2-K2.*H3O.^2)./K2./H3O;

