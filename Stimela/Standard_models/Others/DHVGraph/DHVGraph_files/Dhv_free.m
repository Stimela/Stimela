function Dhv_free(stage,P1)
%  Dhv_free(stage,P1)
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
      set(fg,'pointer','arrow');
      set(fg,'windowbuttondownfcn',['Dhv_free(2)']);
      set(fg,'windowbuttonmotionfcn','')
      set(fg,'windowbuttonupfcn','')

      set(Gcq,'label',':Add Free Line');
    else
      Set_zoom;
    end;
  end;
elseif stage ==2 & length(zb),
  user = get(zb,'userdata');
  if length(user)>4,
%    mot = get(fg,'windowbuttonmotionfcn');
%    [dummy,mot] = strtok(mot,'%');
%    set(fg,'windowbuttonmotionfcn',[' ' mot])
%    set(fg,'windowbuttonupfcn','')
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

  h = line('xdata',[point(2,1)], ...
           'ydata',[point(2,2)], ...
           'color',[.5 .5 .5],'erasemode','xor');
  user(1:3) = [point(2,1:2) h];
  set(zb,'userdata',user);
  mot = get(fg,'windowbuttonmotionfcn');
  set(fg,'windowbuttonmotionfcn',['Dhv_free(3)'])
  set(fg,'windowbuttonupfcn',['Dhv_free(4)'])

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
    xdat = get(real(usrdata(3)),'Xdata');
    ydat = get(real(usrdata(3)),'Ydata');
    set(real(usrdata(3)),'Xdata', ...
     [xdat point(2,1)], ...
                  'Ydata', ...
     [ydat point(2,2)]);
  end
elseif stage ==4 & length(zb),
  point = get(hg,'currentpoint');
  usrdata = get(zb,'userdata');
  xpre = get(hg,'xlim');
  ypre = get(hg,'ylim');
  xdat = get(real(usrdata(3)),'Xdata');
  ydat = get(real(usrdata(3)),'Ydata');

  if length(usrdata)>0,

    if point(2,1)<xpre(1), point(2,1)=xpre(1);end;
    if point(2,1)>xpre(2), point(2,1)=xpre(2);end;
    if point(2,2)<ypre(1), point(2,2)=ypre(1);end;
    if point(2,2)>ypre(2), point(2,2)=ypre(2);end;

    if all(point(2,1) == xdat) & all(point(2,2) == ydat),
      delete(real(usrdata(3)))
    else

      x = [xdat point(2,1)];
      y = [ydat point(2,2)];

      set(real(usrdata(3)),'xdata',x,...
              'ydata',y,'zdata',.5*ones(length(x),1),...
              'color',[1 1 1],'erasemode','normal','userdata','userplot',...
              'linewidth',Dhv_defa(2.7));

    end;

  end;

  set(zb,'userdata',[]);
  set(fg,'windowbuttonmotionfcn','');
  set(fg,'windowbuttonupfcn','');
end;


