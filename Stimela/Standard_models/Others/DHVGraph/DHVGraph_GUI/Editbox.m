function editbox_result = Editbox(Description,Default,Title,options)
% editbox_result = Editbox(Description,Default,Title,options);
% Automatisch produceren van een serie editboxes, waarbij de
% beschrijving links van het editveld staat
% afgesloten wordt na afloop met OK
% Description = een matrixstring met evenveel regels als editboxen
%               en op elke regel de beschrijving van de velden
% Default = initiele text, leeg of evenveel regels als description
% Title = de titel van de Checkbox
% options = 'h' horizontaal
% options = 'v' vertikaal
%
% in de vector editbox_result komt het resultaat :
%  op elke regel van editbox_result de ingetikte waarde
%  of leeg als Cancel gekozen is.

% © Kim van Schagen, 1-Aug-98

if nargin <3,
   Title ='';
end;
if nargin <2,
   Default =[];
end;

[m,n] = size(Description);
nT = length(Title);
n = max([2*n nT 15]);

h_fig=figure('Menubar','none',...
        'NumberTitle','off',...
        'resize','off',...
        'Name',Title,...
        'visible','off',...
        'keypress',' ');%, ...
%        'windowstyle','modal');

h = Gch(2);
screen = get(0, 'ScreenSize');
width = 16*n+30;
heigth = (m+2)*h/.7;
left = screen(1)+max([floor(.5*(screen(3)-width))  0]);
bottom = screen(2)+max([floor(.5*(screen(4)-heigth))  0]);
pos = [left bottom width heigth];


bkgrnd = get(gcf,'color');
bkgrnd = (bkgrnd == .5)*.5+bkgrnd;

for tel= 1 : m,
     uicontrol('Style','text',...
               'Units','normalized',...
               'Position',[0.05 0.9-.8/(m+2)*tel .2 .7/(m+2)],...
               'HorizontalAlignment','left',...
               'backgroundcolor',bkgrnd,...
               'foregroundcolor',[1 1 1]-bkgrnd,...
               'String',Description(tel,:) );
end;

for tel= 1 : m,
     uicontrol('Style','text',...
               'Units','normalized',...
               'Position',[0.25 0.9-.8/(m+2)*tel .05 .7/(m+2)],...
               'HorizontalAlignment','left',...
               'backgroundcolor',bkgrnd,...
               'foregroundcolor',[1 1 1]-bkgrnd,...
               'String',':' );
end;


h = [];
for tel= 1 : m,
    h(tel) = uicontrol('Style','edit',...
               'Units','normalized',...
               'Position',[0.35 0.9-.8/(m+2)*tel .6 .7/(m+2)],...
               'HorizontalAlignment','right');
    if all(size(Default));
       set(h(tel),'String',Delspace(Default(tel,:)));
    end;
end;

OKstr = ['delete(gco)'];

h_OK = uicontrol('Style','pushbutton',...
         'Units','normalized',...
         'position',[0.35 .1 .25 .7/(m+2)],...
         'HorizontalAlignment','center',...
         'String','OK',...
         'Callback', OKstr);

h_Esc = uicontrol('Style','pushbutton',...
         'Units','normalized',...
         'position',[0.70 .1 .25 .7/(m+2)],...
         'HorizontalAlignment','center',...
         'String','Cancel',...
         'Callback', 'delete(gcf)');

set(h_fig,'position',pos,'visible','on');


editbox_result = [];

% zolang h_OK bestaat bestaat de edit box
while ishandle(h_OK)
  drawnow
end

% is alleen h_OK wegf, dan is h_OK gedruk!
if ishandle(h_fig)
  editbox_result = get(h(1),'string');
  for tel = 2:length(h),
    editbox_result = str2mat(editbox_result,get(h(tel),'string'));
  end;

  delete(h_fig)
end


