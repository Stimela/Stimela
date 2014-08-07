function pH=CE_CO2M_pH(CO2,M,K1,K2,Kw,f,pH0)
% calculation of pH using CO2 and M
if nargin<7
 pH0=7;
end
if any(CO2>0) 
fnk=@CE_pHCO2_M;
pH = findpH(fnk,pH0,CO2,M,K1,K2,Kw,f);

else
fnk=@CE_pHM_CO2;
pH = findpH(fnk,pH0,M,CO2,K1,K2,Kw,f);

end
