function PO1 = Dhv_colb(stage,P1,P2,P3,P4,P5)
%  Dhv_colb(stage,P1,P2,P3)
%
%  Kimtools for figures 1993-1996
%

% © Kim van Schagen, 1-Feb-96
if stage ==1,
  OK = Dis_zoom;
  if OK,
    hclb = Gcc;
    ha = gca;
    fig  = gcf;
    old = 0;
    %check for old legend axes
    h = get(fig,'children');
    for tel = 1:length(h),
      if strcmp(get(h(tel),'Type'),'axes'),
        user=get(h(tel),'userdata');
        if length(user) == 8,
          if strcmp(user(1:3),'Clb')
	    if (real(user(4))==ha),
              delete(h(tel));
              ax = get(ha,'units');
              set(ha,'units','normalized');
              set(ha,'position',user(5:8));
              set(ha,'units',ax);
            %  old = 1;
            %  gewoon doorgaan oude alleen verwijderen met Cancel
            end;
          end;
        end;
      end;
    end;
    % of is het actuele assenstelselegenda
    user = get(ha,'userdata');
    if length(user)==8,
      if strcmp(user(1:3),'Clb'),
        delete(ha)
      end
      ha = real(user(4));
      if ishandle(ha)
        ax = get(ha,'units');
        set(ha,'units','normalized');
        set(ha,'position',user(5:8));
        set(ha,'units',ax);
      else
        old = 1;
        ha = gca;
      end
    end;

    if old,
      Set_zoom
    else
      %maken colorbar figuur
      Dhv_colb(2,hclb,fig,ha)
    end
  end;
elseif stage ==2,
  % maken legenda figuur
  hclb = P1;
  fig = P2;
  ga = P3;
  Title = 'Colorbar';
  user = get(hclb,'userdata');
  Options = [1 2];
  if length(user)==2,
    Options = user(1:2);
  end;


  OK = Radiobox(str2mat('Right','Bottom','Left','Top'),'Position Colorbar',Options(1));

  if length(OK),
    Options(1)=OK;

    set(hclb,'userdata',Options);
    figure(fig);

    Dhv_colb(4,ga,fig,'',Options);
  else
    figure(fig);
  end;

  Set_zoom;

elseif stage == 4,
  ga = P1;
  fig = P2;
  titel = P3;
  options = P4; % voorkeuren

  ax = get(ga,'units');
  set(ga,'units','normalized');
  pos = get(ga,'position');
  opos=pos;

  dp = .9;

  cm = get(gcf,'colormap');

  ha = axes('units','normalized',...
         'box','on',...
         'visible','off',...
         'Xtick',[],...
         'Ytick',[],...
         'Xlim',[0 1],...
         'Ylim',[0 1],...
         'FontSize',0.7*get(0,'defaultaxesfontsize'));

  colax= get(ga,'clim');
  srf = (0:size(cm,1))/size(cm,1)*(colax(2)-colax(1))+colax(1);

  if options(2),
    ttick = Dhv_fixx(colax,5);
  else
    ttick = colax;
    ticklabel = ['min|max'];
    tickmod='manual';
    options(2) =0;
  end


  if options(1)==1 | options(1)==3, % rechts vert of links vert
    pos(3) = dp*opos(3);

    if options(1)==1,
      rp = opos(1)+opos(3);
      apos=[rp pos(2) 0.25*(1-dp)*opos(3) pos(4)];
    else
      pos(1)=pos(1)+(1-dp)*opos(3);
      rp = opos(1)-0.25*(1-dp)*opos(3);
      apos=[rp pos(2) 0.25*(1-dp)*opos(3) pos(4)];
    end

    set(ha,'position', apos, ...
           'xtick',[],...
           'ytick',ttick,...
           'xlim',[0 1],...
           'ylim',[min(srf) max(srf)]);

    title(titel);

    if ~options(2),
      set(ha,'yticklabels',ticklabel,...
             'yticklabelmode',tickmod)
    end

    [X,Y] = meshgrid([0 1],srf);
    surface('xdata',X,'ydata',Y,'zdata',zeros(size(Y)),'cdata',Y);
  end


  if options(1) == 2 | options(1)==4, % onder boven
    pos(4) = dp*opos(4);

    if options(1)==2,
      pos(2)=opos(2)+(1-dp)*opos(4);
      rp = opos(2)-0.25*(1-dp)*opos(4);
      apos = [pos(1) rp pos(3) 0.25*(1-dp)*opos(4)];
    else
      rp = opos(2)+opos(4)-0.25*(1-dp)*opos(4);
      apos = [pos(1) rp pos(3) 0.25*(1-dp)*opos(4)];
    end

    set(ha,'position',apos, ...
           'ytick',[],...
           'xtick',ttick,...
           'ylim',[0 1],...
           'xlim',[min(srf) max(srf)]);

    if options(1)==2,
      xlabel(titel);
    else
      title(titel);
    end

    if ~options(2),
      set(ha,'xticklabels',ticklabel,...
             'xticklabelmode',tickmod)
    end

    [X,Y] = meshgrid([0 1],srf);
    surface('xdata',Y,'ydata',X,'zdata',zeros(size(Y)),'cdata',Y);
  end

  set(ga,'position',pos);
  set(ga,'units',ax); % herstellen assen

  shading flat
  set(ha,'units','normalized',...
         'userdata',['Clb' ga opos]);
  set(ha,'visible','on');

  set(fig,'currentaxes',ga);

  PO1 = ha;
end

