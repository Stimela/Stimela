function hret = Uidhv(plek,opschrift,uitvoer,kenmerk)
%  Uidhv(plek,opschrift,uitvoer,kenmerk)
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

if nargin < 4,
  kenmerk = '';
end;

h = uicontrol('Style','pushbutton','Units','normalized', ...
          'position',plek,'HorizontalAlignment','center', ...
          'String',opschrift,'Callback',uitvoer, ...
          'userdata',kenmerk);

if nargout ~=0,
  hret = h;
end

