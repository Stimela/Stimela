function Dhv_pupd(flag),
%
%  Dhv_pupd(flag),
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

if nargin == 0, % alleen recalc, anders ook update
  flag =1;
end

ga = gca;
ha = get(ga,'children');
xpre = get(ga,'xlim');
ypre = get(ga,'ylim');
ua = get(ga,'units');
set(ga,'units','pixels');
pa = get(ga,'position');
set(ga,'units',ua);

for tela = 1:length(ha);
  if strcmp(get(ha(tela),'userdata'),'userplot'),
    x = get(ha(tela),'xdata');
    if length(x)==5,
      y = get(ha(tela),'ydata');
      ld = Dhv_defa(2.6);
      xp = ld(2)/pa(3)*(xpre(2)-xpre(1));
      yp = ld(2)/pa(4) * (ypre(2)-ypre(1));
      x = x(1:2);
      y = y(1:2);
      dy = (y(2)-y(1))/yp;
      dx = (x(2)-x(1))/xp;
      if dx == 0 & dy>=0,
        alpha = .5*pi;
      elseif dx == 0 & dy<0,
        alpha = 1.5*pi;
      elseif dx>0,
        alpha = atan(dy/dx);
      else
        alpha = pi+atan(dy/dx);
      end
      p1 = alpha+((180-ld(3))/180)*pi;
      p2 = alpha+((180+ld(3))/180)*pi;
      x1 = xp*cos(p1);
      y1 = yp*sin(p1);
      x2 = xp*cos(p2);
      y2 = yp*sin(p2);
      set(ha(tela),'xdata',[x x(2)+x1 x(2)+x2 x(2)],...
                'ydata',[y y(2)+y1 y(2)+y2 y(2)],'linewidth',ld(1));

    elseif length(x) == 1 & flag ==2, % userplot dot
      set(ha(tela),'markersize',Dhv_defa(2.5));
    elseif flag == 2,
      set(ha(tela),'linewidth',Dhv_defa(2.7));
    end
  end
end

