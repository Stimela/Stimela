function Set_zoom(dummy);
%  Set_zoom(dummy);
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95 

dwn = get(gcf,'WindowButtonDownFcn');
mot = get(gcf,'WindowButtonmotionFcn');
l1 = length(dwn);
l2 = length(mot);
if l1,
  if dwn(1) == '%',
    set(gcf,'WindowButtonDownFcn',dwn(2:l1));
  elseif length(findstr(dwn,'%')),
    [dummy,dwn] = strtok(dwn,'%');
    set(gcf,'WindowButtonDownFcn',dwn(2:length(dwn)));
  end
end
if l2,
  if mot(1) == '%',
    set(gcf,'WindowButtonmotionFcn',mot(2:l2));
  elseif length(findstr(mot,'%')),
    [dummy,mot] = strtok(mot,'%');
    set(gcf,'WindowButtonmotionFcn',mot(2:length(mot)));
  end
end



