function Ca = fnkCa(dCa,pH0,M,P,K1,K2,Kw,Ks,f0,IB)
 
M=M-2.*dCa;
P=P-dCa;
IB=IB-2.*dCa;
 
pH = CE_MP_pH(M,P,K1,K2,Kw,f0,pH0);
HCO3 = CE_pHM_HCO3(pH,M,K1,K2,Kw,f0);
CO3 = CE_pHM_CO3(pH,M,K1,K2,Kw,f0);
H3O = 10.^(3-pH)./f0;
OH = Kw./(f0.^2.*H3O);
 
IS = IB + (2*CO3+HCO3/2 +H3O/2 + OH/2);
f=CE_Activity(IS);
 
pH = CE_MP_pH(M,P,K1,K2,Kw,f,pH0);
HCO3 = CE_pHM_HCO3(pH,M,K1,K2,Kw,f);
CO3 = CE_pHM_CO3(pH,M,K1,K2,Kw,f);
H3O = 10.^(3-pH)./f;
OH = Kw./(f.^2*H3O);
 
Ca = Ks./(f.^8)./CO3 + dCa;
 
