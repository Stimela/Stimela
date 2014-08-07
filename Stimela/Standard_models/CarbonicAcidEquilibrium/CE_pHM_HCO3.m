function HCO3=CE_pHM_HCO3(pH,M,K1,K2,Kw,f)
% calculation of HCO3 using pH and M
H3O = 10.^(3-pH)./f;
K1=K1./f.^2;K2=K2./f.^4;Kw=Kw./f.^2;
HCO3 = (-Kw+H3O.*M+H3O.^2)./(2.*K2+H3O);

