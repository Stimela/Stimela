function he=Uiedhv(obj,uitvoer,initstr,pos,userdata,saveobj)
%  Uiedhv(obj,uitvoer,initstr)
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

if nargin < 3
  initstr = '';
end;
if nargin < 4,
  po = get(obj,'position');
  pos = [min([po(1)+po(3) 0.5]) po(2) .5-po(3) po(4)];
end;
if nargin <5,
  userdata = [];
end;

if nargin<6,
  saveobj =0;
end


str = get(obj,'userdata');
strmat = Transcod(str,1);
if (isempty(strmat))
   strmat = 'initstr';
end
h = Gch(2); %hoogte in pixels;

he = uicontrol('Style','edit','Units','normalized', ...
          'position',pos, ...
          'HorizontalAlignment','center', ...
          'String',initstr,...
          'backgroundcolor',[.75 .75 .75], ...
          'Callback',['Uiedset(2,' num2str(saveobj) ');' uitvoer]);

set(he,'units','pixels');
pos = get(he,'position');
set(he,'position',[pos(1) pos(2)+pos(4)-h pos(3) h]);

hp = uicontrol('Style','popup','Units','pixels', ...
          'position',[pos(1) pos(2)+pos(4)-2*h pos(3) h], ...
          'HorizontalAlignment','center', ...
          'String',strmat,...
          'backgroundcolor',[.75 .75 .75], ...
          'Callback','Uiedset(1);');

set(he,'userdata',[hp obj userdata]);
set(hp,'userdata',he);


