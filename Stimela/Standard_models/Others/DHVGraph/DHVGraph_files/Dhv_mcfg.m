function Dhv_mcfg(stage,P1,P2,P3,P4,P5,P6,P7,P8,P9);
%  Dhv_mcfg(stage);
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

if stage ==1 & ~figflag('Configure MenuDHV',0),


  %inlezen huidige gegevens
  TextS = Dhv_defa(2.4);
  LineC = Dhv_defa(2.1);
  LineS = Dhv_defa(2.3);
  Name  = Dhv_defa(2.2);
  Line  = Dhv_defa(2.8);
  LineW = Line(1);
  Marker = Line(2);
  DotS  = Dhv_defa(2.5);
  Arrow = Dhv_defa(2.6);
  ArrowW = Arrow(1);
  ArrowS = Arrow(2);
  ArrowA = Arrow(3);
  FreeW  = Dhv_defa(2.7);
  Arc = Dhv_defa(2.9);
  ArcAngle = Arc(1);
  ArcDist = Arc(2);


  h_fig=figure('Menubar','none',...
          'NumberTitle','off',...
          'resize','off',...
          'Name','Configure MenuDHV',...
          'keypress', ' ',...
          'nextplot','new',...
          'visible','off');

  pos = get(h_fig,'position');

  axes('visible','off','units','normalized','position',[0 0 1 1],...
       'xlim',[0 1],'ylim',[0 1]);

  h = Gch(2);
  width = 400;
  heigth = 20*h;
  left = pos(1)+.5*(pos(3)-width);
  bottom = pos(2)+.5*(pos(4)-heigth);

  pos = [left bottom width heigth];
  set(h_fig,'position',pos);


  linestr = str2mat(' ','-','-.','--',':','x','o','*','+','.');
  colorstr = str2mat(' ','yellow','magenta','cyan','red','green','blue','white','black');
  ascolor = [1 1 0;1 0 1;0 1 1;1 0 0;0 1 0;0 0 1; 1 1 1; 0 0 0];

  % initvalues
  inits = ones(1,8);
  for tel = 1:size(LineS,1)
    for tel2 = 1:size(linestr,1)
      if strcmp(Delspace(LineS(tel,:)),Delspace(linestr(tel2,:)))
        inits(tel)=tel2;
      end
    end
  end

  initc = setstr(32*ones(8,14));
  initcc = ones(1,8);
  for tel = 1:size(LineC,1)
    initc(tel,:) = sprintf('%1.2f %1.2f %1.2f',LineC(tel,:));
    for tel2 = 1:size(ascolor,1)
      if all(LineC(tel,:)==ascolor(tel2,:))
        initc(tel,:) = sprintf('%1d     %1d     %1d ',ascolor(tel2,:));
        initcc(tel)=tel2+1;
      end
    end
  end


  % tien pull-down menus voor de lijnen en stylen
  for tel = 1:8,
    text(0.05,1.00-tel*.1,num2str(tel),'verticalalignment','mid','fontsize',12,'horizontalal','left');

    hls(tel) = line('xdata',[.21:.025:.29],'ydata',(1-tel*.1)* ones(4,1),...
                    'linewidth',LineW,'MarkerSize',Marker,'visible','off');
    if (inits(tel)~=1)
      set(hls(tel),'linestyle',linestr(inits(tel),:),'visible','on');
    end

    hs(tel) = uicontrol('units','normalized', ...
               'style','popup',...
               'position',[.1 .98-tel*.1 .1 .04],...
               'HorizontalAlignment','center',...
               'string',linestr,...
               'value',inits(tel),...
               'userdata',hls(tel),...
               'callback','Dhv_setc(1);');

    hlc(tel) = line('xdata',[.51 .59],'ydata',(1-tel*.1)* ones(2,1), ...
                    'linewidth',LineW,'visible','off');
    if (tel<=size(LineC,1))
      set(hlc(tel),'color',LineC(tel,:),'visible','on');
    end

    hc(tel) = uicontrol('units','normalized', ...
               'style','edit',...
               'position',[.3 .98-tel*.1 .2 .04],...
               'HorizontalAlignment','center',...
               'string',Delspace(initc(tel,:)),...
               'callback','Dhv_setc(2);');

    hcc(tel) = uicontrol('units','normalized', ...
               'style','popup',...
               'HorizontalAlignment','center',...
               'string',colorstr,...
               'position',[.3 .94-tel*0.1 .2 .04],...
               'value',initcc(tel),...
               'userdata',[hlc(tel) hc(tel)],...
               'Callback','Dhv_setc(3);');

    set(hc(tel),'userdata',[hlc(tel) hcc(tel)]);

  end

  %menuopties:
  text(0.6,0.9,'Menu:','verticalalignment','mid','fontsize',12,'horizontalal','left');

  %textgrootte
  text(0.6,0.85,'TextSize:','verticalalignment','mid','fontsize',12,'horizontalal','left');
  hts = text(0.9,0.85,'Aa','verticalalignment','mid','fontsize',TextS,'horizontalal','left');
  htss = uicontrol('units','normalized', ...
               'style','edit',...
               'position',[.75 .83 .1 .04],...
               'HorizontalAlignment','center',...
               'string',num2str(TextS),...
               'userdata',hts,...
               'callback','Dhv_setc(4);');
  % naam
  text(0.6,0.8,'Name:','verticalalignment','mid','fontsize',12,'horizontalal','left');
  hnm = uicontrol('units','normalized', ...
               'style','edit',...
               'position',[.75 .78 .2 .04],...
               'HorizontalAlignment','center',...
               'string',Name,...
               'callback',' ');

  text(0.6,0.75,'L.width:','verticalalignment','mid','fontsize',12,'horizontalal','left');
  hlw = line('xdata',[0.86 0.94],'ydata',[0.75 0.75],'linestyle','-','color',[1 1 1],'linewidth',LineW);
  hlww = uicontrol('units','normalized', ...
               'style','edit',...
               'position',[.75 .73 .1 .04],...
               'HorizontalAlignment','center',...
               'userdata',[hlw hlc hls],...
               'string',num2str(LineW),...
               'callback','Dhv_setc(9,1);');

  text(0.6,0.7,'M.size:','verticalalignment','mid','fontsize',12,'horizontalal','left');
  hms = line('xdata',0.9,'ydata',0.7,'linestyle','*','markersize',Marker,'color',[1 1 1]);
  hmss = uicontrol('units','normalized', ...
               'style','edit',...
               'position',[.75 .68 .1 .04],...
               'HorizontalAlignment','center',...
               'userdata',[hms hls],...
               'string',num2str(Marker),...
               'callback','Dhv_setc(9,2);');

  %menuopties:
  text(0.6,0.5,'Plot Tools:','verticalalignment','mid','fontsize',12,'horizontalal','left');

  %dotgrootte
  text(0.6,0.45,'DotSize:','verticalalignment','mid','fontsize',12,'horizontalal','left');
  hds = line('xdata',0.9,'ydata',0.45,'linestyle','.','markersize',DotS,'color',[1 1 1]);
  hdss = uicontrol('units','normalized', ...
               'style','edit',...
               'position',[.75 .43 .1 .04],...
               'HorizontalAlignment','center',...
               'string',num2str(DotS),...
               'userdata',hds,...
               'callback','Dhv_setc(5);');

  % pijl
  har = line('userdata',[0.9 0.9 0.3 0.4 ArrowW ArrowS ArrowA]);
  Dhv_setc(6,har);

  %pijlbreedte
  text(0.6,0.4,'A.width:','verticalalignment','mid','fontsize',12,'horizontalal','left');
  haw = uicontrol('units','normalized', ...
               'style','edit',...
               'position',[.75 .38 .1 .04],...
               'HorizontalAlignment','center',...
               'string',num2str(ArrowW),...
               'userdata',har,...
               'callback','Dhv_setc(7,1);');

  %pijlgrootte
  text(0.6,0.35,'A.size:','verticalalignment','mid','fontsize',12,'horizontalal','left');
  has = uicontrol('units','normalized', ...
               'style','edit',...
               'position',[.75 .33 .1 .04],...
               'HorizontalAlignment','center',...
               'string',num2str(ArrowS),...
               'userdata',har,...
               'callback','Dhv_setc(7,2);');

  %pijlhoek
  text(0.6,0.3,'A.angle:','verticalalignment','mid','fontsize',12,'horizontalal','left');
  hdss = uicontrol('units','normalized', ...
               'style','edit',...
               'position',[.75 .28 .1 .04],...
               'HorizontalAlignment','center',...
               'string',num2str(ArrowA),...
               'userdata',har,...
               'callback','Dhv_setc(7,3);');

  %Freewidth
  text(0.6,0.25,'Free:','verticalalignment','mid','fontsize',12,'horizontalal','left');
  hfw = line('xdata',[0.86 0.94],'ydata',[0.25 0.25],'linestyle','-','linewidth',FreeW,'color',[1 1 1]);
  hfww = uicontrol('units','normalized', ...
               'style','edit',...
               'position',[.75 .23 .1 .04],...
               'HorizontalAlignment','center',...
               'string',num2str(FreeW),...
               'userdata',hfw,...
               'callback','Dhv_setc(8);');

  %Arcerring
  harc = line('userdata',[.86 .95 .22 .22 .14 .14 ArcAngle ArcDist]);

  % hoek
  text(0.6,0.2,'// angle:','verticalalignment','mid','fontsize',12,'horizontalal','left');
  harca = uicontrol('units','normalized', ...
               'style','edit',...
               'position',[.75 .18 .1 .04],...
               'HorizontalAlignment','center',...
               'string',num2str(ArcAngle),...
               'userdata',harc,...
               'callback','Dhv_setc(10,1);');

  Dhv_setc(10,0,harca);

  % hoek
  text(0.6,0.15,'// dist.:','verticalalignment','mid','fontsize',12,'horizontalal','left');
  harcd = uicontrol('units','normalized', ...
               'style','edit',...
               'position',[.75 .13 .1 .04],...
               'HorizontalAlignment','center',...
               'string',num2str(ArcDist),...
               'userdata',harca,...
               'callback','Dhv_setc(10,2);');


  h_OK = uicontrol('Style','pushbutton',...
         'Units','normalized',...
         'position',[0.1 .03 .35 .06],...
         'HorizontalAlignment','center',...
         'String','OK',...
         'callback','Dhv_mcfg(2);');

  h_Esc = uicontrol('Style','pushbutton',...
         'Units','normalized',...
         'position',[0.55 .03 .35 .06],...
         'HorizontalAlignment','center',...
         'String','Cancel',...
         'Callback','close');

  set(h_fig,'userdata',[hts hls hlc hnm hds har hfw harca]);
  set(h_fig,'visible','on');

elseif stage ==2, % vullen commando
  hh = get(gcf,'userdata');
  hts = hh(1);
  hls = hh(2:9);
  hlc = hh(10:17);
  hnm = hh(18);
  hds = hh(19);
  har = hh(20);
  hfw = hh(21);
  harca = hh(22);

  TextS = get(hts,'fontsize');

  LineC = [];
  LineS = [];

  for tel = 1:8,
    if strcmp(get(hlc(tel),'visible'),'on'),
      c=sprintf('%1.2f %1.2f %1.2f',get(hlc(tel),'color'));
      if length(LineC)
        LineC = str2mat(LineC,c);
      else
        LineC = c;
      end;
    end
  end;

  for tel = 1:8,
    if strcmp(get(hls(tel),'visible'),'on'),
      if length(LineS)
        LineS = str2mat(LineS,get(hls(tel),'linestyle'));
      else
        LineS = get(hls(tel),'linestyle');
      end;
    end
  end;

  Name = get(hnm,'string');
  DotS = get(hds,'markersize');

  AllAr = get(har,'userdata');
  Arrow = AllAr(5:7);
  FreeW = get(hfw,'linewidth');

  Line = [get(hls(1),'linewidth') get(hls(1),'markersize')];
  user = get(get(harca,'userdata'),'userdata');
  Arc = user(7:8);

  close;
  Dhv_mcfg(3,TextS, LineC, LineS, Name, Line, DotS, Arrow, FreeW, Arc);

elseif stage == 3,
  TextS = P1;
  LineC = P2;
  LineS = P3;
  Name =strrep(P4,'''','''''');
  Line = P5;
  DotS = P6;
  Arrow = P7;
  FreeW = P8;
  Arc = P9;

  fid=fopen('Mdhvdefs.m','w');

  fprintf(fid,pr_str('% Mdhvdefs.m',1));
  fprintf(fid,pr_str('%',1));
  fprintf(fid,pr_str('%  Kimtools for figures 1993-1995',1));
  fprintf(fid,pr_str('%',1));
  fprintf(fid,pr_str('% Do not alter the names of the variables.',1));
  fprintf(fid,pr_str(' ',1));
  fprintf(fid,pr_str('% © Kim van Schagen, 1-Aug-95 ',1));
  fprintf(fid,pr_str(' ',1));
  fprintf(fid,pr_str('%% Text',1));
  fprintf(fid,pr_str('  % Standard text size',1));
  fprintf(fid,pr_str('  % Default : TextSize = 10;',1));
  fprintf(fid,pr_str(' ',1));

  fprintf(fid,pr_str('  TextSize = '));
  fprintf(fid,'%10.1f',TextS);
  fprintf(fid,pr_str(';',1));

  fprintf(fid,pr_str(' ',1));
  fprintf(fid,pr_str('%% Lines:',1));
  fprintf(fid,pr_str('  % Standard color order',1));
  fprintf(fid,pr_str('  % Default : LineColorOrder = get(0,''defaultaxescolororder'');',1));
  fprintf(fid,pr_str(' ',1));

  fprintf(fid,pr_str('  LineColorOrder = [',1));
  for tel = 1:size(LineC,1)
    fprintf(fid,pr_str(['                 ' LineC(tel,:)],1));
  end
  fprintf(fid,pr_str('                               ];',1));

  fprintf(fid,pr_str(' ',1));
  fprintf(fid,pr_str('  % Standard styles',1));
  fprintf(fid,pr_str('  % Default : LineStyleOrder = str2mat(''- '',''-.'',''--'','':'');',1));
  fprintf(fid,pr_str(' ',1));

  fprintf(fid,pr_str('  LineStyleOrder = [',1));
  for tel = 1:size(LineS,1)
    fprintf(fid,pr_str(['                ''' LineS(tel,:) ''''],1));
  end
  fprintf(fid,pr_str('                               ];',1));

  fprintf(fid,pr_str(' ',1));
  fprintf(fid,pr_str('%% DHV:',1));
  fprintf(fid,pr_str('  % Standard name',1));
  fprintf(fid,pr_str('  % Default : Name = ''Enter your own name here'';',1));
  fprintf(fid,pr_str(' ',1));

  fprintf(fid,pr_str('  Name = '));
  fprintf(fid,pr_str(['''' Name ''';'],1));

  fprintf(fid,pr_str(' ',1));
  fprintf(fid,pr_str('%% Line:',1));
  fprintf(fid,pr_str('  % Standard Line width',1));
  fprintf(fid,pr_str('  % Default : LineWidth = 0.5;',1));
  fprintf(fid,pr_str(' ',1));

  fprintf(fid,pr_str('  LineWidth = '));
  fprintf(fid,'%10.1f',Line(1));
  fprintf(fid,pr_str(';',1));

  fprintf(fid,pr_str(' ',1));
  fprintf(fid,pr_str('  % Standard Marker size',1));
  fprintf(fid,pr_str('  % Default : MarkerSize = 6;',1));
  fprintf(fid,pr_str(' ',1));

  fprintf(fid,pr_str('  MarkerSize = '));
  fprintf(fid,'%10.1f',Line(2));
  fprintf(fid,pr_str(';',1));

  fprintf(fid,pr_str(' ',1));
  fprintf(fid,pr_str('%% Dot:',1));
  fprintf(fid,pr_str('  % Standard dot size',1));
  fprintf(fid,pr_str('  % Default : DotSize = 15;',1));
  fprintf(fid,pr_str(' ',1));

  fprintf(fid,pr_str('  DotSize = '));
  fprintf(fid,'%10.1f',DotS);
  fprintf(fid,pr_str(';',1));

  fprintf(fid,pr_str(' ',1));
  fprintf(fid,pr_str('%% Arrow:',1));
  fprintf(fid,pr_str('  % Standard linewidth',1));
  fprintf(fid,pr_str('  % Default : ArrowWidth = get(0,''defaultlinelinewidth'');',1));
  fprintf(fid,pr_str(' ',1));

  fprintf(fid,pr_str('  ArrowWidth = '));
  fprintf(fid,'%10.1f',Arrow(1));
  fprintf(fid,pr_str(';',1));

  fprintf(fid,pr_str(' ',1));
  fprintf(fid,pr_str('  % Standard size of the arrowhead',1));
  fprintf(fid,pr_str('  % Default : ArrowSize = 10;',1));
  fprintf(fid,pr_str(' ',1));

  fprintf(fid,pr_str('  ArrowSize = '));
  fprintf(fid,'%10.1f',Arrow(2));
  fprintf(fid,pr_str(';',1));

  fprintf(fid,pr_str(' ',1));
  fprintf(fid,pr_str('  % Standard angle of the arrowhead',1));
  fprintf(fid,pr_str('  % Default : ArrowAngle = 30;',1));
  fprintf(fid,pr_str(' ',1));

  fprintf(fid,pr_str('  ArrowAngle = '));
  fprintf(fid,'%10.1f',Arrow(3));
  fprintf(fid,pr_str(';',1));

  fprintf(fid,pr_str(' ',1));
  fprintf(fid,pr_str('%% Free',1));
  fprintf(fid,pr_str(' % Standard linewidth,',1));
  fprintf(fid,pr_str(' % Default : FreeWidth = get(0,''defaultlinelinewidth'');',1));
  fprintf(fid,pr_str(' ',1));

  fprintf(fid,pr_str('  FreeWidth = '));
  fprintf(fid,'%10.1f',FreeW);
  fprintf(fid,pr_str(';',1));

  fprintf(fid,pr_str(' ',1));
  fprintf(fid,pr_str('%% Arcering',1));
  fprintf(fid,pr_str(' % Arc Angle,',1));
  fprintf(fid,pr_str(' % Default : ArcAngle=45',1));
  fprintf(fid,pr_str(' ',1));

  fprintf(fid,pr_str('  ArcAngle = '));
  fprintf(fid,'%10.2f',Arc(1));
  fprintf(fid,pr_str(';',1));

  fprintf(fid,pr_str(' ',1));
  fprintf(fid,pr_str(' % distance arcering,',1));
  fprintf(fid,pr_str(' % Default : ArcDist = 20',1));
  fprintf(fid,pr_str(' ',1));

  fprintf(fid,pr_str('  ArcDist = '));
  fprintf(fid,'%10.2f',Arc(2));
  fprintf(fid,pr_str(';',1));

  fprintf(fid,pr_str(' ',1));

  fclose(fid);

  clear Mdhvdefs.m

elseif stage ==4,
  %update
  % color
  Dhv_mcfg(4.1)
  %style
  Dhv_mcfg(4.2)
  % legenda's
  Dhv_mcfg(4.3)
  % pijl groottes
  Dhv_mcfg(4.4)
elseif stage == 4.1 % color
  Dhv_colo;
  Dhv_colo;
elseif stage == 4.2 % style
  Dhv_styl;
  Dhv_styl;
elseif stage == 4.3 % legenda's
  Dhv_mleg(' ','u');
elseif stage == 4.4 % arrow
  Dhv_pupd(2);


  
end
