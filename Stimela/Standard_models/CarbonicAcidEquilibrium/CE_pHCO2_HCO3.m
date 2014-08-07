function HCO3=CE_pHCO2_HCO3(pH,CO2,K1,K2,Kw,f)
% calculation of HCO3 using pH and CO2
H3O = 10.^(3-pH)./f;
K1=K1./f.^2;K2=K2./f.^4;Kw=Kw./f.^2;
HCO3 = K1.*CO2./H3O;

