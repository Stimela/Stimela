function ht = Uitdhv(plek,opschrift,userdata)
%  Uitdhv(plek,opschrift,userdata)
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

if nargin < 3,
  userdata = '';
end;

ht = uicontrol('Style','text','Units','normalized', ...
         'position',plek,'HorizontalAlignment','center', ...
          'String',opschrift,'userdata',userdata);

