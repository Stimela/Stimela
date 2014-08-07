function M=CE_pHP_M(pH,P,K1,K2,Kw,f)
% calculation of M using pH and P
H3O = 10.^(3-pH)./f;
K1=K1./f.^2;K2=K2./f.^4;Kw=Kw./f.^2;
M = -(2.*P.*H3O.*K2.*K1-Kw.*K2.*K1+K2.*K1.*H3O.^2+K1.*H3O.^2.*P-Kw.*K1.*H3O+H3O.^3.*K1-H3O.^2.*Kw+H3O.^4)./(-K2.*K1+H3O.^2)./H3O;

