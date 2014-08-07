function CO3=CE_pHM_CO3(pH,M,K1,K2,Kw,f)
% calculation of CO3 using pH and M
H3O = 10.^(3-pH)./f;
K1=K1./f.^2;K2=K2./f.^4;Kw=Kw./f.^2;
CO3 = K2.*(-Kw+H3O.*M+H3O.^2)./(2.*K2+H3O)./H3O;

