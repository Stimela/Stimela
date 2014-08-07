function pH=CE_CO2HCO3_pH(CO2,HCO3,K1,K2,Kw,f)
% calculation of pH using CO2 and HCO3
K1=K1./f.^2;K2=K2./f.^4;Kw=Kw./f.^2;
H3O = K1.*CO2./HCO3;
pH = 3-log10(H3O.*f);

