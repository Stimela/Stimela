function [sys,x0,mstr,ts] = PIDHV(t,x,u,flag,P,I,D,Lims,x0)
% u(1) = u
% u(2) = uset

% © Kim van Schagen, 1-Aug-95


if abs(flag) == 1,
  e = u(1)-u(2);
  sys = P/I*e;
  y = P*e + x(1);
  if  y <= Lims(1) & sys<0,
      sys = 0;
  elseif y >= Lims(2) & sys>0,
      sys = 0;
  end;

elseif flag == 3,
  e = u(1)-u(2);
  sys = P*e + x(1);
  if  sys < Lims(1),
      sys = Lims(1);
  elseif sys > Lims(2),
      sys = Lims(2);
  end;

elseif flag == 0,
  sys = INITSIZ([1,0,1,2,0,1]);
  x0 = [x0];
  str = '';
  ts = [-1,0];
end;



