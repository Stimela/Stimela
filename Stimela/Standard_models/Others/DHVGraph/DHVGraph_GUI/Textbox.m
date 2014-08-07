function Textbox(Text,Title)
% Textbox(Text,Title);
% Automatisch produceren van een Textbox
% afgesloten wordt na afloop met OK
% Ook kan afgesloten worden met Enter
%
% Text = een matrixstring met evenveel regels als opties
% Title = de titel van de Textbox

% © Kim van Schagen, 1-Aug-95


if nargin <2,
  Title ='';
end;

[m,n] = size(Text);
nT = length(Title);

n = max([n nT 15]);

% Size Box

h_fig=figure('Menubar','none',...
        'NumberTitle','off',...
        'resize','off',...
        'Name',Title,...
        'visible','off');%, ...
%        'windowstyle','modal');

h = Gch(2);
screen = get(0, 'ScreenSize');
width = 8*n;
heigth = (m+2)*h/.7;
left = screen(1)+max([floor(.5*(screen(3)-width))  0]);
bottom = screen(2)+max([floor(.5*(screen(4)-heigth))  0]);
pos = [left bottom width heigth];

bkgrnd = get(gcf,'color');
bkgrnd = (bkgrnd == .5)*.5+bkgrnd;

h = [];
for tel= 1 : m,
  h(tel) = uicontrol('Style','text',...
     'Units','normalized',...
     'Position',[0.1 0.9-.8/(m+2)*tel .8 .7/(m+2)],...
     'HorizontalAlignment','left',...
     'backgroundcolor',bkgrnd,...
     'foregroundcolor',[1 1 1] - bkgrnd,...
     'String',Text(tel,:));
end;

h_OK = uicontrol('Style','pushbutton',...
  'Units','normalized',...
  'position',[0.1 .1 .8 .7/(m+2)],...
  'HorizontalAlignment','center',...
  'String','OK' ,...
  'CallBack','close(gcf)');

set(h_fig,'position',pos,'visible','on');

% zolang h_fig bestaat bestaat de edit box
while ishandle(h_fig)
  drawnow
end



