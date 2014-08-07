function Dhv_view(stage);
%  Dhv_view(stage);
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

fg = gcf;
ag = gca;
zb = Gcz;

if stage ==0,
  OK = Dis_zoom;
  if OK,

    set(fg,'pointer','arrow');

    set(fg,'windowbuttondownfcn','Dhv_view(1)');
    set(fg,'windowbuttonmotionfcn','');
    set(fg,'windowbuttonupfcn','');

    set(Gcq,'label',':View Axis');

  end;

elseif stage ==1,
%  if any(get(ag,'view') ~= [0 90]),
  user = get(zb,'userdata');
  if length(user)>0
    delete(user(3));
  end

    h = get(fg,'children');
    for tel = 1:length(h),
      plek = findstr(get(h(tel),'userdata'),'viewtemp');
      if length(plek),
        delete(h(tel));
      end;
    end;
    ag = gca;
    vi = get(ag,'view');
    set(fg,'windowbuttonmotionfcn','Dhv_view(2)')
    set(fg,'windowbuttonupfcn','Dhv_view(3)')

    ga = ag;
    point = get(ga,'currentpoint');
    pos = get(ga,'position');

    ha = axes('position',[pos(1)+.4*pos(3) pos(2)+.9*pos(4) .2*pos(3) .2*pos(4)],...
       'visible','off',...
       'xlim',[-1 1],'ylim',[-1 1]);
    point = get(ha,'currentpoint');
    set(ha,'zlim', [-1 1],'view',vi);
    hb = axes('position',[pos(1)+.4*pos(3)  pos(2)+.9*pos(4) .2*pos(3) .2*pos(4)],...
            'visible','on',...
            'xlim',[-60 60]-60*point(2,1)+vi(1),...
            'ylim',[-60 60]-60*point(2,2)+vi(2),...
            'xtick',[],'ytick',[],'box','on',...
            'userdata','viewtemp');

    set(fg,'currentaxes',ha);

    x = .8*[0 0 1 0 0 1];
    y = .8*[0 1 0 1 0 0];
    z =.8*[ 0     1   NaN   NaN   NaN   NaN
            0     1   NaN   NaN   NaN   NaN
          NaN   NaN     0     0   NaN   NaN
          NaN   NaN     0     0   NaN   NaN
          NaN   NaN   NaN   NaN     1     1
          NaN   NaN   NaN   NaN     0     0];

    h2 = surface(x,y,z,'parent',ha,'facecolor',[.25 .25 .25],'erasemode','normal');

    h1 = text(0,1,0,'Y','erasemode','normal');
    h3 = text(1,0,0,'X','erasemode','normal');
    h4 = text(0,0,1,'Z','erasemode','normal');


    set(ha,'userdata',[ha hb ga double('viewtemp')]);
    user(3) = ha;
    set(zb,'userdata',user);
    drawnow
 % else
 %   dhv_upda
 % end;
elseif stage ==2,



  user = get(ag,'userdata');
  if ~isempty(user),
    point = get(real(user(2)),'currentpoint');

    vi = point(2,1:2);
    set(ag,'view',vi);

  end;

elseif stage ==3,

  user = get(ag,'userdata');
  if ~isempty(user),
    point = get(real(user(2)),'currentpoint');

    vi = point(2,1:2);
    delete(real(user(1:2)))
    set(fg,'currentaxes',real(user(3)));
    set(real(user(3)),'view',vi);

    set(zb,'userdata',[]);
  end;

  set(fg,'windowbuttonmotionfcn','')
  set(fg,'windowbuttonupfcn','')
end;

