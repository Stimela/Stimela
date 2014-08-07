function pH=CE_HCO3P_pH(HCO3,P,K1,K2,Kw,f,pH0)
% calculation of pH using HCO3 and P
if nargin<7
 pH0=7;
end
if any(HCO3>0) 
fnk=@CE_pHHCO3_P;
pH = findpH(fnk,pH0,HCO3,P,K1,K2,Kw,f);

else
fnk=@CE_pHP_HCO3;
pH = findpH(fnk,pH0,P,HCO3,K1,K2,Kw,f);

end
