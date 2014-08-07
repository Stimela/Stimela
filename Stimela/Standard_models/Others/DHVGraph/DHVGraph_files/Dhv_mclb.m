function hcolb = Dhv_mclb(opties,titel);
%  hcolb = Dhv_mclb(opties,titel);
%
%  ha = handle resulterend assenstelsel
%  opties 1 - positie
%         2 - (0) aanduiding min/max (1) aanduiding waarden
%  titel naam bij colorbar
%
%  bij aanroep zonder argument wordt ie verwijdert
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95


% verwijderen oude versie
  ha = gca;
  fig  = gcf;

  h = get(fig,'children');
  for tel = 1:length(h),
    if strcmp(get(h(tel),'Type'),'axes'),
      user=get(h(tel),'userdata');
      if length(user) == 8,
        if strcmp(user(1:3),'Clb')
          if (abs(user(4))==ha),
              delete(h(tel));
              ax = get(ha,'units');
              set(ha,'units','normalized');
              set(ha,'position',user(5:8));
              set(ha,'units',ax);
          end;
        end;
      end;
    end;
  end
    % of is het actuele assenstelselegenda
    user = get(ha,'userdata');
    if length(user)==4,
      if strcmp(user(1:3),'Clb'),
        delete(ha)
      end
      ha = user(4);
      if ishandle(ha)
        ax = get(ha,'units');
        set(ha,'units','normalized');
        set(ha,'position',user(5:8));
        set(ha,'units',ax);
      else
        ha = gca;
      end
    end;


hcolb= [];
if nargin ~= 0 % alleen verwijderen
  if nargin < 2
    titel = '';
  end

  % aanmaken legende
  hcolb = Dhv_colb(4,ha,fig,titel,opties);

end

