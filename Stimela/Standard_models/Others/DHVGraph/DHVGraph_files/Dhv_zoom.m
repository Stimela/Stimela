function Dhv_zoom(stage,P1)
%  Dhv_zoom(stage)
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

zb = Gcz;
fg = gcf;

if stage >0
  ax = gca;
end

if stage ==0 & length(zb),
  OK = Dis_zoom;
  if OK,
    set(fg,'pointer','crosshair');

    set(fg,'windowbuttondownfcn','Dhv_zoom(1)');
    set(fg,'windowbuttonmotionfcn','');
    set(fg,'windowbuttonupfcn','');

    set(Gcq,'label',':Zoom Axis');
  end;



elseif stage ==1 & length(zb),

  but=get(fg,'selectiontype');
  if strcmp(but,'alt')
    ortho=1;
  else
    ortho=0;
  end

    user = get(zb,'userdata');
    if length(user)>0,
      delete(real(user(3)));
      set(zb,'userdata',[]);
    end;

    point = get(ax,'currentpoint');
    xpre = get(ax,'xlim');
    ypre = get(ax,'ylim');
    OK = 1;
    autoy = any([point(2,1)<xpre(1) point(2,1)>xpre(2)]);
    autox = any([point(2,2)<ypre(1) point(2,2)>ypre(2)]);
    if autox| autoy
      OK = 0;
      af = get(fg,'units');
      set(fg,'units','normalized');
      Ps = get(fg,'currentpoint');
      set(fg,'units',af);
      hf = get(fg,'children');
      for tel = 1:length(hf),
        Tp = get(hf(tel),'Type');
        if Tp(1) == 'a' &  Tp(length(Tp)) == 's',
          axU = get(hf(tel),'units');
          set(hf(tel),'units','normalized');
          ps = get(hf(tel),'position');
          set(hf(tel),'units',axU);
          if (Ps(1)<ps(1)+ps(3)) &  (Ps(1) > ps(1)) & (Ps(2) > ps(2)) & (Ps(2) < ps(2)+ps(4)),
             set(fg,'currentax',hf(tel));
             ax=hf(tel);
            point = get(ax,'currentpoint');
            OK = 1;
          end;
        end;
      end;
    end;

    vw = 1;
    if any(get(ax,'view') ~= [0 90]),
      OK = 0;
      vw = 0;
    end

    if ~OK,
      if autox | (~ortho & vw)
        set(ax,'xlimmode','auto');
      end
      if autoy | (~ortho & vw)
        set(ax,'ylimmode','auto');
      end
      set(fg,'windowbuttonmotionfcn','')
      set(fg,'windowbuttonupfcn','')
    else
      xd = [point(2,1) point(2,1) point(2,1) point(2,1) point(2,1)];
      yd = [point(2,2) point(2,2) point(2,2) point(2,2) point(2,2)];

      h = line('xdata',xd, ...
              'ydata',yd, ...
              'color',[.5 .5 .5],'erasemode','xor');
      user(1:3) = [point(2,1:2) h];
      set(zb,'userdata',user);
      set(fg,'windowbuttonmotionfcn',['Dhv_zoom(2,' num2str(ortho) ')'])
      set(fg,'windowbuttonupfcn',['Dhv_zoom(3,' num2str(ortho) ')'])
    end

elseif stage ==2 & length(zb),

  ortho = P1;
  point = get(ax,'currentpoint');
  usrdata = get(zb,'userdata');
  xpre = get(ax,'xlim');
  ypre = get(ax,'ylim');
  if length(usrdata)>0,
    if point(2,1)<xpre(1), point(2,1)=xpre(1);end;
    if point(2,1)>xpre(2), point(2,1)=xpre(2);end;
    if point(2,2)<ypre(1), point(2,2)=ypre(1);end;
    if point(2,2)>ypre(2), point(2,2)=ypre(2);end;

    xd=  [real(usrdata(1)) point(2,1) point(2,1) real(usrdata(1)) real(usrdata(1))];
    yd = [real(usrdata(2)) real(usrdata(2)) point(2,2) point(2,2) real(usrdata(2))];

    if ortho==1
      dx = real(usrdata(1))-point(2,1);
      dy = real(usrdata(2))-point(2,2);
      if abs(dx/(xpre(2)-xpre(1))) > abs(dy/(ypre(2)-ypre(1)))
        yd=[ypre(2) ypre(2) ypre(1) ypre(1) ypre(2)];
      else
        xd=[xpre(2) xpre(1) xpre(1) xpre(2) xpre(2)];
      end
    end

    set(real(usrdata(3)),'Xdata',xd,'Ydata',yd);

  end
elseif stage ==3 & length(zb),

  ortho = P1;
  point = get(ax,'currentpoint');
  usrdata = get(zb,'userdata');
  xpre = get(ax,'xlim');
  ypre = get(ax,'ylim');

  if length(usrdata)>0,

    if point(2,1)<xpre(1), point(2,1)=xpre(1);end;
    if point(2,1)>xpre(2), point(2,1)=xpre(2);end;
    if point(2,2)<ypre(1), point(2,2)=ypre(1);end;
    if point(2,2)>ypre(2), point(2,2)=ypre(2);end;


    OKx=1;
    OKy=1;
    if ortho==1
      dx = real(usrdata(1))-point(2,1);
      dy = real(usrdata(2))-point(2,2);
      if abs(dx/(xpre(2)-xpre(1))) > abs(dy/(ypre(2)-ypre(1)))
        OKy=0;
      else
        OKx=0;
      end
    end

    if (OKx)&(OKy)& ...
         ( (point(2,1) == real(usrdata(1))) | (point(2,2) == real(usrdata(2))) )
      OKx=0;
      OKy=0;
    end

    if (OKx) & (point(2,1) ~= real(usrdata(1))),
        set(ax,'xlim',sort([real(usrdata(1)) point(2,1)]));
        set(ax,'xlimmode','manual');
    end
    if (OKy) & (point(2,2) ~= real(usrdata(2))),
      set(ax,'ylim', sort([real(usrdata(2)) point(2,2)]));
      set(ax,'ylimmode','manual');
    end

    set(Gcz,'userdata',[]);
    delete(real(usrdata(3)))
  end;

  set(fg,'windowbuttonmotionfcn','')
  set(fg,'windowbuttonupfcn','')

end;


