function Dhv_movl(stage,P1,P2)
%  Dhv_movl(stage,P1)
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
    tel =0;
    OK = 0;
    while tel <length(h),
      tel = tel+1;
      if strcmp(get(h(tel),'type'),'line'),
        OK = 1;
        tel = length(h);
      end
    end;

    if all(vi == [0 90]) & OK,
      s2 = get(fg,'pointer');
      dwn = get(fg,'windowbuttondownfcn');
      set(fg,'pointer','arrow');

      set(fg,'windowbuttondownfcn',['Dhv_arce(2,''' s2 ''')' dwn]);
        qm = Gcq;
        set(qm,'userdata',get(qm,'label'));
        set(qm,'label',':Hatching');

    else
      Set_zoom;
    end;
  end;

elseif stage ==2 & length(zb),

  but=get(gcf,'selectiontype');
  if strcmp(but,'extend')
    local=1;
  else
    local=0;
  end

  user = get(zb,'userdata');
  if  length(user)>0,
    mot = get(fg,'windowbuttonmotionfcn');
    [dummy,mot] = strtok(mot,'%');
    set(fg,'windowbuttonmotionfcn',[' ' mot])
    set(fg,'windowbuttonupfcn','')
    delete(real(user(3)));
    set(zb,'userdata',[]);
  end;

  point = get(hg,'currentpoint');

  xpre = get(hg,'xlim');
  ypre = get(hg,'ylim');

  %zoek boven liggende en onderliggende lijn
  hl = get(hg,'children');
  tel = 0;
  dptop = inf;
  dpbot = -inf;
  tptop=0;
  tpbot=0;

  while tel <length(hl),
    tel = tel+1;
    if strcmp(get(hl(tel),'type'),'line')
      x=get(hl(tel),'xdata');
      y=get(hl(tel),'ydata');
      nx = length(x);
      dx=x(1:nx-1)-x(2:nx);
      if length(dx)==0,
        dx=NaN;
      end

      if (min(x)<point(2,1)) & (max(x) >point(2,1)) & ( all( sign(dx(:))==sign(dx(1)) ) )
        yl = table1([x(:) y(:)],point(2,1));
        dy = yl-point(2,2);

        if (dy>0 & dy<dptop)
          dptop = dy;
          tptop=tel;
        elseif (dy<0 & dy>dpbot)
          dpbot = dy;
          tpbot=tel;
        end
      end;
    end
  end

  if tptop >0
    xt = get(hl(tptop),'xdata');
    yt = get(hl(tptop),'ydata');
    htop = hl(tptop);
  else
    xt = xpre;
    yt = ypre(2)*ones(2,1);
    htop = 0;
  end

  if tpbot >0
    xb = get(hl(tpbot),'xdata');
    yb = get(hl(tpbot),'ydata');
    hbot =hl(tpbot);
  else
    xb = xpre;
    yb = ypre(1)*ones(2,1);
    hbot=0;
  end

  hp = patch([xt(:);flipud(xb(:))],[yt(:);flipud(yb(:))],[.5 .5 .5]);
  set(hp,'erasemode','xor');
  user(1)=htop;
  user(2)=hbot;
  user(3)=hp;

  set(zb,'userdata',user);
  mot = get(fg,'windowbuttonmotionfcn');
  set(fg,'windowbuttonmotionfcn',['Dhv_arce(3,' num2str(local) ')' mot])
  set(fg,'windowbuttonupfcn',['Dhv_arce(4,' num2str(local) ',''' P1 ''')'])

elseif stage ==3 & length(zb),
  local=P1;
  point = get(hg,'currentpoint');
  usrdata = get(zb,'userdata');

  if length(usrdata)>0
    %zoek boven liggende en onderliggende lijn
    hl = get(hg,'children');
    tel = 0;
    dptop = inf;
    dpbot = -inf;

    tptop=0;
    tpbot=0;
    htop=0;
    hbot=0;

    while tel <length(hl),
      tel = tel+1;

      if strcmp(get(hl(tel),'type'),'line')
        x=get(hl(tel),'xdata');
        y=get(hl(tel),'ydata');
        nx = length(x);
        dx=x(1:nx-1)-x(2:nx);
        if length(dx)==0,
          dx=NaN;
        end

        if (min(x)<point(2,1)) & (max(x) >point(2,1)) & ( all( sign(dx(:))==sign(dx(1)) ) )
          yl = table1([x(:) y(:)],point(2,1));
          dy = yl-point(2,2);

          if (dy>0 & dy<dptop)
            dptop = dy;
            tptop=tel;
          elseif (dy<0 & dy>dpbot)
            dpbot = dy;
            tpbot=tel;
          end
        end;
      end
    end

    if tptop >0
      htop = hl(tptop);
    end

    if tpbot >0
      hbot = hl(tpbot);
    end

    if (htop~=real(usrdata(1)) | hbot~=real(usrdata(2)) )
      xpre = get(hg,'xlim');
      ypre = get(hg,'ylim');

      if tptop >0
         xt = get(hl(tptop),'xdata');
         yt = get(hl(tptop),'ydata');
      else
        xt = xpre;
        yt = ypre(2)*ones(2,1);
      end

      if tpbot >0
         xb = get(hl(tpbot),'xdata');
         yb = get(hl(tpbot),'ydata');
      else
        xb = xpre;
        yb = ypre(1)*ones(2,1);
      end

      set(real(usrdata(3)),'xdata',[xt(:);flipud(xb(:))],'ydata',[yt(:);flipud(yb(:))]);
      usrdata(1)=htop;
      usrdata(2)=hbot;
      set(zb,'userdata',usrdata);
    end
  end

elseif stage ==4 & length(zb),
  local = P1;
  usrdata = get(zb,'userdata');

  if length(usrdata)>0,
    set(zb,'userdata',[]);
    delete(real(usrdata(3)))

    xpre = get(hg,'xlim');
    ypre = get(hg,'ylim');

    if real(usrdata(1))>0
      xtop = get(real(usrdata(1)),'xdata');
      ytop = get(real(usrdata(1)),'ydata');
    else
      xtop = xpre;
      ytop = ypre(2)*ones(2,1);
    end

    if real(usrdata(2))>0
      xbot = get(real(usrdata(2)),'xdata');
      ybot = get(real(usrdata(2)),'ydata');
    else
      xbot = xpre;
      ybot=ypre(1)*ones(2,1);
    end

    arcOK = 0;
    if length(xtop)==length(xbot)
      if all(xtop==xbot)
        arcOK=1;
      end
    end

    % welke kleur arcering
    col = get(gca,'color');
    if length(col) ~= 3,
      col = get(gcf,'color');
    end;

    blcol = abs([1 1 1] -col)+all((col==[.5 .5 .5]))*[.5 .5 .5];

    if arcOK
      arc = Dhv_defa(2.9);
      hh=Arceer(xtop(:)',ytop(:)',ybot(:)',arc(2),arc(1));
      set(hh,'userdata','userplot','color',blcol);
    else

      % dit stuk misschien later opnemen in arceer2
      % waarin 2 arceringen, doe maar eenvoudig:
      %  grootst gemen deler
      % eerst moeten beiden wel monotonic zijn : 1:n-1 - 2:n <0

      xtot = sort([xbot(:);xtop(:)]);
      %verwijderen dubbelen
      nt = length(xtot);
      nd = find((xtot(1:nt-1)-xtot(2:nt))==0);
      xtot(nd)=[];
      %verwijderen kleiner dan x waarden
      nd = find(xtot<min(xbot) | xtot>max(xbot) | xtot<min(xtop) | xtot>max(xtop));
      xtot(nd)=[];

      ytop = interp1(xtop,ytop,xtot);
      ybot = interp1(xbot,ybot,xtot);

      arc = Dhv_defa(2.9);
      hh=Arceer(xtot(:)',ytop(:)',ybot(:)',arc(2),arc(1));
      set(hh,'userdata','userplot','color',blcol);
    end

  end;

  set(zb,'userdata',[]);
  set(fg,'windowbuttonupfcn','');
  Set_zoom;

  qm = Gcq;
  set(qm,'label',get(qm,'userdata'));
  set(fg,'pointer',P2);

end;


