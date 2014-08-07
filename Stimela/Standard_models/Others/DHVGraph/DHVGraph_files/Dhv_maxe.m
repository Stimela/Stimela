function Dhv_maxe(stage,P1,P2,P3,P4,P5,P6,P7,P8,P9);
%  Dhv_maxe(stage);
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

if stage ==1 & ~figflag('Configure Axes',0),


  %inlezen huidige gegevens
  ax = gca;
  zb = Gct;
  fg = gcf;

  la = get(get(ax,'title'),'string');
  la = str2mat(la, get(get(ax,'xlabel'),'string') );
  la = str2mat(la, get(get(ax,'ylabel'),'string') );
  la = str2mat(la, get(get(ax,'zlabel'),'string') );

  ls(1) = get(get(ax,'title'),'fontsize');
  ls(2) = get(get(ax,'xlabel'),'fontsize');
  ls(3) = get(get(ax,'ylabel'),'fontsize');
  ls(4) = get(get(ax,'zlabel'),'fontsize');

  gr(1) = strcmp(get(ax,'xgrid'),'on');
  gr(2) = strcmp(get(ax,'ygrid'),'on');
  gr(3) = strcmp(get(ax,'zgrid'),'on');

  ln(1) = strcmp(get(ax,'xscale'),'linear');
  ln(2) = strcmp(get(ax,'yscale'),'linear');
  ln(3) = strcmp(get(ax,'zscale'),'linear');

  lm(1,:) = get(ax,'xlim');
  lm(2,:) = get(ax,'ylim');
  lm(3,:) = get(ax,'zlim');
  % limieten kleiner dan 1e-3 krijg je problemen
  dm=abs((lm(:,1)-lm(:,2)))./max(abs(lm(:,1:2)'))';
  lm(:,2) = lm(:,2)+(dm<1e-3).*1e-3.*max(abs(lm(:,1:2)'))';


  md(1) = strcmp(get(ax,'xlimmode'),'auto');
  md(2) = strcmp(get(ax,'ylimmode'),'auto');
  md(3) = strcmp(get(ax,'zlimmode'),'auto');


%  as = get(ax,'DataAspectRatio');
%  ast = str2mat('Normal','Square','Equal','Fixed');
%  asn = [nan nan;1 nan;nan 1;1 1];
%  asc = 4-( isnan(as(1))+isnan(as(2))*2);

  % view 
  vi = get(ax,'view');

  %aanmaken van figuur file
  h_fig=figure('Menubar','none',...
          'NumberTitle','off',...
          'resize','off',...
          'Name','Configure Axis',...
          'keypress', ' ',...
          'HandleVisibility','callback',...
          'visible','off');

  % voorkomen dat onderstaande figuur geopend wordt
  Dhv_filf(fg,'Configure Axis',h_fig);

  pos = get(h_fig,'position');

  axes('visible','off','units','normalized','position',[0 0 1 1],...
       'xlim',[0 1],'ylim',[0 1]);

  h = Gch(2);
  width = 600;
  heigth = 13*h;
  left = pos(1)+.5*(pos(3)-width);
  bottom = pos(2)+.5*(pos(4)-heigth);

  pos = [left bottom width heigth];
  set(h_fig,'position',pos);

  hu = Gch;

  % 4 teksten voor xlabel-ylabel-zalbel-title
  xp=0.05;
  txt = str2mat('title:','xlabel:','ylabel:','zlabel:');
  for i=1:4
    text(xp,1-i/6+hu,txt(i,:),...
         'verticalalignment','top','fontsize',12,'horizontalal','left');
    ht(i) = Uiedhv(zb,'',Delspace(la(i,:)),[xp+.1 1-i/6 .2 hu],[],1);
  end


  % 4 fontsizes
  xp = 0.38;
  for i=1:4
    hf(i) = uicontrol('Style','edit','Units','normalized',...
        'Position',[xp 1-i/6 .04 hu],'HorizontalAlignment','left',...
        'string', num2str(ls(i)), ...
        'callback',['Dhv_seta(1,' num2str(ls(i)) ')']);
  end

  % grid
  xp=0.38+.075;
  text(xp,1-1/6,'Grid',...
         'verticalalignment','base','fontsize',12,'horizontalal','left');
  for i=1:3
    hg(i) = uicontrol('Style','Checkbox','Units','normalized',...
        'Position',[xp 1-(i+1)/6 .03 hu],'HorizontalAlignment','left',...
        'string', '','Value',gr(i));
  end

  % limits
  xp=.44+.075;
  onoff = str2mat('on','off');

  text(xp,1-1/6,'Limits',...
         'verticalalignment','base','fontsize',12,'horizontalal','left');
  text(xp,1-1/6-1/14,'min','fontangle','italic',...
         'verticalalignment','base','fontsize',11,'horizontalal','left');
  text(xp+.1,1-1/6-1/14,'max','fontangle','italic',...
         'verticalalignment','base','fontsize',11,'horizontalal','left');
  for i=1:3
    hl(i) = uicontrol('Style','edit','Units','normalized',...
        'Position',[xp 1-(i+1)/6 .1 hu],'HorizontalAlignment','left',...
        'string', num2str(lm(i,1)), 'enable', onoff(md(i)+1,:),...
        'callback',['Dhv_seta(1,' num2str(lm(i,1)) ')'] );
    hl(i+3) = uicontrol('Style','edit','Units','normalized',...
        'Position',[xp+.1 1-(i+1)/6 .1 hu],'HorizontalAlignment','left',...
        'string', num2str(lm(i,2)), 'enable', onoff(md(i)+1,:),...
        'callback',['Dhv_seta(1,' num2str(lm(i,2)) ')'] );
  end

  % auto
  xp=.68+.075;
  text(xp,1-1/6-1/14,'Auto','fontangle','italic',...
         'verticalalignment','base','fontsize',11,'horizontalal','left');
  for i=1:3
    hm(i) = uicontrol('Style','check','Units','normalized',...
        'Position',[xp 1-(i+1)/6 .03 hu],'HorizontalAlignment','left',...
        'callback','Dhv_seta(2)','value', md(i),'userdata',[hl(i) hl(i+3)] );
  end


  % logarithm
  xp = .75+.075;
  text(xp,1-1/6,'Scale',...
         'verticalalignment','base','fontsize',12,'horizontalal','left');
  for i=1:3
    hs(i) = uicontrol('Style','radio','Units','normalized',...
        'Position',[xp 1-(i+1)/6 .08 hu],'HorizontalAlignment','left',...
        'string', 'lin','callback','Dhv_seta(3)','value', ln(i) );
    hs(i+3) = uicontrol('Style','radio','Units','normalized',...
        'Position',[xp 1-(i+1)/6-1/14 .08 hu],'HorizontalAlignment','left',...
        'string', 'log','callback','Dhv_seta(3)','value',1-ln(i) );
  end

  for i=1:3,
    set(hs(i),'userdata',hs(i+3));
    set(hs(i+3),'userdata',hs(i));
  end


  % aspect
 % xp = 0.05;
 % text(xp,1-5/6,'Aspect-Ratio',...
 %        'verticalalignment','base','fontsize',12,'horizontalal','left');
 % ha = uicontrol('Style','popup','Units','normalized',...
 %       'Position',[xp+.2 1-5/6 .1 hu],'HorizontalAlignment','left',...
 %       'string', ast,'value', asc );
 
 ha=0;
 
  % view
  xp=.38+.075;
  text(xp,1-5/6,'View',...
         'verticalalignment','base','fontsize',12,'horizontalal','left');
  text(xp+0.06,1-5/6+1/12,'azimuth','fontangle','italic',...
         'verticalalignment','base','fontsize',11,'horizontalal','left');
  text(xp+.17,1-5/6+1/12,'elevation','fontangle','italic',...
         'verticalalignment','base','fontsize',11,'horizontalal','left');
  hv(1) = uicontrol('Style','edit','Units','normalized',...
        'Position',[xp+.06 1-5/6 .1 hu],'HorizontalAlignment','left',...
        'string', num2str(vi(1)), 'callback',['Dhv_seta(1,' num2str(vi(1)) ')']);
  hv(2) = uicontrol('Style','edit','Units','normalized',...
        'Position',[xp+.17 1-5/6 .1 hu],'HorizontalAlignment','left',...
        'string', num2str(vi(2)), 'callback',['Dhv_seta(1,' num2str(vi(2)) ')']);



  h_OK = uicontrol('Style','pushbutton',...
         'Units','normalized',...
         'position',[0.1 .02 .35 1.1*hu],...
         'HorizontalAlignment','center',...
         'String','OK',...
         'callback','Dhv_maxe(2);');

  h_Esc = uicontrol('Style','pushbutton',...
         'Units','normalized',...
         'position',[0.55 .02 .35 1.1*hu],...
         'HorizontalAlignment','center',...
         'String','Cancel',...
         'Callback','close;Dhv_chfi;');

  set(h_fig,'userdata',[ax ht hg hl hm hs(1:3) ha hv hf]);
  set(h_fig,'visible','on');

elseif stage ==2, % vullen commando
  hh = get(gcf,'userdata');
  ax = hh(1);
  ht = hh(2:5);
  hg = hh(6:8);
  hl = hh(9:14);
  hm = hh(15:17);
  hs = hh(18:20);
  ha = hh(21);
  hv = hh(22:23);
  hf = hh(24:27);

  set(get(ax,'title'),'string',get(ht(1),'string'),'fontsize',eval(get(hf(1),'string')) );
  set(get(ax,'xlabel'),'string',get(ht(2),'string'),'fontsize',eval(get(hf(2),'string')));
  set(get(ax,'ylabel'),'string',get(ht(3),'string'),'fontsize',eval(get(hf(3),'string')));
  set(get(ax,'zlabel'),'string',get(ht(4),'string'),'fontsize',eval(get(hf(4),'string')));

  gridtxt = str2mat('off','on');
  set(ax,'xgrid',gridtxt(get(hg(1),'value')+1,:));
  set(ax,'ygrid',gridtxt(get(hg(2),'value')+1,:));
  set(ax,'zgrid',gridtxt(get(hg(3),'value')+1,:));

  set(ax,'xlim',sort(eval(['[' get(hl(1),'string') ',' get(hl(3+1),'string') ']'])));
  set(ax,'ylim',sort(eval(['[' get(hl(2),'string') ',' get(hl(3+2),'string') ']'])));
  set(ax,'zlim',sort(eval(['[' get(hl(3),'string') ',' get(hl(3+3),'string') ']'])));

  automan = str2mat('manual','auto');
  set(ax,'xlimmode',automan(get(hm(1),'value')+1,:));
  set(ax,'ylimmode',automan(get(hm(2),'value')+1,:));
  set(ax,'zlimmode',automan(get(hm(3),'value')+1,:));

  scale = str2mat('log','lin');
  set(ax,'xscale',scale(get(hs(1),'value')+1,:));
  set(ax,'yscale',scale(get(hs(2),'value')+1,:));
  set(ax,'zscale',scale(get(hs(3),'value')+1,:));

%  asn = [nan nan;1 nan;nan 1;1 1];
%  set(ax,'aspect',asn(get(ha,'value'),:));

  set(ax,'view',sort(eval(['[' get(hv(1),'string') ',' get(hv(2),'string') ']'])));

  close;
  Dhv_chfi;

end
