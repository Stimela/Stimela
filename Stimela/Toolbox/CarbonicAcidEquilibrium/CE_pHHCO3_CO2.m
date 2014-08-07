function CO2=CE_pHHCO3_CO2(pH,HCO3,K1,K2,Kw,f)
% calculation of CO2 using pH and HCO3
H3O = 10.^(3-pH)./f;
K1=K1./f.^2;K2=K2./f.^4;Kw=Kw./f.^2;
CO2 = HCO3.*H3O./K1;

