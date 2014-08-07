function Dhv_dell(stage,P1)
%  Dhv_dell(stage,P1)
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
      set(fg,'pointer','cross');
      set(fg,'windowbuttondownfcn',['Dhv_dell(2,''' s2 ''')' dwn]);
        qm = Gcq;
        set(qm,'userdata',get(qm,'label'));
        set(qm,'label',':Erase Line');
    else
      Set_zoom;
    end;
  end;
elseif stage ==2 & length(zb),
  user = get(zb,'userdata');
  if length(user)>0,
    mot = get(fg,'windowbuttonmotionfcn');
    [dummy,mot] = strtok(mot,'%');
    set(fg,'windowbuttonmotionfcn',[' ' mot])
    set(fg,'windowbuttonupfcn','')
    delete(real(user(3)));
%    user = 'Menu';
    set(zb,'userdata',[]);
  end;

  point = get(hg,'currentpoint');

  xpre = get(hg,'xlim');
  ypre = get(hg,'ylim');
  if point(2,1)<xpre(1), point(2,1) = xpre(1); end;
  if point(2,1)>xpre(2), point(2,1) = xpre(2); end;
  if point(2,2)<ypre(1), point(2,2) = ypre(1); end;
  if point(2,2)>ypre(2), point(2,2) = ypre(2); end;

  h = line('xdata',[point(2,1) point(2,1) point(2,1) point(2,1) point(2,1)], ...
           'ydata',[point(2,2) point(2,2) point(2,2) point(2,2) point(2,2)], ...
           'color',[.5 .5 .5],'erasemode','xor');
  user(1:3) = [point(2,1:2) h];
  set(zb,'userdata',user);
  mot = get(fg,'windowbuttonmotionfcn');
  set(fg,'windowbuttonmotionfcn',['Dhv_dell(3)' mot])
  set(fg,'windowbuttonupfcn',['Dhv_dell(4,''' P1 ''')'])

elseif stage ==3 & length(zb),
  point = get(hg,'currentpoint');
  usrdata = get(zb,'userdata');
  xpre = get(hg,'xlim');
  ypre = get(hg,'ylim');
  if length(usrdata)>0,
    if point(2,1)<xpre(1), point(2,1)=xpre(1);end;
    if point(2,1)>xpre(2), point(2,1)=xpre(2);end;
    if point(2,2)<ypre(1), point(2,2)=ypre(1);end;
    if point(2,2)>ypre(2), point(2,2)=ypre(2);end;
    set(real(usrdata(3)),'Xdata', ...
     [real(usrdata(1)) point(2,1) point(2,1) real(usrdata(1)) real(usrdata(1))], ...
                  'Ydata', ...
     [real(usrdata(2)) real(usrdata(2)) point(2,2) point(2,2) real(usrdata(2))]);
  end
elseif stage ==4 & length(zb),
  point = get(hg,'currentpoint');
  usrdata = get(zb,'userdata');
  xpre = get(hg,'xlim');
  ypre = get(hg,'ylim');

  if length(usrdata)>0,

    if point(2,1)<xpre(1), point(2,1)=xpre(1);end;
    if point(2,1)>xpre(2), point(2,1)=xpre(2);end;
    if point(2,2)<ypre(1), point(2,2)=ypre(1);end;
    if point(2,2)>ypre(2), point(2,2)=ypre(2);end;

    if (point(2,1) == real(usrdata(1))) | (point(2,2) == real(usrdata(2))),
      set(zb,'userdata',[]);
      delete(real(usrdata(3)))
    else
      limx = sort([real(usrdata(1)) point(2,1)]);
      limy = sort([real(usrdata(2)) point(2,2)]);
      set(zb,'userdata',[]);
      delete(real(usrdata(3)))
%
      teller=0;
      h = get(hg,'children');
      for tel = 1:length(h),
        if strcmp(get(h(tel),'type'),'line'),
          x = get(h(tel),'xdata');
          y = get(h(tel),'ydata');
          plek = find(x>=limx(1) & x<=limx(2));
          if (any(y(plek)<=limy(2) & y(plek)>=limy(1))),
            delete(h(tel));
          end;
        end;
      end; %for loop
    end;

  end;

  set(fg,'windowbuttonupfcn','');
  Set_zoom;

  qm = Gcq;
  set(qm,'label',get(qm,'userdata'));
  set(fg,'pointer',P1);

end;


