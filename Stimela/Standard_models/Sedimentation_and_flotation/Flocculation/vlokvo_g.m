function val = vlokvo_g(naamfilterfile,plotfile)


%Ophalen van de variabelen
warning off;
V=st_Varia;


%=============================START: AvdBerge, 13/03/00=========================================
if nargin<1
  ib = st_findblock(gcs,'vlokvo');
  if length(ib)==1
    naamfilterfile = get_pfil(ib{1});
  else
    % meerdere blokken   
     fs = get_pfil(ib);
     n = Radiobox(strvcat(ib),'Select the parameter file of the flocculation to be visualized');
     if length(n)
       naamfilterfile = fs{n};
     else
       return;
     end
   end  
end
%=============================STOP : AvdBerge, 13/03/00=========================================


%Ophalen van de parameters
P = st_getPdata(naamfilterfile, 'vlokvo');

Length = P.Length;
Opp    = P.Surf;
G10    = P.G10;
Ka     = P.Ka;
Kb     = P.Kb;
NumCel = P.NumCel;


%Bewerken van de parameters
%dy     = Lbed/NumCel;
%vel          = Debiet/(Opp*3600); %oppervlakte filtratiesnelheid
%VelReal      = vel;  


%=============================START: AvdBerge, 13/03/00=========================================
eval(['load ' naamfilterfile(1:length(naamfilterfile)-4) '_EM.sti -mat']);
%=============================STOP : AvdBerge, 13/03/00=========================================

Sig     = [vlokvoEM(2:NumCel+1,:)];
Tijdout = vlokvoEM(1,:);



%=============================START: AvdBerge, 13/03/00=========================================
eval(['load ' naamfilterfile(1:length(naamfilterfile)-4) '_in.sti -mat']);
%=============================STOP : AvdBerge, 13/03/00=========================================

LengteIn  = size(vlokvoin,2);
Ql        = vlokvoin(V.Flow+1,LengteIn);
Tl        = vlokvoin(V.Temperature+1,LengteIn);
coSS      = vlokvoin(V.Suspended_solids+1,LengteIn);
Susp      = vlokvoin(V.Suspended_solids+1,:);


%=============================START: AvdBerge, 13/03/00=========================================
eval(['load ' naamfilterfile(1:length(naamfilterfile)-4) '_out.sti -mat']);
%=============================STOP : AvdBerge, 13/03/00=========================================

Lengteout = size(vlokvoout,2);
ceSSReeks = vlokvoout(V.Suspended_solids+1,:);

ceSS    = ceSSReeks(1,Lengteout);
TijdUur = Tijdout/3600;
SSmax   = max(vlokvoout(V.Suspended_solids+1,:));
RSSmin  = (coSS-SSmax)/coSS*100; % Maximaal verwijderingsrendement zwevende stof

%Sig
Sig=[Susp;Sig];
Sig=Sig(:,LengteIn);

%=============================START: KMS, 03/08/04=========================================
%inlezen data
Data=[];
if nargin==2
  Data=st_LoadTxt(plotfile);
end  
%=============================STOP : AvdBerge, 03/08/04=========================================

%Omzetten van getallen naar strings voor weergave
LengthT = sprintf('%.1f',Length);
NumCelT = sprintf('%.0f',NumCel);
OppT    = sprintf('%.1f',Opp);
G10T    = sprintf('%.1f',G10);
KaT     = sprintf('%.2e',Ka);
KbT     = sprintf('%.2e',Kb);
QlT     = sprintf('%.1f',Ql);


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
%set(gcf,'PaperPosition',[0.25 0.25 10.5 8]);
set(gcf,'Name',['Flocculation']);
pnt=[NaN NaN  1  NaN NaN  1   1   1  NaN  1  NaN  1  NaN NaN  1  NaN;...
     NaN  1  NaN  1  NaN NaN  1  NaN NaN  1  NaN  1   1   1   1  NaN;...
     NaN  1  NaN NaN NaN NaN  1  NaN NaN  1  NaN  1  NaN NaN  1  NaN;...
     NaN NaN  1  NaN NaN NaN  1  NaN NaN  1  NaN  1  NaN NaN  1  NaN;...
     NaN NaN NaN  1  NaN NaN  1  NaN NaN  1  NaN  1  NaN NaN  1  NaN;...
     NaN  1  NaN  1  NaN NaN  1  NaN NaN  1  NaN  1  NaN NaN  1  NaN;...
     NaN NaN  1  NaN NaN NaN  1  NaN NaN  1  NaN  1  NaN NaN  1  NaN;...
      1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1 ;...
      1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1 ;...
     NaN NaN  1   1   1  NaN  1  NaN NaN NaN NaN  1   1  NaN NaN NaN;...
     NaN NaN  1  NaN NaN NaN  1  NaN NaN NaN  1  NaN NaN  1  NaN NaN;...
     NaN NaN  1  NaN NaN NaN  1  NaN NaN NaN  1  NaN NaN  1  NaN NaN;...
     NaN NaN  1   1  NaN NaN  1  NaN NaN NaN  1   1   1   1  NaN NaN;...
     NaN NaN  1  NaN NaN NaN  1  NaN NaN NaN  1  NaN NaN  1  NaN NaN;...
     NaN NaN  1  NaN NaN NaN  1  NaN NaN NaN  1  NaN NaN  1  NaN NaN;...
     NaN NaN  1   1   1  NaN  1   1   1  NaN  1  NaN NaN  1  NaN NaN];
set(gcf,'Pointer','custom','PointerShapeCData',pnt);


subplot(2,2,1)
plot((0:NumCel)*(Length/NumCel),Sig,'k')
%=============================START: KMS, 03/08/04=========================================
if size(Data,2)>1
  hold on
  plot(Data(:,1),Data(:,2),'*')
  hold off
end  
%=============================STOP: KMS, 03/08/04=========================================

xlabel('Length of the reactor [meter]')
ylabel('Suspended solids [mg/l]')
title(['Removal of suspended solids over the length'])
grid on


subplot(2,2,2)
plot(TijdUur,ceSSReeks,'k')
%hold on
%plot(TijdUur,coSS*(1:LengteIn))
xlabel('Time [hour]')
ylabel('Suspended solids [mg/l]')
title(['Effluent concentration of suspended solids in time'])
grid on


subplot(2,2,3)
set(gca,'Visible','off')
text(-0.1,1, 'Parameters:')
text(-0.1,0.9,   'Length of the reactor')
text(-0.1,0.8, 'Cross section of the reactor')
text(-0.1,0.7, 'G value at 10 o^C')
text(-0.1,0.6, 'Floc aggregation constant, Ka')
text(-0.1,0.5, 'Floc breakup constant, Kb')
text(-0.1,0.4, 'Water flow')
text(-0.1,0.3, 'Competely mixed reactors')
text(-0.1,0.2, '')
text(-0.1,0.1, '')
text(-0.1,0,   '')

text(0.45,0.9,   LengthT)
text(0.45,0.8, OppT )
text(0.45,0.7, G10T)
text(0.45,0.6, KaT)
text(0.45,0.5, KbT)
text(0.45,0.4, QlT)
text(0.45,0.3, NumCelT)

text(0.7,0.9,   'm')
text(0.7,0.8, 'm^2')
text(0.7,0.7, '1/s')
text(0.7,0.6, '-')
text(0.7,0.5, '-')
text(0.7,0.4, 'm^3/h')
text(0.7,0.3, '-')


subplot(2,2,4)
set(gca,'Visible','off')

