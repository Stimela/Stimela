function P=CE_pHM_P(pH,M,K1,K2,Kw,f)
% calculation of P using pH and M
H3O = 10.^(3-pH)./f;
K1=K1./f.^2;K2=K2./f.^4;Kw=Kw./f.^2;
P = -(-Kw.*K2.*K1-K1.*K2.*H3O.*M+K2.*K1.*H3O.^2-H3O.^2.*Kw+H3O.^3.*M+H3O.^4-Kw.*K1.*H3O+H3O.^3.*K1)./(2.*K2+H3O)./H3O./K1;

