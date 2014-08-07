function Dhv_line(stage,P1,P2)
%  Dhv_line(stage,P1)
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
      set(fg,'windowbuttondownfcn','Dhv_line(2)');
      set(fg,'windowbuttonmotionfcn','');
      set(fg,'windowbuttonupfcn','');

      set(Gcq,'label',':Add Line');
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

  point = get(hg,'currentpoint');

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
  set(fg,'windowbuttonmotionfcn',['Dhv_line(3,' num2str(ortho) ')'])
  set(fg,'windowbuttonupfcn',['Dhv_line(4,' num2str(ortho) ')'])

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

      set(real(usrdata(3)),'Zdata',.5*ones(2,1),...
              'color',[1 1 1],'erasemode','normal','userdata','userplot',...
              'linewidth',Dhv_defa(2.7));
  end;

  set(zb,'userdata',[]);
  set(fg,'windowbuttonmotionfcn','');
  set(fg,'windowbuttonupfcn','');

end;


