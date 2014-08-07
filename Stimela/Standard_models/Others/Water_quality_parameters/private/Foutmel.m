function Foutmel(Text,Title)
%
% Functie naam :    Foutmel
%
% Gebruik      :    algemeen
%
% Aanroep      :    f = Foutmel(Text,Title)
%
% Text         =    characterstring met de omschrijving van de
%                   fout. Dit mag ook een matrix zijn.
% Title        =    characterstring met de titel van het fout-
%                   meldings window
%
% Omschrijving :
% --------------
%
% indien een foutmelding naar de gebruiker doorgegeven moet worden 
% kan dit dmv een uniforme routine gebeuren. Deze routine
% geeft een nieuw window met als titel de meegegeven string of
% de defaultwaarde " Foutmelding".
%
% Automatisch produceren van een Textbox
% afgesloten wordt na afloop met OK
% Ook kan afgesloten worden met Enter
%
% Text = een matrixstring met evenveel regels als opties
% Title = de titel van de Textbox

% Kim van Schagen 23-11-94
% 



% ===============================================================
% DHV Water BV
% Project       : Modellering Spaarbekken Panheel
% Opdrachtgever : Waterleiding Maatschappij Limburg
%
% B. Witteveen
% maart 1995
%
% Wijzigingen:
% ================================================================





if nargin <2,
  Title ='Foutmelding';
end;

[m,n] = size(Text);

n = max([n 15]);

% Size Box
screen = get(0, 'ScreenSize');
left = screen(1)+max([floor(.5*screen(3))-4*n  0]);
bottom = screen(2)+floor(.5*screen(4)-(20*m+35)/2);
width = 8*n;
heigth = 20*m+35;

h_fig=figure('Menubar','none',...
        'position',[left bottom width heigth],...
        'NumberTitle','off',...
        'resize','off',...
        'Name',Title);

bkgrnd = get(gcf,'color');
bkgrnd = (bkgrnd == .5)*.5+bkgrnd;

h = [];
for tel= 1 : m,
  h(tel) = uicontrol('Style','text',...
     'Units','normalized',...
     'Position',[0.1 0.9-.8/(m+1)*tel .8 .8/(m+2)],...
     'HorizontalAlignment','left',...
     'backgroundcolor',bkgrnd,...
     'foregroundcolor',[1 1 1] - bkgrnd,...
     'String',Text(tel,:));
end;

h_OK = uicontrol('Style','pushbutton',...
  'Units','normalized',...
  'position',[0.1 .1 .8 .8/(m+2)],...
  'HorizontalAlignment','center',...
  'String','OK');


OK = Holdfig([0.1 .1 .8 .8/(m+2)]);


close(h_fig);


