function pH=CE_CO3M_pH(CO3,M,K1,K2,Kw,f,pH0)
% calculation of pH using CO3 and M
if nargin<7
 pH0=7;
end
if any(CO3>0) 
fnk=@CE_pHCO3_M;
pH = findpH(fnk,pH0,CO3,M,K1,K2,Kw,f);

else
fnk=@CE_pHM_CO3;
pH = findpH(fnk,pH0,M,CO3,K1,K2,Kw,f);

end
