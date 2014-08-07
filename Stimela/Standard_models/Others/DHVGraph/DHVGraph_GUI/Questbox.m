function OK=Questbox(Text,Title)
% OK=Questbox(Text,Title);
% Automatisch produceren van een question-box
% afgesloten wordt na afloop met OK of Cancel
% Ook kan afgesloten worden met Enter of Escape
% Ok is 1 als is afgesloten met Enter of OK en 0 als is
% afgesloten met Cancel of Escape
%
% Text = een matrixstring met evenveel regels
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
        'visible','off', ...
        'windowstyle','modal');

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
  'position',[0.1 .1 .3 .7/(m+2)],...
  'HorizontalAlignment','center',...
  'String','OK', ...
  'callback','delete(gco)');

h_Esc = uicontrol('Style','pushbutton',...
  'Units','normalized',...
  'position',[0.6 .1 .3 .7/(m+2)],...
  'HorizontalAlignment','center',...
  'String','Cancel', ...
  'callback','delete(gco)');


set(h_fig,'position',pos,'visible','on');

while ishandle(h_OK) & ishandle(h_Esc)
  drawnow;
end

% omzetten zodat 1 = OK en 0=Esc
if ishandle(h_Esc)
  OK = 1;
else
  OK = 0;
end

if ishandle(h_fig)
  delete(h_fig)
end

