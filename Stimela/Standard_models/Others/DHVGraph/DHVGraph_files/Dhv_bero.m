function on = Dhv_bero(Ps,poin)
%  on = Dhv_bero(Ps,poin)
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95 

on = 0;
dp = .05*Ps(3);
Lmx(1) = Ps(1)-dp;
Lmx(2) = Ps(1)+dp;
Lmx(3) = Ps(1)+Ps(3)-dp;
Lmx(4) = Ps(1)+Ps(3)+dp;

dp = .05*Ps(4);
Lmy(1) = Ps(2)-dp;
Lmy(2) = Ps(2)+dp;
Lmy(3) = Ps(2)+Ps(4)-dp;
Lmy(4) = Ps(2)+Ps(4)+dp;


if any(poin>[Lmx(4) Lmy(4)])|any(poin<[Lmx(1) Lmy(1)])
  on = 0;
elseif all(poin>[Lmx(2) Lmy(2)])&all(poin<[Lmx(3) Lmy(3)])
  on = 1;
elseif poin(1) >Lmx(3),
   on = 2;
   if poin(2) >Lmy(3),
     on = 4;
   elseif poin(2) < Lmy(2),
     on = 5;
   end;
elseif poin(1) <Lmx(2),
   on = -2;
   if poin(2) >Lmy(3),
     on = -5;
   elseif poin(2) < Lmy(2),
     on = -4;
   end;
elseif poin(2) <Lmy(2),
   on = -3;
elseif poin(2) > Lmy(3),
   on = 3;
end;



