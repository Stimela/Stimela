function Dhv_move(stage,on,hg)
%  Dhv_move(stage)
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

fg = gcf;
zb = Gcz;

fx = get(fg,'units');
set(fg,'units','normalized');
point = get(fg,'currentpoint');
set(fg,'units',fx);

if stage == 0 & length(zb)
  OK = Dis_zoom;
  if OK,
    set(fg,'pointer','arrow');

    set(fg,'windowbuttondownfcn','Dhv_move(1)');
    set(fg,'windowbuttonmotionfcn','Dhv_move(4)');
    set(fg,'windowbuttonupfcn','');

    set(Gcq,'label',':Move Axis');
  end;


elseif stage ==1 & length(zb),
  user = get(zb,'userdata');
  if length(user)>0,
    set(fg,'windowbuttonmotionfcn','Dhv_move(4)')
    set(fg,'windowbuttonupfcn','')
    delete(real(user(3)));
    set(zb,'userdata',[]);
  end;

  h = get(fg,'children');

  if nargin <2,
    on = 0;
    hg = gca;
    ax = get(hg,'units');
    set(hg,'units','normalized')
    Ps = get(hg,'position');
    set(hg,'units',ax);

    on = Dhv_bero(Ps,point);

    if ~on,
      tel = length(h);
      while tel>1 & ~on,
        tel = tel-1;
        Tp = get(h(tel),'Type');
        if Tp(1) == 'a',
          ax = get(h(tel),'units');
          set(h(tel),'units','normalized')
          Ps = get(h(tel),'position');
          set(h(tel),'units',ax);

          on = Dhv_bero(Ps,point);
        end;
      end;
    else
      tel = find(hg==h);
    end;
  else
    tel=find(hg==h);
    ax = get(hg,'units');
    set(hg,'units','normalized')
    Ps = get(hg,'position');
    set(hg,'units',ax);
    point= [Ps(1)+.5*Ps(3) Ps(2)+.5*Ps(4)];
  end

  if abs(on)>0,
     ha = axes('visible','off','position',[0 0 1 1],'units','normalized','color','none',...
               'Xlim',[0 1],'Ylim',[0 1]);
     x = [Ps(1) Ps(1)+Ps(3) Ps(1)+Ps(3) Ps(1) Ps(1)];
     y = [Ps(2) Ps(2) Ps(2)+Ps(4) Ps(2)+Ps(4) Ps(2)];
     hl = line('xdata',x,'ydata',y, ...
              'color',[.5 .5 .5],'erasemode','xor');
     set(ha,'userdata',[hl h(tel)]);
     set(hl,'userdata',[x y]);

     user(1:3) = [point ha];
     set(zb,'userdata',user);
     set(fg,'windowbuttonmotionfcn',['Dhv_move(2,' num2str(on) ')'])
     set(fg,'windowbuttonupfcn',['Dhv_move(3,' num2str(on) ')'])
  end

elseif stage ==2 & length(zb),
  usrdata = get(zb,'userdata');
  if length(usrdata)>0,
    user = get(real(usrdata(3)),'userdata');
    dx = point(1)-real(usrdata(1));
    dy = point(2)-real(usrdata(2));

    if abs(on) > 3,
      if abs(dx) < abs(dy),
        dy = abs(dx)*sign(dy);
      else
        dx = abs(dy)*sign(dx);
      end;
    end;

    vars = get(user(1),'userdata');
    y = vars(6:10);
    x = vars(1:5);

    if on == 1,
      x = x+dx;
      y = y+dy;
    else
      if on == 2|on == 4 | on == 5,
        x(2:3) = x(2:3)+dx;
      elseif on == -2 | on == -4 | on == -5,
        x([1 4 5]) = x([1 4 5])+dx;
      end;
      if on == 3 | on == 4 | on ==-5,
        y(3:4) = y(3:4)+dy;
      elseif on == -3 | on == -4 | on ==5,
        y([1 2 5]) = y([1 2 5])+dy;
      end;
    end

    set(user(1),'Xdata',x,'Ydata',y);
  end;

elseif stage ==3 & length(zb),
  usrdata = get(zb,'userdata');
  if length(usrdata)>0,
    user = get(real(usrdata(3)),'userdata');
    dx = point(1)-real(usrdata(1));
    dy = point(2)-real(usrdata(2));

    if abs(on) > 3,
      if abs(dx) < abs(dy),
        dy = abs(dx)*sign(dy);
      else
        dx = abs(dy)*sign(dx);
      end;
    end;

    vars = get(user(1),'userdata');
    y = vars(6:10);
    x = vars(1:5);

    if on == 1,
      x = x+dx;
      y = y+dy;
    else
      if on == 2|on == 4 | on == 5,
        x(2:3) = x(2:3)+dx;
      elseif on == -2 | on == -4 | on == -5,
        x([1 4 5]) = x([1 4 5])+dx;
      end;
      if on == 3 | on == 4 | on ==-5,
        y(3:4) = y(3:4)+dy;
      elseif on == -3 | on == -4 | on ==5,
        y([1 2 5]) = y([1 2 5])+dy;
      end;
    end

    set(zb,'userdata',[]);
    delete(real(usrdata(3)))

    Ps = [x(1) y(1) x(2)-x(1) y(3)-y(1)];

    if x(1)>x(2),
      Ps(1) = x(2);
      Ps(3) = x(1)-x(2);
      vi = get(gca,'view');
      if all(vi ==[0 90]);
        xdir = get(user(2),'Xdir');
        if xdir(1) =='n',
          set(user(2),'Xdir','reverse');
        else
          set(user(2),'Xdir','normal');
        end;
      end;
    end;

    if y(1)>y(3),
      Ps(2) = y(3);
      Ps(4) = y(1)-y(3);
      vi = get(gca,'view');
      if all(vi ==[0 90]);
        ydir = get(user(2),'Ydir');
        if ydir(1) =='n',
          set(user(2),'Ydir','reverse');
        else
          set(user(2),'Ydir','normal');
        end;
      end;
    end;
    ax = get(user(2),'units');
    set(user(2),'units','normalized')
    set(user(2),'position',Ps);
    set(user(2),'units',ax);

  end;

  set(fg,'windowbuttondownfcn','Dhv_move(1)')
  set(fg,'windowbuttonmotionfcn','Dhv_move(4)')
  set(fg,'windowbuttonupfcn','')


%  % herstel aan de hand van heersende button stand
%  set(fg,'currentobject',zb);
%  dhv_setz;

elseif stage ==4 & length(zb),
  h = get(fg,'children');

  on = 0;
  hg = gca;
  ax = get(hg,'units');
  set(hg,'units','normalized')
  Ps = get(hg,'position');
  set(hg,'units',ax);

  on = Dhv_bero(Ps,point);
  if ~on,
    tel = length(h);
    while tel>1 & ~on,
      tel = tel-1;
      Tp = get(h(tel),'Type');
      if Tp(1) == 'a',
        ax = get(h(tel),'units');
        set(h(tel),'units','normalized')
        Ps = get(h(tel),'position');
        set(h(tel),'units',ax);

        on = Dhv_bero(Ps,point);
      end;
    end;
  else
    tel = find(hg==h);
  end;
  
  switch on
     case 1 
       set(fg,'pointer','fleur');
     case -2 
       set(fg,'pointer','left');
     case -3 
       set(fg,'pointer','bottom');
     case -4 
        set(fg,'pointer','botl');
     case -5 
        set(fg,'pointer','topl');
        
     case 2 
       set(fg,'pointer','right');
     case 3 
       set(fg,'pointer','top');
     case 4 
        set(fg,'pointer','topr');
     case 5 
        set(fg,'pointer','botr');
        
     otherwise   
        set(fg,'pointer','arrow');
  end;

end

