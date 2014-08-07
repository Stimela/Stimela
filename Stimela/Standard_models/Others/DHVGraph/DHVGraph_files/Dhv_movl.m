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
%      s2 = get(fg,'pointer');
%      dwn = get(fg,'windowbuttondownfcn');
      set(fg,'pointer','arrow');

%      set(fg,'windowbuttondownfcn',['Dhv_movl(2,''' s2 ''')' dwn]);
      set(fg,'windowbuttondownfcn',['Dhv_movl(2)']);
      set(fg,'windowbuttonmotionfcn','');
      set(fg,'windowbuttonupfcn','');

      set(Gcq,'label',':Move Line');

    else
      Set_zoom;
    end;
  end;

elseif stage ==2 & length(zb),

      but=get(gcf,'selectiontype');
      if strcmp(but,'extend')
        ortho=1;
      else
        ortho=0;
      end

      user = get(zb,'userdata');
      if  length(user)>0,
%       mot = get(fg,'windowbuttonmotionfcn');
%        [dummy,mot] = strtok(mot,'%');
%        set(fg,'windowbuttonmotionfcn',[' ' mot])
%        set(fg,'windowbuttonupfcn','')
        delete(real(user(3)));
%        user = 'Menu';
        set(zb,'userdata',[]);
      end;

      point = get(hg,'currentpoint');

      xpre = get(hg,'xlim');
      ypre = get(hg,'ylim');
      if point(2,1)<xpre(1), point(2,1) = xpre(1); end;
      if point(2,1)>xpre(2), point(2,1) = xpre(2); end;
      if point(2,2)<ypre(1), point(2,2) = ypre(1); end;
      if point(2,2)>ypre(2), point(2,2) = ypre(2); end;

      %zoek dichtsbijzijnde lijn
      hl = get(hg,'children');
      tel =0;
      dp=inf;
      tp=1;
      while tel <length(hl),
        tel = tel+1;
        if strcmp(get(hl(tel),'type'),'line')
          x=get(hl(tel),'xdata');
          y=get(hl(tel),'ydata');

          dx = x-point(2,1);
          dy = y-point(2,2);
          dv = min(dx.^2+dy.^2);
          if(dp>dv)
            dp = dv;
            tp=tel;
          end
        end
      end;


      x=get(hl(tp),'xdata');
      y=get(hl(tp),'ydata');
      h = line('xdata',x, ...
              'ydata',y, ...
              'color',[.5 .5 .5],'erasemode','xor',...
               'userdata',[x(:) y(:)]);
      user(1:4) = [point(2,1:2) h hl(tp)];
      set(zb,'userdata',user);
      mot = get(fg,'windowbuttonmotionfcn');
%      set(fg,'windowbuttonmotionfcn',['Dhv_movl(3,' num2str(ortho) ')' mot])
%      set(fg,'windowbuttonupfcn',['Dhv_movl(4,' num2str(ortho) ',''' P1 ''')'])
     set(fg,'windowbuttonmotionfcn',['Dhv_movl(3,' num2str(ortho) ')'])
     set(fg,'windowbuttonupfcn',['Dhv_movl(4,' num2str(ortho) ')'])

elseif stage ==3 & length(zb),
  ortho=P1;
  point = get(hg,'currentpoint');
  usrdata = get(zb,'userdata');
  data = get(real(usrdata(3)),'userdata');

  if length(usrdata)>0,
    dx = point(2,1)-real(usrdata(1));
    dy = point(2,2)-real(usrdata(2));
    if ortho==1
      xpre = get(hg,'xlim');
      ypre = get(hg,'ylim');
      if abs(dx/(xpre(2)-xpre(1))) > abs(dy/(ypre(2)-ypre(1)))
        dy=0;
      else
        dx=0;
      end
    end

    set(real(usrdata(3)),'Xdata', ...
      data(:,1)+dx,...
      'Ydata',data(:,2)+dy);
  end

elseif stage ==4 & length(zb),
  ortho = P1;
  point = get(hg,'currentpoint');
  usrdata = get(zb,'userdata');
  xpre = get(hg,'xlim');
  ypre = get(hg,'ylim');
  data =get(real(usrdata(3)),'userdata');

  if length(usrdata)>0,
    if Questbox('Move the line ?','Question');

      dx = point(2,1)-real(usrdata(1));
      dy = point(2,2)-real(usrdata(2));
      if ortho==1
        xpre = get(hg,'xlim');
        ypre = get(hg,'ylim');
        if abs(dx/(xpre(2)-xpre(1))) > abs(dy/(ypre(2)-ypre(1)))
          dy=0;
        else
          dx=0;
        end
      end

      set(real(usrdata(4)),'Xdata', ...
        data(:,1)+dx,...
        'Ydata',data(:,2)+dy);
    end
    set(zb,'userdata',[]);
    delete(real(usrdata(3)))
  end;

  set(fg,'windowbuttonmotionfcn','');
  set(fg,'windowbuttonupfcn','');
%  Set_zoom;

%  set(fg,'pointer',P2);

end;


