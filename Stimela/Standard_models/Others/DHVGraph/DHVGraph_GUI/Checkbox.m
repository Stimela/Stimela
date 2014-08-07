function checkbox_result = Checkbox(Text,Title,initvalue)
% checkbox_result = Checkbox(Text,Title,Initvalue);
% Automatisch produceren van een serie checkboxes
% afgesloten wordt na afloop met OK of Cancel
% Ook kan afgesloten worden met Enter of Escape respectievelijk
%
% Text = een matrixstring met evenveel regels als opties
% Title = de titel van de Checkbox
% Initvalue = vector van initiele waarden (0 of 1 per optie);
%
% in de vector checkbox_result komt het resultaat :
% checkbox_result(n)  is 1 als de nde optie aangeklikt is en anders 0
% checkbox_result is leeg als Cancel of Escape gekozen is.

% © Kim van Schagen, 1-Aug-95


if (nargin <3),
  initvalue = zeros(1,size(Text,1));
end;
if nargin <2,
  Title ='';
end;

if (size(Text,1)~=length(initvalue)),
  initvalue = zeros(1,size(Text,1));
end;

initvalue = (initvalue~=0);

[m] = size(Text,1);
MaxRows = 25;
if m <= MaxRows
    NoVal = m;
else
    NoVal = MaxRows;
end

for i=1:m
    n(i,1)=size(Text{i,1},2)*ceil(m/NoVal);
end
n = max(n);
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
heigth = ((NoVal+2)*h/.8);
left = screen(1)+max([floor(.5*(screen(3)-width))  0]);
bottom = screen(2)+max([floor(.5*(screen(4)-heigth))  0]);
pos = [left bottom width heigth];

bkgrnd = get(gcf,'color');
bkgrnd = (bkgrnd == .5)*.5+bkgrnd;

h = [];
for tel= 1 : m,
    h(tel) = uicontrol('Style','Checkbox',...
    'Units','normalized',...
    'Position',[(ceil(tel/NoVal)-1)*0.9/(ceil(m/NoVal))+0.05 0.98-.98/(NoVal+2)*(tel-(ceil(tel/NoVal)*NoVal-NoVal)) .8 .7/(NoVal+2)],...
    'HorizontalAlignment','left',...
    'backgroundcolor',bkgrnd,...
    'foregroundcolor',[1 1 1] - bkgrnd,...
    'String',Text(tel,:),...
    'Value',initvalue(tel));
end;

h_OK = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'position',[0.1 .02 .35 .7/(NoVal+2)],...
    'HorizontalAlignment','center',...
    'String','OK');

h_Esc = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'position',[0.55 .02 .35 .7/(NoVal+2)],...
    'HorizontalAlignment','center',...
    'String','Cancel');

set(h_fig,'position',pos,'visible','on');

OK = Holdfig([0.1 .02 .35 .7/(NoVal+2);0.55 .02 .35 .7/(NoVal+2)]);

if abs(OK) == 1,
  for tel = 1:length(h),
    checkbox_result(tel) = get(h(tel),'value');
  end;
else
  checkbox_result = [];
end;

close(h_fig);

