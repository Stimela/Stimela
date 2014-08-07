function pH=CE_CO2P_pH(CO2,P,K1,K2,Kw,f,pH0)
% calculation of pH using CO2 and P
if nargin<7
 pH0=7;
end
if any(CO2>0) 
fnk=@CE_pHCO2_P;
pH = findpH(fnk,pH0,CO2,P,K1,K2,Kw,f);

else
fnk=@CE_pHP_CO2;
pH = findpH(fnk,pH0,P,CO2,K1,K2,Kw,f);

end
