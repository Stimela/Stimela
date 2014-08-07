function Dhv_prin(nr,P1),
%  Dhv_prin(nr),
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

if nargin <1
  nr =0;
end

OK = Dis_zoom;
if OK,
  if (nr == 0)
    hprint = Gcp;

    userdata = get(hprint,'userdata');
    if length(userdata)>4,
      sel = abs(userdata(5));
    else
      sel = 1;
    end;
    nr = Radiobox(str2mat('Windows driver',...
                        'Windows driver (color)',...
                        'Windows driver to File',...
                        'Windows driver (color) to File',...
                        'Windows Meta to Clipboard',...
                        'WP (hpgl) to File',...
                        'Laserjet III'),'Print menu',sel);
    if length(nr)
      userdata(5) = nr;
      set(hprint,'userdata',userdata);
    end
  end


  if length(nr)

    ga = gca;

    %put legends on top
    h = get(gcf,'children');
    for tel = 1:length(h),
      if strcmp(get(h(tel),'Type'),'axes'),
        user=get(h(tel),'userdata');
        if length(user) == 4,
          if strcmp(user(1:3),'Leg')
            set(gcf,'currentaxes',h(tel));
          end;
        end;
      end;
    end;


    if nr == -1,
      eval(['print ' P1],'disp(''error in print string'')');
    elseif nr == 1,
      print -dwin -v
    elseif nr == 2,
      print -dwinc -v
    elseif nr == 3,
      [filenm,pathnm] = uiputfile('*.*','Print: filename');
      if filenm,
        eval(['print -dwin ' pathnm filenm ])
      end;
    elseif nr == 4,
      [filenm,pathnm] = uiputfile('*.*','Print: filename');
      if filenm,
        eval(['print -dwinc ' pathnm filenm ])
      end;
    elseif nr == 5,
      print -dmeta
    elseif nr == 6,
      [filenm,pathnm] = uiputfile('*.hpg','Print: hpgl file');
      if filenm,
        eval(['print -dhpgl ' pathnm filenm ])
      end;
    elseif nr == 7,
      print -dljet3
    end;
    set(gcf,'position',get(gcf,'position'));
    set(gcf,'currentaxes',ga);
  end
  Set_zoom
end;


