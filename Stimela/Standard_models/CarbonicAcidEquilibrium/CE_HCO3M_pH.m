function pH=CE_HCO3M_pH(HCO3,M,K1,K2,Kw,f,pH0)
% calculation of pH using HCO3 and M
if nargin<7
 pH0=7;
end
if any(HCO3>0) 
fnk=@CE_pHHCO3_M;
pH = findpH(fnk,pH0,HCO3,M,K1,K2,Kw,f);

else
fnk=@CE_pHM_HCO3;
pH = findpH(fnk,pH0,M,HCO3,K1,K2,Kw,f);

end
