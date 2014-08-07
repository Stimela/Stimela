function Dhv_chax()
%  Dhv_chax()
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

OK = Dis_zoom;
if OK,
  gf = gca;
  ff = get(gcf,'children');
  tel = length(ff)+1;
  tela = 0;

  while tel > 1,
    tel = tel-1;
    tela = tel;
    if strcmp(get(ff(tel),'type'),'axes'),
        tel = 1;
    end;
  end;

  if tela ~= 0,
    na = ff(tela);
    set(gcf,'currentaxes',na);

    limx = get(na,'xlim');
    limy = get(na,'ylim');
    limz = get(na,'zlim');
    h =  surface(limx,limy,ones(2,2)*limz(1),'facecolor',[.5 .5 .5],'erasemode','xor');
    % een .1 seconden wachten
    tbeg = clock;
    while(etime(clock,tbeg)<.15)
    end
    delete(h)

  end;

  Set_zoom
end;



