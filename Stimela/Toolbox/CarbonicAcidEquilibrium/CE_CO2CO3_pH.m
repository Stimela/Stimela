function pH=CE_CO2CO3_pH(CO2,CO3,K1,K2,Kw,f)
% calculation of pH using CO2 and CO3
K1=K1./f.^2;K2=K2./f.^4;Kw=Kw./f.^2;
H3O = 1./CO3.*(K1.*CO2.*K2.*CO3).^(1./2);
pH = 3-log10(H3O.*f);

