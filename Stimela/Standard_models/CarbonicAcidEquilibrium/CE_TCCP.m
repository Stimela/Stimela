function dCa = CE_TCCP(Ca,M,P,K1,K2,Kw,Ks,IS)
 
f0 = CE_Activity(IS);
pH0 = CE_MP_pH(M,P,K1,K2,Kw,f0);

HCO3 = CE_pHM_HCO3(pH0,M,K1,K2,Kw,f0);
CO3 = CE_pHM_CO3(pH0,M,K1,K2,Kw,f0);
H3O = 10.^(3-pH0)./f0;
OH = Kw./(f0.^2.*H3O);
 
IB = IS - (2*CO3+HCO3/2 +H3O/2 + OH/2);

fnk=@fnkCa;
dCa = finddCa(fnk,0,pH0,Ca,M,P,K1,K2,Kw,Ks,f0,IB);
 
