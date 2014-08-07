function pH=CE_CO3P_pH(CO3,P,K1,K2,Kw,f,pH0)
% calculation of pH using CO3 and P
if nargin<7
 pH0=7;
end
if any(CO3>0) 
fnk=@CE_pHCO3_P;
pH = findpH(fnk,pH0,CO3,P,K1,K2,Kw,f);

else
fnk=@CE_pHP_CO3;
pH = findpH(fnk,pH0,P,CO3,K1,K2,Kw,f);

end
