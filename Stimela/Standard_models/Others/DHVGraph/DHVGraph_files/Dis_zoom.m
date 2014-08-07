function OK=Dis_zoom(flag),
%  OK=Dis_zoom(flag),
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95 

dwn = get(gcf,'WindowButtonDownFcn');
mot = get(gcf,'windowbuttonmotionfcn');
OK = 0;
if (length(findstr(dwn,'%'))==0),
  set(gcf,'WindowButtonDownFcn',['%' dwn]);
  set(gcf,'windowbuttonmotionfcn',['%' mot]);
  OK = 1;
end;


