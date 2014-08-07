function dhv_sizf(fig)
%zet op standaard formaat
if nargin <1
  fig = gcf;
end

set(fig,'paperpositionmode','manual');
set(fig,'paperposition',get(0,'defaultfigurepaperposition'));
