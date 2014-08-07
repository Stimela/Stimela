function Dhv_clea(flag),
%  Dhv_clea(flag),
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

if flag == 1,
  set(gcf,'windowbuttondownfcn','Mdhv');
  set(gcf,'windowbuttonmotionfcn',' ');
  set(gcf,'windowbuttonupfcn',' ');

  h = get(gcf,'children');
  for tel = 1:length(h),
    OK = 0;
    Tp = get(h(tel),'type');
    if Tp(1:3)=='uim',
      Str = get(h(tel),'label');
      if strcmp(Str,'&MenuDHV'),
        OK =1;
      end
    elseif Tp(1:3)=='uic',
      user = get(h(tel),'userdata');
      if length(findstr(user(:)','Butt')),
        OK =1;
      end;
    end;
    if ~OK,
      delete(h(tel));
    end;
  end

  Dhv_zoom(0);

elseif flag ==2,
  OK = Dis_zoom;
  if OK,
    cla;
    Set_zoom
  end
elseif flag ==3,
  OK = Dis_zoom;
  if OK,
    delete(gca);
    Set_zoom
  end
elseif flag ==4,
  fg = gcf;
  menub = get(fg,'menubar');
  if strcmp(menub,'none')
    set(fg,'menubar','figure');
  else
    set(fg,'menubar','none');
  end
elseif flag ==5
  OK = Dis_zoom;
  if OK,
    set(gcf,'windowbuttondownfcn','Mdhv');
    set(gcf,'windowbuttonmotionfcn',' ');
    set(gcf,'windowbuttonupfcn',' ');
    set(gcf,'pointer','arrow');

    set(Gcq,'label',':None');
    Set_zoom;
  end

elseif flag ==6,
  pos = get(gcf,'position');
  set(gcf,'position',.9999*pos);
  drawnow
  set(gcf,'position',pos);
end

