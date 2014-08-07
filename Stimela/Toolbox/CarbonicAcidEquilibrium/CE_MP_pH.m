function pH=CE_MP_pH(M,P,K1,K2,Kw,f,pH0)
% calculation of pH using M and P
if nargin<7
 pH0=7;
end
if any(M>0) 
fnk=@CE_pHM_P;
pH = findpH(fnk,pH0,M,P,K1,K2,Kw,f);

else
fnk=@CE_pHP_M;
pH = findpH(fnk,pH0,P,M,K1,K2,Kw,f);

end
% standard functions for CarbonEw
