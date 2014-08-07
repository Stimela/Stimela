function radiobox_result = Radiobox(Text,Title,initvalue)
% radiobox_result = Radiobox(Text,Title,Initvalue);
% Automatisch produceren van een serie radioboxes
% afgesloten wordt na afloop met OK of Cancel
% Ook kan afgesloten worden met Enter of Escape respectievelijk
%
% Text = een matrixstring met evenveel regels als opties
% Title = de titel van de Radiobox
% Initvalue = initiele waarde (nr van optie);
%
% in radiobox_result komt het resultaat :
% radiobox_result is n als nde optie aangeklikt
% radiobox_result is leeg als Cancel of Escape gekozen is.

% © Kim van Schagen, 1-Aug-95


if (nargin <3),
  initvalue = 1;
end;
if nargin <2,
  Title ='';
end;

if (size(Text,1)<initvalue|initvalue<1),
  initvalue = 1;
end;
[m,n] = size(Text);
nT = length(Title);

n = max([n nT 15]);

h_fig=figure('Menubar','none',...
        'NumberTitle','off',...
        'resize','off',...
        'Name',Title,...
        'visible','off');

h = Gch(2);
screen = get(0, 'ScreenSize');
width = 10*n+20;
heigth = (m+2)*h/.7;
left = screen(1)+max([floor(.5*(screen(3)-width))  0]);
bottom = screen(2)+max([floor(.5*(screen(4)-heigth))  0]);
pos = [left bottom min([width screen(3)]) min([heigth screen(4)])];


bkgrnd = get(h_fig,'color');
bkgrnd = (bkgrnd == .5)*.5+bkgrnd;

h = [];
for tel= 1 : m,
  h(tel) = uicontrol('Style','radiobutton',...
     'Units','normalized',...
     'Position',[0.1 0.9-.8/(m+2)*tel .8 .7/(m+2)],...
     'HorizontalAlignment','left',...
     'backgroundcolor',bkgrnd,...
     'foregroundcolor',[1 1 1] - bkgrnd,...
     'String',Text(tel,:));

end;
set(h(initvalue),'Value',1);
set(h_fig,'userdata',h);

h_OK = uicontrol('Style','pushbutton',...
  'Units','normalized',...
  'position',[0.1 .1 .35 .7/(m+2)],...
  'HorizontalAlignment','center',...
  'String','OK');

h_OK = uicontrol('Style','pushbutton',...
  'Units','normalized',...
  'position',[0.55 .1 .35 .7/(m+2)],...
  'HorizontalAlignment','center',...
  'String','Cancel');

set(h_fig,'position',pos,'visible','on');

OK = Holdfigr([0.1 .1 .35 .7/(m+2);0.55 .1 .35 .7/(m+2)]);

if abs(OK) == 1,
  for tel = 1:length(h),
    if get(h(tel),'value'),
      radiobox_result = tel;
    end;
  end;
else
  radiobox_result = [];
end;

close(h_fig);

