function fig = Dhv_chfi(Title,nr);
%  set_chfi(Title,nr);
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95 

OK =0;
if nargout, %
  h = get(0,'children');
  if length(h);
    fig = gcf;
  else
    fig = 0;
  end;
else
  if nargin,
    [flags,fig_nr] = figflag(Title,1);
    if flags
      if length(find(fig_nr==nr)),
        OK =1;
        figure(nr);
      end;
    end;
  end

  if ~OK,
    dwn = get(gcf,'windowbuttondownfcn');
    mot = get(gcf,'windowbuttonmotionfcn');
    up  = get(gcf,'windowbuttonupfcn');
    key = get(gcf,'keypressfcn');
 
    if length(dwn),
      if dwn(1)=='%'
        set(gcf,'windowbuttondownfcn',dwn(2:length(dwn)));
      elseif length(findstr(dwn,'%')),
        [dummy,dwn]  =strtok(dwn,'%');
        set(gcf,'windowbuttondownfcn',dwn(2:length(dwn)));
      end;
    end;

    if length(mot),
      if mot(1)=='%'
        set(gcf,'windowbuttonmotionfcn',mot(2:length(mot)));
      elseif length(findstr(mot,'%')),
        [dummy,mot]  =strtok(mot,'%');
        set(gcf,'windowbuttonmotionfcn',mot(2:length(mot)));
      end;
    end;

    if length(up),
      if up(1)=='%'
        set(gcf,'windowbuttonupfcn',up(2:length(up)));
      elseif length(findstr(up,'%')),
        [dummy,up]  =strtok(up,'%');
        set(gcf,'windowbuttonupfcn',up(2:length(up)));
      end;
    end;

    if length(key),
      if key(1)=='%'
        set(gcf,'keypressfcn',key(2:length(key)));
      elseif length(findstr(key,'%')),
        [dummy,key]  =strtok(key,'%');
        set(gcf,'keypressfcn',key(2:length(key)));
      end;
    end;
  end;
end;

