function Dhv_dplo(stage,P1)
%  Dhv_dplo(stage)
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

if stage ==1,
  if all(get(gca,'view') == [0 90]);
    OK = Dis_zoom;
    if OK,
      h = get(gca,'children');
      OK=0;
      tel = 0;
      while tel < length(h),
        tel=tel+1;
        if strcmp(get(h(tel),'userdata'),'userplot'),
          OK = 1;
          tel = length(h);
        end;
      end;

      if OK,
        s2 = get(gcf,'pointer');
        set(gcf,'pointer','arrow');
        dwn = get(gcf,'windowbuttondownfcn');
        set(gcf,'windowbuttondownfcn',['Dhv_dplo(2,''' s2 ''')' dwn]);

        qm = Gcq;
        set(qm,'userdata',get(qm,'label'));
        set(qm,'label',':Erase Addon');
      else
        Set_zoom
      end
    end;
  end;

elseif stage ==2,
  point = get(gca,'currentpoint');
  p = (point(1,:)+point(2,:))/2;
  h = get(gca,'children');
  telp = [];
  ps = -1*ones(length(h),1);
  for tel = 1:length(h),
    if strcmp(get(h(tel),'userdata'),'userplot'),
      if strcmp(get(h(tel),'type'),'line')
        x = get(h(tel),'xdata');
        y = get(h(tel),'ydata');
      elseif strcmp(get(h(tel),'type'),'text')
        pl = get(h(tel),'position');
        x = pl(1);
        y = pl(2);
      end
      % alle NaN en Inf tellen niet mee
      n = find(isnan(x) | isnan(y));
      x(n)=[];
      y(n)=[];
      if size(x)
        ps(tel) = sum( ([mean(x) mean(y) 0]-p).^2);
        telp = [telp tel];
      end
    end;
  end;
  if find(ps>=0),
    cl = find(ps==min(ps(telp)));

    % hier moet nog een vraagje !!

    delete(h(cl));
  end;

  set(Gcq,'label',get(Gcq,'userdata'));
  set(gcf,'pointer',P1);
  Set_zoom;

end;


