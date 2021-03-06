function P=CE_pHCO3_P(pH,CO3,K1,K2,Kw,f)
% calculation of P using pH and CO3
H3O = 10.^(3-pH)./f;
K1=K1./f.^2;K2=K2./f.^4;Kw=Kw./f.^2;
P = -(-CO3.*K1.*K2.*H3O+CO3.*H3O.^3-Kw.*K2.*K1+K2.*K1.*H3O.^2)./K1./K2./H3O;

