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

vr = ver('matlab');
if vr(1).Version(1)=='6'
  
  warning off MATLAB:m_warning_end_without_block
  
  radiobox_result = RadioboxV6(Text,Title,initvalue);
  return;
end

if (nargin <3),
  initvalue = 1;
end;
if nargin <2,
  Title ='';
end;

if (size(Text,1)<initvalue|initvalue<1),
  initvalue = 1;
end;

Text = char(Text); % Convert to character array to find correct width

[m,n] = size(Text);
nT = length(Title);

n = max([n nT 15]);

screen = get(0, 'ScreenSize');
width = 10*n+20;
heigth = (m+2)*20/.7;
left = screen(1)+max([floor(.5*(screen(3)-width))  0]);
bottom = screen(2)+max([floor(.5*(screen(4)-heigth))  0]);
pos = [left bottom min([width screen(3)]) min([heigth screen(4)*0.9])];
h_fig=figure('Menubar','none',...
        'NumberTitle','off',...
        'resize','off',...
        'Name',Title,...
        'position',pos,...
        'visible','off');    
bkgrnd = get(h_fig,'color');
%bkgrnd = (bkgrnd == .5)*.5+bkgrnd;


% Create the button group.
h = uibuttongroup('visible','off','Position',[0 0 1 1]);
% Create three radio buttons in the button group.

bt = [];
for tel= 1 : m,
  bt(tel) = uicontrol('Style','Radio',...
      'Tag',int2str(tel),....
     'Units','normalized',...
     'Position',[0.1 0.9-.8/(m+2)*tel .8 .7/(m+2)],...
     'HorizontalAlignment','left',...
     'backgroundcolor',bkgrnd,...
     'foregroundcolor',[1 1 1] - bkgrnd,...
     'String',Text(tel,:),...
     'parent',h,...
     'HandleVisibility','off',...
     'FontName', 'FixedWidth');
  
end;

% Initialize some button group properties. 

set(h,'SelectedObject',bt(initvalue));  
set(h,'Visible','on');

h_OK = uicontrol('Parent', h,...
    'Style','pushbutton',...
  'Units','normalized',...
  'position',[0.1 .1 .35 .7/(m+2)],...
  'HorizontalAlignment','center',...
  'String','OK',...
  'Callback',@OK_Callback);

h_Cancel = uicontrol('Parent',h,...
  'Style','pushbutton',...
  'Units','normalized',...
  'position',[0.55 .1 .35 .7/(m+2)],...
  'HorizontalAlignment','center',...
  'String','Cancel',...
  'Callback',@Cancel_Callback);

set(h_fig,'visible','on');

radiobox_result = [];

uiwait(gcf);

close(h_fig);


function OK_Callback(src,evt)

radiobox_result = str2num(get(get(h,'SelectedObject'),'Tag'));
uiresume(gcbf);

end

function Cancel_Callback(srv,evt)

radiobox_result = [];
uiresume(gcbf);

end

end
