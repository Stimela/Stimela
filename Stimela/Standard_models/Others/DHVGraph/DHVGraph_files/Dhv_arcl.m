function l = arclijn(t,y,h)
% levert a en b van lijn y
% voor de plekken waar h = 1;
% h(1) kan nooit 1 zijn !!
% l = [a b];


  % lijn door (x1,y1) en (x2,y2)
  % y = a*x +b
  % vergelijking a = (y2-y1)/(x2-x1)
  %              b = y1 -a*x1
  % als a = inf -> x = b;

  % begin snijpunten
  % 3 lijnen

  hp = find(h==1);

  dx = (t(hp)-t(hp-1));
  a = (y(hp)-y(hp-1))./dx;
  b = y(hp-1)-a.*t(hp-1);

  l = [a(:) b(:)];


