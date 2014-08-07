function CO3=CE_pHCO2_CO3(pH,CO2,K1,K2,Kw,f)
% calculation of CO3 using pH and CO2
H3O = 10.^(3-pH)./f;
K1=K1./f.^2;K2=K2./f.^4;Kw=Kw./f.^2;
CO3 = K1.*CO2.*K2./H3O.^2;

