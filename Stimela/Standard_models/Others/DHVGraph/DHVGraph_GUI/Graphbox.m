function Graphbox(x,y,Title)
% Graphbox(x,y,Title);
% Automatisch produceren van een Graphbox
% afgesloten wordt na afloop met OK
% Ook kan afgesloten worden met Enter
%
% x,y waarden
% Title = de titel van de Graphbox

% © Kim van Schagen, 1-Aug-95


if nargin <3,
  Title ='';
end;


% Size Box

h_fig=figure('Menubar','none',...
        'NumberTitle','off',...
        'resize','off',...
        'Name',Title,...
        'visible','off')%, ...
%        'windowstyle','modal');

h = Gch(2);
screen = get(0, 'ScreenSize');
width = .4;
heigth = .4;
left = screen(1)+max([floor( (.5-.5*width)*screen(3))  0]);
bottom = screen(2)+max([floor( (.5-.5*heigth)*screen(4))  0]);
pos = [left bottom width*screen(3) heigth*screen(4)];

set(h_fig,'position',pos)

axes('pos',[0.13 0.11+0.1 0.775 0.815-0.1])
plot(x,y);

bkgrnd = get(gcf,'color');
bkgrnd = (bkgrnd == .5)*.5+bkgrnd;

h_OK = uicontrol('Style','pushbutton',...
  'Units','normalized',...
  'position',[0.1 .05 .8 Gch],...
  'HorizontalAlignment','center',...
  'String','OK', ...
  'CallBack','close(gcf)');


set(h_fig,'visible','on');

while ishandle(h_fig)
 drawnow
end
