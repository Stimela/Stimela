function val = pels25_g(naampelsoffile,naamsofconfile,naamcalcfile,plotfile)


%Ophalen van de variabelen
V=st_Varia;

if nargin<1
   ib = st_findblock(gcs,'pels25');
   if length(ib)==1
      naampelsoffile = get_pfil(ib{1});
   else
    % meerdere blokken   
     fs = get_pfil(ib);
     n = Radiobox(strvcat(ib),'Select the parameter file of the pellet reactor to be visualized');
     if length(n)
       naampelsoffile = fs{n};
     else
       return;
     end
   end  
end

% Get Pellet control module parameters
if nargin<2
  
  naamsofconfile = '';
  
%   ib = st_findblock(gcs,'sofcon');
%   if length(ib)==0
%     naamsofconfile = '';
%   else
%     if length(ib)==1
%       naamsofconfile = get_pfil(ib{1});
%     else 
%       % meerdere blokken   
%        fs = get_pfil(ib);
%        n = Radiobox(strvcat(ib),'Select the parameter file of the pellet control module of the pellet reactor');
%        if length(n)
%          naamsofconfile = fs{n};
%        else
%          return;
%        end
%      end  
%    end
end

if nargin<3
  ib = st_findblock(gcs,'calceq');
  if length(ib)==1
    naamcalcfile = get_pfil(ib{1});
  else
    [F,P]=uigetfile('*.mat','Select the parameter file of the dosing module after the pellet reactor');
    if F ~= 0,
      P = transDir(P);
      naamcalcfile=[P F];
    end
  end
end


%Ophalen van de parameters
Pa = st_getPdata(naampelsoffile, 'pels25');

NumCel = Pa.NumCel; %aantal cellen

%Ophalen van de parameters
if length(naamsofconfile)>0
  Co = st_getPdata(naamsofconfile, 'sofcon');
else
  Co.Soda=NaN;
  Co.vPel=NaN;
  Co.BPFlow = NaN;
end

SodaFlow  = Co.Soda; 
PelVel    = Co.vPel;
BPFlow    = Co.BPFlow;

eval(['load ' naampelsoffile(1:length(naampelsoffile)-4) '_in.sti -mat']);
eval(['load ' naampelsoffile(1:length(naampelsoffile)-4) '_ES.sti -mat']);
eval(['load ' naampelsoffile(1:length(naampelsoffile)-4) '_out.sti -mat']);
eval(['load ' naampelsoffile(1:length(naampelsoffile)-4) '_EM.sti -mat']);

%Bewerken van de uitvoer gegevens
LengteIn  = size(pels25in,2);
Ql        = pels25in(V.Flow+1,LengteIn);
Tl        = pels25in(V.Temperature+1,LengteIn);
Cain      = pels25in(V.Calcium+1,:)/40;
pHin      = pels25in(V.pH+1,:);

%Extra measurements
time=pels25EM(1,:);
dP=pels25EM(2,:);
Diam=pels25EM(4,:);
BedHeight=pels25EM(3,:);
dp50=pels25EM(6,:);
dPX = pels25EM(1+5*Pa.NumCel+(1:Pa.NumCel),:);
dPL = pels25EM(1+3*Pa.NumCel+(1:Pa.NumCel),:);
DiamR = pels25EM(1+1*Pa.NumCel+(1:Pa.NumCel),:);

L = cumsum(dPL);
dPR = cumsum(dPX);

Dos=pels25ES(2:4,:);

% determine time fraction
timespan=time(end)-time(1);
dt=60;
dttxt='Minutes';
if timespan>3600
  dt=3600;
  dttxt='Hours';
end
if timespan>2*24*3600
  dt=3600*24;
  dttxt='Days';
end


% after chemical equilibrium
eval(['load ' naamcalcfile(1:length(naamcalcfile)-4) '_out.sti -mat']);
eval(['load ' naamcalcfile(1:length(naamcalcfile)-4) '_EM.sti -mat']);

Camix=calceqout(V.Calcium+1,:)/40;
HCO3mix=calceqout(V.Bicarbonate+1,:);
pHmix=calceqout(V.pH+1,:);

% na reactor
TACC = calceqEM(3,:);

%inlezen data
Data=[];
if nargin==4
  Data=st_LoadTxt(plotfile);
end  

%Omzetten van getallen naar strings voor weergave
AT        = sprintf('%.1f',Pa.A);
kg0T       = sprintf('%.2f',Pa.kg0);     
d0T       = sprintf('%.2f',Pa.d0);
%p0T       = sprintf('%.2f',p0);
rhogT     = sprintf('%.0f',Pa.rhog);
rhosT     = sprintf('%.0f',Pa.rhos);
%ffT       = sprintf('%.1f',ff);
NumCelT   = sprintf('%.0f',Pa.NumCel);
QlT       = sprintf('%.1f',Ql);
TlT       = sprintf('%.1f',Tl);
SodaFlowT = sprintf('%.1f',SodaFlow);
PelVelT   = sprintf('%.1f',PelVel);
BPFlowT   = sprintf('%.1f',BPFlow);
%StopTimeT = sprintf('%.0f',StopTime);
%kTT   = sprintf('%.4f',Pa.KT20);
%DfT   = sprintf('%.4f',Pa.Df);
%CdT   = sprintf('%.1f',Pa.Cd);
%ndT   = sprintf('%.1f',Pa.nd);


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
set(gcf,'Name',['Pellet reactor']);
stimMous(gcf);


subplot(2,2,1)
plot(time/(dt),Camix)
text(time(end)/(dt),Camix(end), sprintf('%.2f',Camix(end)),'HorizontalAlignment','right','BackgroundColor',[1 1 1],'color','b')
hold on
plot(time/(dt),Cain,'r')
text(time(end)/(dt),Cain(end), sprintf('%.2f',Cain(end)),'HorizontalAlignment','right','BackgroundColor',[1 1 1],'color','r')
plot(time/(dt),TACC*10,'g')
text(time(end)/(dt),TACC(end)*10, sprintf('%.2f',TACC(end)),'HorizontalAlignment','right','BackgroundColor',[1 1 1],'color','g')
%=============================START: KMS, 03/08/04=========================================
if size(Data,2)>1
  hold on
  plot(Data(:,1),Data(:,2),'*')
  hold off
end  
%=============================STOP: KMS, 03/08/04=========================================

xlabel(['Time (' dttxt ')'])
ylabel('Calcium (mmol/l)')
title(['Calcium concentration'])
legend('Mixed effluent','Influent','TCCP*10',0)
%axis([0 365 30 100])
set(gca,'ylim',[0 3])
grid on

subplot(4,2,2)
plot(time/(dt),pHmix)
text(time(end)/(dt),pHmix(end), sprintf('%.1f',pHmix(end)),'HorizontalAlignment','right','BackgroundColor',[1 1 1],'color','b')
hold on
plot(time/(dt),pHin,'r')
text(time(end)/(dt),pHin(end), sprintf('%.1f',pHin(end)),'HorizontalAlignment','right','BackgroundColor',[1 1 1],'color','r')
%=============================START: KMS, 03/08/04=========================================
if size(Data,2)>2
  hold on
  plot(Data(:,1),Data(:,3),'*')
  hold off
end  
%=============================STOP: KMS, 03/08/04=========================================

ylabel('pH')
xlabel(['Time (' dttxt ')'])
title(['pH'])
legend('Mixed effluent','Influent',0)
%axis([0 365 7 9])
grid on


subplot(4,2,4)
plot(time/(dt),Dos)
for i=1:size(Dos,1)
  text(time(end)/(dt),Dos(i,end), sprintf('%.0f',Dos(i,end)),'HorizontalAlignment','right','BackgroundColor',[1 1 1],'color','b')
end
xlabel(['Time (' dttxt ')'])
ylabel('Dosage')
 l{1} = ['NaOH'];
 l{2} = ['Seed'];
 l{3} = ['Pellet'];
legend(l,3)
%axis([0 365 0 4])
grid on

subplot(4,2,4+1)
subplot(2,2,3)
plot(time/(dt),dP)
text(time(end)/(dt),dP(end), sprintf('%.2f',dP(end)),'HorizontalAlignment','right','BackgroundColor',[1 1 1],'color','b')
hold on
plot(time/(dt),Diam,'r')
text(time(end)/(dt),Diam(end), sprintf('%.2f',Diam(end)),'HorizontalAlignment','right','BackgroundColor',[1 1 1],'color','r')
plot(time/(dt),BedHeight,'g')
text(time(end)/(dt),BedHeight(end), sprintf('%.1f',BedHeight(end)),'HorizontalAlignment','right','BackgroundColor',[1 1 1],'color','g')
plot(time/(dt),dp50*9.8,'c')
text(time(end)/(dt),dp50(end)*9.8, sprintf('%.1f',dp50(end)*9.8),'HorizontalAlignment','right','BackgroundColor',[1 1 1],'color','c')
xlabel(['Time (' dttxt ')'])
%axis([0 365 0 4])
legend('Headloss [mWc]','Pellet diameter [mm]', 'Bedheight [m]', '\DeltaP_{50} [kPa]',3)
grid on

% subplot(4,2,4+3)
% plot(time/(dt),dPX)
% for i=1:Pa.NumCel
%   text(time(end)/(dt),dPX(i,end), sprintf('%.2f',dPX(i,end)),'HorizontalAlignment','right','BackgroundColor',[1 1 1])
% end  
% %text(time(end)/(dt),dP(end), sprintf('%.0f',dP(end)),'HorizontalAlignment','right','BackgroundColor',[1 1 1],'color','b')
% xlabel(['Time (' dttxt ')'])
% ylabel('Headloss/m')
% %axis([0 365 0 4])
% l={};
% for i=1:Pa.NumCel
%     l{i} = ['Reactor' num2str(i)];
% end
% legend(l,3)
% grid on

subplot(2,2,4)
n = interp1(time,1:length(time),time(1):((time(end)-time(1))/5):time(end));
n=floor(n);
%for i=n
  plot(DiamR(:,n),L(:,n))
%  hold on
%end  
%hold off
%text(time(end)/(dt),dP(end), sprintf('%.0f',dP(end)),'HorizontalAlignment','right','BackgroundColor',[1 1 1],'color','b')
xlabel(['Diameter'])
ylabel('Height')
%axis([0 365 0 4])
l={};
for i=1:length(n)
    l{i} = ['t=' sprintf('%.1f',time(n(i))/dt)];
end
legend(l,1)
grid on

% subplot(2,2,4)
% set(gca,'Visible','off')
% 
% nx = 1/13;
% 
% text(-0.1,13*nx, 'Parameters:')
% text(-0.1,12*nx, 'Water flow through reactor')
% text(-0.1,11*nx, 'Reactor surface')
% text(-0.1,10*nx, 'Size seeding material')
% text(-0.1, 9*nx, 'Density seeding material')
% %text(-0.1, 9*nx, 'Density seeding material')
% %text(-0.1, 8*nx, 'Crystallization constant')
% %text(-0.1, 7*nx, 'Drag constant')
% %text(-0.1, 6*nx, 'Drag exponent')
% text(-0.1, 5*nx, 'Temperature')
% %text(-0.1, 4*nx, 'Competely mixed reactors')
% text(-0.1, 3*nx, 'By-Pass flow')
% text(-0.1, 2*nx, 'Pellet discharge')
% text(-0.1, 1*nx, 'Caustic soda flow')
% 
% text(0.45,12*nx,   QlT)
% text(0.45,11*nx, AT)
% text(0.45,10*nx, d0T)
% text(0.45, 9*nx, rhogT)
% %text(0.45, 8*nx, kTT)
% %text(0.45, 7*nx, CdT)
% %text(0.45, 6*nx, ndT)
% text(0.45, 5*nx, TlT)
% %text(0.45, 4*nx, NumCelT)
% text(0.45, 3*nx, BPFlowT)
% text(0.45, 2*nx, PelVelT)
% text(0.45, 1*nx, SodaFlowT)
% 
% text(0.7,12*nx,   'm^3/h')
% text(0.7,11*nx, 'm^2')
% text(0.7,10*nx, 'mm')
% text(0.7, 9*nx, 'kg/m^3')
% %text(0.7, 8*nx, 'l m / s mmol')
% %text(0.7, 7*nx, '-')
% %text(0.7, 6*nx, '-')
% text(0.7, 5*nx, 'oC')
% %text(0.7, 4*nx, '-')
% text(0.7, 3*nx, 'm^3/h')
% text(0.7, 2*nx, '1000 grains/s')
% text(0.7, 1*nx, 'l/h')
