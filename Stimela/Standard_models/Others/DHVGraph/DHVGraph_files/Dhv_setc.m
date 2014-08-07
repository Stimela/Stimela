function Dhv_setc(flag,P1,P2);
%  Dhv_setc(flag);
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

colorstr = str2mat(' ','yellow','magenta','cyan','red','green','blue','white','black');
ascolor = [1 1 0;1 0 1;0 1 1;1 0 0;0 1 0;0 0 1; 1 1 1; 0 0 0];

if flag ==1,
  hls = get(gco,'userdata');
  val = get(gco,'value');
  if (val~=1)
    str = get(gco,'string');
    set(hls,'linestyle',Delspace(str(val,:)),'visible','on');
  else
    set(hls,'visible','off');
  end

elseif flag ==2,
  hlc = get(gco,'userdata');
  str = get(gco,'string');
  set(hlc(1),'visible','off');
  set(hlc(2),'value',1);
  OK = 1;
  M = [];
  eval(['M= [' str '];'],'OK = 0;');
  if ~OK
    Textbox(str2mat('error in color definition:',' ',str,' ',transcode(lasterr)));
  elseif length(M) ~=3,
      Textbox(str2mat('error in color definition:',' ',str,'invalid length'));
  elseif max(M)>1 | min(M) <0,
      Textbox(str2mat('error in color definition:',' ',str,'invalid values'));
  else
    set(hlc(1),'color',M,'visible','on');
    for tel = 1:size(ascolor,1)
      if all(M==ascolor(tel,:))
        set(hlc(2),'value',tel+1);
      end
    end
  end


elseif flag ==3,
  hlc = get(gco,'userdata');
  val = get(gco,'value');
  set(hlc(1),'visible','off');
  if(val~=1)
    set(hlc(1),'color',ascolor(val-1,:),'visible','on');
    set(hlc(2),'string',sprintf('%1d     %1d     %1d',ascolor(val-1,:)));
  else
    set(hlc(2),'string',' ');
  end

elseif flag ==4,
  htss = get(gco,'userdata');
  str = get(gco,'string');
  OK = 1;
  M = [];
  eval(['M= [' str '];'],'OK = 0;');
  if ~OK
    Textbox(str2mat('error in text definition:',' ',str,' ',transcode(lasterr)));
  elseif length(M) ~=1,
      Textbox(str2mat('error in text definition:',' ',str,'invalid length'));
  elseif min(M) <0,
      Textbox(str2mat('error in text definition:',' ',str,'invalid values'));
  else
    set(htss,'fontsize',M);
  end

elseif flag ==5,
  hdss = get(gco,'userdata');
  str = get(gco,'string');
  OK = 1;
  M = [];
  eval(['M= [' str '];'],'OK = 0;');
  if ~OK
    Textbox(str2mat('error in dot definition:',' ',str,' ',transcode(lasterr)));
  elseif length(M) ~=1,
      Textbox(str2mat('error in dot definition:',' ',str,'invalid length'));
  elseif min(M) <0,
      Textbox(str2mat('error in dot definition:',' ',str,'invalid values'));
  else
    set(hdss,'markersize',M);
  end
elseif flag ==6
  har = P1;
  hps = get(har,'userdata');
  x1 = hps(1);
  x2 = hps(2);
  y1 = hps(3);
  y2 = hps(4);
  W = hps(5);
  S = hps(6);
  A = hps(7);


  hg = gca;
  ua = get(hg,'units');
  set(hg,'units','pixels');
  pa = get(hg,'position');
  set(hg,'units',ua);

  xp = S/pa(3);
  yp = S/pa(4);

  x = [x1 x2];
  y = [y1 y2];
  dy = (y(2)-y(1));
  dx = (x(2)-x(1));
  if dy>0,
    alpha = .5*pi;
  else
    alpha = 1.5*pi;
  end

  p1 = alpha+((180-A)/180)*pi;
  p2 = alpha+((180+A)/180)*pi;
  x1 = xp*cos(p1);
  y1 = yp*sin(p1);
  x2 = xp*cos(p2);
  y2 = yp*sin(p2);

  set(har,'xdata',[x x(2)+x1 x(2)+x2 x(2)],...
          'ydata',[y y(2)+y1 y(2)+y2 y(2)],'zdata',.5*ones(5,1),...
          'color',[1 1 1],'erasemode','normal',...
          'linewidth',W);

elseif flag==7
  har = get(gco,'userdata');
  hps = get(har,'userdata');
  str = get(gco,'string');
  OK = 1;
  M = [];
  eval(['M= [' str '];'],'OK = 0;');
  if ~OK
    Textbox(str2mat('error in arrow definition:',' ',str,' ',transcode(lasterr)));
  elseif length(M) ~=1,
      Textbox(str2mat('error in arrow definition:',' ',str,'invalid length'));
  elseif min(M) <0 | max(M)>90,
      Textbox(str2mat('error in arrow definition:',' ',str,'invalid values'));
  else
    hps(4+P1)=M;
    set(har,'userdata',hps);
    Dhv_setc(6,har);
  end


elseif flag ==8,
  hfww = get(gco,'userdata');
  str = get(gco,'string');
  OK = 1;
  M = [];
  eval(['M= [' str '];'],'OK = 0;');
  if ~OK
    Textbox(str2mat('error in free definition:',' ',str,' ',transcode(lasterr)));
  elseif length(M) ~=1,
      Textbox(str2mat('error in free definition:',' ',str,'invalid length'));
  elseif min(M) <0,
      Textbox(str2mat('error in free definition:',' ',str,'invalid values'));
  else
    set(hfww,'linewidth',M);
  end

elseif flag ==9,
  if P1==1,
    Sstr = 'linewidth';
  else
    Sstr = 'markersize';
  end
  hfww = get(gco,'userdata');
  str = get(gco,'string');
  OK = 1;
  M = [];
  eval(['M= [' str '];'],'OK = 0;');
  if ~OK
    Textbox(str2mat('error in definition:',' ',str,' ',transcode(lasterr)));
  elseif length(M) ~=1,
      Textbox(str2mat('error in definition:',' ',str,'invalid length'));
  elseif min(M) <=0,
      Textbox(str2mat('error in definition:',' ',str,'invalid values'));
  else
    for tel = 1:length(hfww),
      set(hfww,Sstr,M);
    end
  end

elseif flag ==10,
  if P1==0;
    hangle = P2;
  elseif P1 == 2,
    hangle = get(gco,'userdata');
    minM=0;
    maxM=Inf;
  else
    hangle = gco;
    minM = -360;
    maxM = 360;
  end

  harc = get(hangle,'userdata');
  user = get(harc,'userdata');
  angle = user(7);
  dist = user(8);

  delete(harc); % verwijderen oude arcering

  if P1,

    str = get(gco,'string');
    OK = 1;
    M = [];
    eval(['M= [' str '];'],'OK = 0;');
    if ~OK
      Textbox(str2mat('error in definition:',' ',str,' ',transcode(lasterr)));
    elseif length(M) ~=1,
      Textbox(str2mat('error in definition:',' ',str,'invalid length'));
    elseif min(M) <= minM | max(M) >=maxM,
      Textbox(str2mat('error in definition:',' ',str,'invalid values'));
    end

    if P1==2
      dist =  M;
    else
      angle = M;
    end

  end
  % angel tussen -180 en 180 graden
  %twee lijnen
  harc = Arceer(user(1:2),user(3:4),user(5:6),dist,angle);
  set(harc,'userdata',[user(1:6) angle dist]);
  set(hangle,'userdata',harc);

end







