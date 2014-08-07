function Dhv_slin(stage,P1,P2)
%  Dhv_slin(stage,P1)
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95
zb = Gcz;
hg = gca;
fg = gcf;

if stage ==1 & length(zb),
  OK = Dis_zoom;
  if OK,
    vi = get(hg,'view');
    h = get(hg,'children');
    if all(vi == [0 90]),
      set(fg,'pointer','crosshair');
      set(fg,'windowbuttondownfcn',['Dhv_slin(2)']);
      set(fg,'windowbuttonmotionfcn','');
      set(fg,'windowbuttonupfcn','');

      set(Gcq,'label',':Add Arrow');
    else
      Set_zoom;
    end;
  end;
elseif stage ==2 & length(zb),

  but=get(fg,'selectiontype');
  if strcmp(but,'extend')
    ortho=1;
  else
    ortho=0;
  end

  user = get(zb,'userdata');
  if length(user)>0,
    delete(real(user(3)));
    set(zb,'userdata',[]);
  end;

  if nargin==1,
    point = get(hg,'currentpoint');
  else
    point(2,1:2) = P1;
  end

  xpre = get(hg,'xlim');
  ypre = get(hg,'ylim');
  if point(2,1)<xpre(1), point(2,1) = xpre(1); end;
  if point(2,1)>xpre(2), point(2,1) = xpre(2); end;
  if point(2,2)<ypre(1), point(2,2) = ypre(1); end;
  if point(2,2)>ypre(2), point(2,2) = ypre(2); end;

  h = line('xdata',[point(2,1) point(2,1)], ...
           'ydata',[point(2,2) point(2,2)], ...
           'color',[.5 .5 .5],'erasemode','xor');
  user(1:3) = [point(2,1:2) h];
  set(zb,'userdata',user);
  mot = get(fg,'windowbuttonmotionfcn');
  set(fg,'windowbuttonmotionfcn',['Dhv_slin(3,' num2str(ortho) ')'])
  set(fg,'windowbuttonupfcn',['Dhv_slin(4,' num2str(ortho) ')'])

elseif stage ==3 & length(zb),
  ortho=P1;
  point = get(hg,'currentpoint');
  usrdata = get(zb,'userdata');
  xpre = get(hg,'xlim');
  ypre = get(hg,'ylim');
  if length(usrdata)>0,
    if point(2,1)<xpre(1), point(2,1)=xpre(1);end;
    if point(2,1)>xpre(2), point(2,1)=xpre(2);end;
    if point(2,2)<ypre(1), point(2,2)=ypre(1);end;
    if point(2,2)>ypre(2), point(2,2)=ypre(2);end;

    xd = [real(usrdata(1)) point(2,1)];
    yd = [real(usrdata(2)) point(2,2)];

    if ortho==1
      dx = real(usrdata(1))-point(2,1);
      dy = real(usrdata(2))-point(2,2);
      if abs(dx/(xpre(2)-xpre(1))) > abs(dy/(ypre(2)-ypre(1)))
        yd=[real(usrdata(2)) real(usrdata(2))];
      else
        xd=[real(usrdata(1)) real(usrdata(1))];
      end
    end

    set(real(usrdata(3)),'Xdata',xd,'Ydata',yd);
  end

elseif stage ==4 & length(zb),
  ortho = P1;

  if nargin ==2,
    point = get(hg,'currentpoint');
  else
    point(2,1:2) =  P2;
  end

  usrdata = get(zb,'userdata');
  xpre = get(hg,'xlim');
  ypre = get(hg,'ylim');

  if length(usrdata)>0,

    if point(2,1)<xpre(1), point(2,1)=xpre(1);end;
    if point(2,1)>xpre(2), point(2,1)=xpre(2);end;
    if point(2,2)<ypre(1), point(2,2)=ypre(1);end;
    if point(2,2)>ypre(2), point(2,2)=ypre(2);end;

    x = [real(usrdata(1)) point(2,1)];
    y = [real(usrdata(2)) point(2,2)];

    OKx=1;
    OKy=1;
    if ortho==1
      dx = real(usrdata(1))-point(2,1);
      dy = real(usrdata(2))-point(2,2);
      if abs(dx/(xpre(2)-xpre(1))) > abs(dy/(ypre(2)-ypre(1)))
        OKy=0;
        y = [real(usrdata(2)) real(usrdata(2))];
        if (point(2,1) == real(usrdata(1)))
          OKx=0;
        end
      else
        OKx=0;
        x = [real(usrdata(1)) real(usrdata(1))];
        if (point(2,2) == real(usrdata(2)))
          OKy=0;
        end
      end
    end
    if (point(2,1) == real(usrdata(1))) & (point(2,2) == real(usrdata(2))),
      OKx=0;
      OKy=0;
    end

    if OKx==0 & OKy==0
      delete(real(usrdata(3)));
    else
      ua = get(hg,'units');
      set(hg,'units','pixels');
      pa = get(hg,'position');
      set(hg,'units',ua);

      ld = Dhv_defa(2.6);

      xp = ld(2)/pa(3)*(xpre(2)-xpre(1));
      yp = ld(2)/pa(4) * (ypre(2)-ypre(1));

      dy = (y(2)-y(1))/yp;%(ypre(2)-ypre(1));
      dx = (x(2)-x(1))/xp;%(xpre(2)-xpre(1));
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

      set(real(usrdata(3)),'xdata',[x x(2)+x1 x(2)+x2 x(2)],...
              'ydata',[y y(2)+y1 y(2)+y2 y(2)],'zdata',.5*ones(5,1),...
              'color',[1 1 1],'erasemode','normal','userdata','userplot',...
              'linewidth',ld(1));
    end;

  end;

  set(zb,'userdata',[]);
  set(fg,'windowbuttonmotionfcn','');
  set(fg,'windowbuttonupfcn','');

end;


