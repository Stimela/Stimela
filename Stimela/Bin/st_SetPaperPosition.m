function st_SetPaperPosition(hfig)
% st_SetPaperPosition(hfig)
% set default position of the figure.
% if hfig ommitted -> set the default for new figures


s = get(0,'ScreenSize');
if s(3) == 1152
   bottom = 8;
elseif s(3) == 1024
   bottom = 4;
elseif s(3) == 800
   bottom = -5;
else
   bottom = 0;
end
pos =  [1 bottom s(3) 0.8*s(4)];


if nargin<1
  set(0,'DefaultFigurePosition',pos); 
%  set(0,'DefaultFigureNumberTitle','off');
  set(0,'DefaultFigurePaperOrientation','landscape');
  set(0,'DefaultFigurePaperUnits', 'centimeters');
  set(0,'DefaultFigurePaperPosition',[0.25 0.25 10.5 8]*2.54);
else
  set(hfig,'Position',pos); 
%  set(hfig,'NumberTitle','off');
  set(hfig,'PaperOrientation','landscape');
  set(hfig,'PaperUnits', 'centimeters');
  set(hfig,'PaperPosition',[0.25 0.25 10.5 8]*2.54);
end  