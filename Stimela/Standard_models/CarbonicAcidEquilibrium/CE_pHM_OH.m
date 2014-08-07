function OH=CE_pHM_OH(pH,M,K1,K2,Kw,f)
% calculation of OH using pH and M
H3O = 10.^(3-pH)./f;
K1=K1./f.^2;K2=K2./f.^4;Kw=Kw./f.^2;
OH = Kw./H3O;

