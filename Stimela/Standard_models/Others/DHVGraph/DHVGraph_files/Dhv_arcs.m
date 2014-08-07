function [x,y] = Arceer(l1,l2),
% levert a en b van lijn ytop
% voor de plekken waar h = 1;
% h(1) kan nooit 1 zijn !!


  % snijden  y = a1x+b1 en y = a2x+b2
  %          x = (b1-b2)/(a2-a1);
  % of als dx = 0  -> a=inf
  % vergelijking x = b2
  % snijden  y =a1.b2+b1

  % begin snijpunten
  % 3 lijnen

  b1 = l1(:,2);
  b2 = l2(:,2);

  a1 = l1(:,1);
  a2 = l2(:,1);


  x = (b2-b1)./(a1-a2);
  y = a2.*x + b2;

