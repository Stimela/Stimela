function val = ccemsi_g(naamccemsiffile,plotfile)
%standard graphic output file for ccemsi

if nargin<1
   ib = st_findblock(gcs,'ccemsi');
   if length(ib)==1
      naampelsoffile = get_pfil(ib{1});
   else
    % meerdere blokken   
     fs = get_pfil(ib);
     n = Radiobox(strvcat(ib),'Select the parameter file of type ccemsi to be visualized');
     if length(n)
       naampelsoffile = fs{n};
     else
       return;
     end
   end  
end

%Ophalen van de variabelen
V=st_Varia;

%Ophalen van de parameters
Pa = st_getPdata(naampelsoffile, 'ccemsi');

NumCel = Pa.NumCel; %aantal cellen

eval(['load ' naampelsoffile(1:length(naamccemsifile)-4) '_in.sti -mat']);
eval(['load ' naampelsoffile(1:length(naamccemsifile)-4) '_out.sti -mat']);
eval(['load ' naampelsoffile(1:length(naamccemsifile)-4) '_EM.sti -mat']);
eval(['load ' naampelsoffile(1:length(naamccemsifile)-4) '_ES.sti -mat']);

%Bewerken van de uitvoer gegevens
time      = ccemsiin(1,:);
Q         = ccemsiin(V.Flow+1,:);
Ql        = Q(end);

%Extra measurements
dP=ccemsiEM(2,:);

% determine time fraction
timespan=time(end)-time(1);
dt=60;
dttxt='Minuts';
if timespan>3600
  dt=3600;
  dttxt='Hours';
end
if timespan>2*24*3600
  dt=3600*24;
  dttxt='Days';
end

%inlezen data
Data=[];
if nargin==2
  Data=st_LoadTxt(plotfile);
end  

%Omzetten van getallen naar strings voor weergave
Ex1        = sprintf('%.1f',Pa.Ex1);


% text vak vullen
TxtM ={
'Parameters', '',  ''
'Water Flow', Q1,  'm3/h'
'Ex1',        Ex1, 'unitEx1'};


%%%%%%%%%%%%%%%% daadwerkelijke uitvoer
figure

Mdhv;
s = get(0,'ScreenSize');
if s(3) == 1152
   bottom = 8;
elseif s(3) == 1024
   bottom = 4;
elseif s(3) == 800
   bottom = -5;
else
   bottom = 0;
end
pos =  [1 bottom s(3) 0.94*s(4)];
set(gcf,'Position',pos); 
set(gcf,'NumberTitle','off');
set(gcf,'PaperOrientation','landscape');
set(gcf,'Name',['ccemsi']);
stimMous(gcf);

subplot(2,2,1)
plot(time/(dt),Q)
text(time(end)/(dt),Q(end), sprintf('%.2f',Q(end)),'HorizontalAlignment','right','BackgroundColor',[1 1 1],'color','b')

if size(Data,2)>1
  hold on
  plot(Data(:,1),Data(:,2),'*')
  hold off
end  

xlabel(['Time (' dttxt ')'])
Ylabel('Flow (m3/h)')
legend('Flow',0)
grid on


% text output
subplot(2,2,4)
set(gca,'Visible','off')

nx = size(TxtM,2);

for i=1:nx
  text(-0.1 ,(13-i+1)/nx, TxtM{i,1});
  text(0.45 ,(13-i+1)/nx, TxtM{i,2});
  text(0.7  ,(13-i+1)/nx, TxtM{i,3});
end