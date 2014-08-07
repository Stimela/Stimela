function HCO3=CE_pHP_HCO3(pH,P,K1,K2,Kw,f)
% calculation of HCO3 using pH and P
H3O = 10.^(3-pH)./f;
K1=K1./f.^2;K2=K2./f.^4;Kw=Kw./f.^2;
HCO3 = -K1.*(P.*H3O-Kw+H3O.^2)./(-K2.*K1+H3O.^2);

