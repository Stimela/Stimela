function Dhv_subp();
%  Dhv_subp();
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95 

OK = Dis_zoom;
if OK,
  fg = gcf;
  pos = get(gcf,'position');
  h = get(gcf,'children');
  for tel = 1:length(h);
    if strcmp(get(h(tel),'type'),'axes'),
      posx = [posx;get(h(tel),'position')];
    end;
  end;
  left = pos(1)+.2*pos(3);
  bottom = pos(2)+.2*pos(4);
  width = .6*pos(3);
  heigth = .6*pos(4);

  h_fig=figure('Menubar','none',...
        'position',[left bottom width heigth],...
        'NumberTitle','off',...
        'resize','off',...
        'Name','Click on subplot number',...
        'keypress',' ');
  col = get(gcf,'color');
  colo = abs(col-[1 1 1])+(col == [.5 .5 .5])*.5;
    h_Esc = uicontrol('Style','pushbutton',...
           'Units','normalized',...
           'position',[0.1 0 .8 .1],...
           'HorizontalAlignment','center',...
           'String','Cancel');
  pos(2,:) = [0.1 0 0.8 .1];
    axes('position',[0 .1 1 .9],'visible','off','xlim',[0 6],'ylim',[0 6]);
  for telC = 1:6,
    for telR = 1:6,
      line('xdata',[telC-.9 telC-.1 telC-.1 telC-.9 telC-.9],...
           'ydata',[telR-.9 telR-.9 telR-.1 telR-.1 telR-.9],...
           'color',colo);
      text(telC-.5,telR-.5,[int2str(7-telR) ' x ' int2str(telC)],...
           'horizontalalignment','center',...
           'verticalalignment','middle','color',colo);
      pos(6*telC+(7-telR)+2,:) = [telC-.9 .6+(telR-.9)*.9 .8 .8*.9]/6 ;
    end;
  end
  OK = Holdfig(pos);
  if abs(OK)==1,
    OK=4;
  end;
  if abs(OK) >2,
    R = rem((OK-3),6)+1;
    C = ((OK-2)-R)/6;
    clf
    set(gcf,'Name','Click on subplot');
    h_Esc = uicontrol('Style','pushbutton',...
           'Units','normalized',...
           'position',[0.1 0 .8 .1],...
           'HorizontalAlignment','center',...
           'String','Cancel');
    pos = [];
    pos(2,:) = [0.1 0 0.8 .1];

    dx = .22;
    dy = .1;
    axes('position',[dx/2 .1+dy/2 1-dx .9-dy],'visible','off','xlim',[0 C],'ylim',[0 R]);
    for tel = 1:size(posx,1),
      dR = (.9-dy)+dy/.9;
      posx(tel,1) = ((posx(tel,1)-dx/2)/(1-dx))*C;
      posx(tel,2) = ((posx(tel,2)-dy/2)/dR)*R;
      posx(tel,3) = posx(tel,3)/(1-dx)*C;
      posx(tel,4) = posx(tel,4)/dR*R;
      patch([posx(tel,1) posx(tel,1) posx(tel,1)+posx(tel,3) posx(tel,1)+posx(tel,3)], ...
            [posx(tel,2) posx(tel,2)+posx(tel,4) posx(tel,2)+posx(tel,4) posx(tel,2)], ...
            abs(col-[.5 .5 .5]),'edgecolor','none');
    end;

    for telC = 1:C,
      for telR = 1:R,
        line('xdata',[telC-.9 telC-.1 telC-.1 telC-.9 telC-.9],...
             'ydata',[telR-.9 telR-.9 telR-.1 telR-.1 telR-.9],...
             'color',colo);
        text(telC-.5,telR-.5,int2str(C*(R-telR)+telC),...
             'horizontalalignment','center',...
             'verticalalignment','middle','color',colo);
        pos(C*(R-telR)+telC+2,:) = [dx/2+(1-dx)*(telC-.9)/C .1+dy/2+(.9-dy)*(telR-.9)/R (1-dx)*.8/C (.9-dy)*.8/R];
      end;
    end
    OK = Holdfig(pos);

    close

    figure(fg);
    if OK ==-1,
      subplot(R,C,1);
    elseif OK>2,
      subplot(R,C,OK-2);
    end;
  else
    close
    figure(fg)
  end;

  Set_zoom
end;


