function CO2=CE_pHM_CO2(pH,M,K1,K2,Kw,f)
% calculation of CO2 using pH and M
H3O = 10.^(3-pH)./f;
K1=K1./f.^2;K2=K2./f.^4;Kw=Kw./f.^2;
CO2 = (-Kw+H3O.*M+H3O.^2)./(2.*K2+H3O).*H3O./K1;

