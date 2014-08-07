function PO1 = Dhv_lege(stage,P1,P2,P3,P4)
%  Dhv_lege(stage,P1,P2,P3)
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95
if stage ==1,
  OK = Dis_zoom;
  if OK,
    old = 0;
    hleg = Gcl;
    ha = gca;
    fig  = gcf;
    %check for old legend axes
    h = get(fig,'children');
    for tel = 1:length(h),
      if strcmp(get(h(tel),'Type'),'axes'),
        user=get(h(tel),'userdata');
        if length(user) == 4,
          if strcmp(user(1:3),'Leg')
            if real(user(4))==ha,
              delete(h(tel));
            %  old = 1;
            % nu kan je gewoon verder. Bij Cancel is hij gewoon erased
            end;
          end;
        end;
      end;
    end;
    % of is het actuele assenstelselegenda
    user = get(ha,'userdata');
    if length(user)==4,
      if strcmp(user(1:3),'Leg'),
        delete(ha)
        if ishandle(real(user(4)))
          set(fig,'currentaxes',real(user(4)));
          ha = real(user(4));
        else
          old = 1;
          ha = gca;
        end
      end
    end;

    if old,
      Set_zoom
    else
      hline = [];
      h = get(ha,'children');
      telline = 0;
      for tel = length(h):-1:1,
        if strcmp(get(h(tel),'type'),'line'),
          hline = [hline;h(tel)];
        end;
      end;

      if size(hline,1)
        %maken legenda figuur
        Dhv_lege(2,hline,hleg,fig)
      else
        Set_zoom
      end
    end
  end;
elseif stage ==2,
  % maken legenda figuur
  hline = P1;
  hleg = P2;
  fig = P3;
  Title = 'Legenda';
  user = get(hleg,'userdata');
  Default = setstr(32*ones(length(hline),1));

  if length(user)>0,
    hold = real(user(2:1+user(1) ));
    old = Transcod(user(1+user(1)+1:length(user) ),1);
    for tel = 1:user(1),
      plek = find(hold(tel)==hline);
      hold(tel)=-1;
      if length(plek),
        Default(plek,1:length(Delspace(old(tel,:)))) = Delspace(old(tel,:));
      end;
    end;
  end;

  m = size(hline,1);
  n = size(Default,2);
  n = 2*n;

  Set_zoom;
  h_fig=figure('Menubar','none',...
          'NumberTitle','off',...
          'resize','off',...
          'visible','off',...
          'keypress',' ',...
          'Name',Title);


  Dhv_filf(fig,Title,h_fig);

  % Size Box
  h = Gch(2);
  fx = get(fig,'units');
  set(fig,'units','pixels');
  screen = get(fig, 'position');
  set(fig,'units',fx);

  width = max([200 16*n+30]);
  heigth = (m+2)*h/.7;
  left = screen(1)+floor(.5*screen(3)-width/2);
  bottom = screen(2)+floor(.5*screen(4)-heigth/2);

  pos = [left bottom width heigth];
  bkgrnd = get(fig,'color');
  bkgrnd = (bkgrnd == .5)*.5+bkgrnd;

  for tel= 1 : m,
     axes('XLim',[0 1],...
          'Ylim',[0 1],...
          'Units','normalized',...
          'Position',[0.05 0.9-.8/(m+2)*tel .2 .7/(m+2)],...
          'Visible','off');

     lnst = get(hline(tel),'linestyle');
     nxd  = length(get(hline(tel),'xdata'));

     if any(lnst(1)=='+o*x.') & nxd==1,
       xd = .5;
     else
       xd = 0:.25:1;
     end

     line('XData',xd,...
          'YData',.5*ones(size(xd)),...
          'LineStyle',get(hline(tel),'LineStyle'),...
          'Linewidth',get(hline(tel),'Linewidth'),...
          'Markersize',get(hline(tel),'Markersize'),...
          'Color',get(hline(tel),'Color'));
  end;

  for tel= 1 : m,
     uicontrol('Style','text',...
               'Units','normalized',...
               'Position',[0.25 0.9-.8/(m+2)*tel .05 .7/(m+2)],...
               'HorizontalAlignment','left',...
               'backgroundcolor',bkgrnd,...
               'foregroundcolor',[1 1 1]-bkgrnd,...
               'String',':' );
  end;


  h = [];
  for tel= 1 : m,
    h(tel) = uicontrol('Style','edit',...
               'Units','normalized',...
               'Position',[0.35 0.9-.8/(m+2)*tel .6 .7/(m+2)],...
               'HorizontalAlignment','right');
    set(h(tel),'String',Delspace(Default(tel,:)));
  end;

  h_OK = uicontrol('Style','pushbutton',...
         'Units','normalized',...
         'position',[0.35 .1 .25 .7/(m+2)],...
         'HorizontalAlignment','center',...
         'String','OK',...
         'Callback', ['Dhv_lege(3,gcf,1,' int2str(fig) ');']);

  h_Esc = uicontrol('Style','pushbutton',...
         'Units','normalized',...
         'position',[0.7 .1 .25 .7/(m+2)],...
         'HorizontalAlignment','center',...
         'String','Cancel',...
         'Callback', ['Dhv_lege(3,gcf,0,' int2str(fig) ' );']);

  set(h_fig,'position',pos,'visible','on');
  set(h_fig,'userdata',[m h hleg hline']);

elseif stage ==3,
  % na sluiten van een figuur
  h_fig = P1;
  OK = P2;
  fig = P3;

  h = get(h_fig,'userdata');

  if OK,
    result = [];
    hline = [];
    tel =0;
    % eerst de oude handles
    allhs = h(h(1)+2+(1:h(1)));
    %weggooien van niet gevulde handles
    while tel<h(1);
      tel = tel+1;
      r = Delspace(get(h(tel+1),'string'));
      if length(r),
        hline = [hline h(h(1)+2+tel)];
        if ~size(result,1),
          result = get(h(tel+1),'string');
        else
          result = str2mat(result,get(h(tel+1),'string'));
        end
      end
    end;
    hleg = h(h(1)+2);
    close % sluiten van legenda box

    % vullen van de legenda button
    Dhv_lege(3.1,hline,result,allhs)

    figure(fig);
    Dhv_chfi; % herstellen figuur

    ga = gca;
    if length(hline),
      % maken assenstelsel
      ha = Dhv_lege(4,ga,fig,hline,result);
      % plaatsen
      if length(Gcz),
      Dhv_move(0)
      Dhv_move(1,1,ha)

      up = get(gcf,'windowbuttonupfcn');
      set(gcf,'windowbuttondownfcn',up)
%      set(gcf,'windowbuttonupfcn','')
      end

    end % van check lengte

  else
    close
    figure(fig);
    Dhv_chfi;
  end;


elseif stage ==3.1
    hline = P1;
    result=P2;
    allhs = P3;

    hleg = Gcl;

    %oude legenda's ook bewaren
    user = get(hleg,'userdata');
    hold=[];
    old=[];
    if length(user)>1,
      hold = real(user(2:1+user(1) ));
      old = Transcod(user(1+user(1)+1:length(user) ),1);
      for tel = 1:user(1),
        if length(find(hold(tel)==allhs))
          hold(tel)=-1;
        end
      end;
      old(find(hold==-1),:)=[];
      hold(find(hold==-1))=[];
    end;
    if length(hold)>0
      hlleg = [hline hold];
      leg = str2mat(result,old);
    else
      hlleg=hline;
      leg=result;
    end

    strleg = [length(hlleg) hlleg double(Transcod(leg,1))];
    set(hleg,'userdata',strleg);

elseif stage == 4,
  ga = P1;
  fig = P2;
  hline = P3;
  result = P4;

  ax = get(ga,'units');
  set(ga,'units','pixels');
  pos = get(ga,'position');
  set(ga,'units',ax);

  bkgrnd = get(fig,'color');

  [m,n] = size(result);

  hh = Gch(2);
  hor = min([50 .9*pos(3)]);
  ver = min([hh*(m+.2)*10/12 .9*pos(4)]);
  ha = axes('units','pixels',...
         'position',[pos(1)+.95*pos(3)-hor pos(2)+.95*pos(4)-ver hor ver],...
         'box','on',...
         'visible','off',...
         'Xtick',[],...
         'Ytick',[],...
         'Xlim',[0-.1 1+.1],...
         'Ylim',[1-.1 m+1+.1],...
         'color',bkgrnd,...
         'userdata',[double('Leg') ga]);

  for tel = 1:length(hline);
    lnst = get(hline(tel),'linestyle');
    nxd  = length(get(hline(tel),'xdata'));
    if any(lnst(1)=='+o*x.') & nxd==1,
      xd = .5*30/50;
    else
      xd = 0:.25:1*30/50;
    end

    line('XData',xd,...
           'YData',(m+.5-(tel-1))*ones(size(xd)),...
           'Linestyle',get(hline(tel),'Linestyle'),...
           'Linewidth',get(hline(tel),'Linewidth'),...
           'Markersize',get(hline(tel),'Markersize'),...
           'Color',get(hline(tel),'Color'));

    ht= text(40/50,m+.5-(tel-1),result(tel,:),...
           'verticalal','middle',...
           'horizontalal','left',...
           'fontsize',10,...
           'fontname','helvetica');
         ext(tel,:) = get(ht,'extent');
  end;
  hort = max(ext(:,3));
  if hor > 10/50,
    over = hort-10/50;
    hor = min([over*50+50 .9*pos(3)]);
    set(ha,...
           'position',[pos(1)+.95*pos(3)-hor pos(2)+.95*pos(4)-ver hor ver],...
           'xlim',[0-.1 1+.1+over],...
           'visible','on');
  else
    set(ha,'visible','on');
  end
  set(ha,'units','normalized');
  set(fig,'currentaxes',ga);

  PO1 = ha;
end



