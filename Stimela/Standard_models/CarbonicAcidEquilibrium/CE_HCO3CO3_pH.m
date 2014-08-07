function pH=CE_HCO3CO3_pH(HCO3,CO3,K1,K2,Kw,f)
% calculation of pH using HCO3 and CO3
K1=K1./f.^2;K2=K2./f.^4;Kw=Kw./f.^2;
H3O = K2.*HCO3./CO3;
pH = 3-log10(H3O.*f);

