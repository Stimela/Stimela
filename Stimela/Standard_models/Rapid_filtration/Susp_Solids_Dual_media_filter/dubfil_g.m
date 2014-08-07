function val = dubfil_g(naamfilterfile,naamspoelfile,plotfile)

% Constants
NumLines = 6;

%Ophalen van de variabelen
warning off;
V=st_Varia;

% Get filter parameters
if nargin<1
  ib = st_findblock(gcs,'dubfil');
  if length(ib)==1
    naamfilterfile = get_pfil(ib{1});
  else
    % meerdere blokken   
     fs = get_pfil(ib);
     n = Radiobox(strvcat(ib),'Select the parameter file of the dual media filter to be visualized');
     if length(n)
       naamfilterfile = fs{n};
     else
       return;
     end
   end  

end

% Get backwash module parameters
if nargin<2
  ib = st_findblock(gcs,'bacwa1');
  if length(ib)==1
    naamspoelfile = get_pfil(ib{1});
  else
    % meerdere blokken   
     fs = get_pfil(ib);
     n = Radiobox(strvcat(ib),'Select the parameter file of the backwash module of the filter');
     if length(n)
       naamspoelfile = fs{n};
     else
       return;
     end
   end  
end

%Ophalen van de parameters
P = st_getPdata(naamfilterfile, 'dubfil');

Opp    = P.Surf;
Ls     = P.Ls;
rhoD   = P.rhoD;


%Bewerken van de parameters
Diamb    = P.Diam1;
Diamo    = P.Diam2;
FilPorb  = P.FilPor1;
FilPoro  = P.FilPor2;
n1       = P.n1;
n2       = P.n2;
Lambdab  = P.Lambda01;
Lambdao  = P.Lambda02;
Lbboven  = P.Lb1;
Lbonder  = P.Lb2;
Lbtotaal = Lbboven+Lbonder;
NumCelb  = P.NumCel1;
NumCelo  = P.NumCel2;
NumCelt  = NumCelb + NumCelo;
dy1      = P.Lb1/P.NumCel1;
dy2      = P.Lb2/P.NumCel2;


P = st_getPdata(naamspoelfile, 'bacwa1');

TL       = P.TL;   %Filter run time [h]
Tsp      = P.Tsp;   %Backwash time [min]
Tst      = P.Tst;   %Start time for backwashing [h]

eval(['load ' naamfilterfile(1:length(naamfilterfile)-4) '_in.sti -mat']);
eval(['load ' naamfilterfile(1:length(naamfilterfile)-4) '_out.sti -mat']);
eval(['load ' naamfilterfile(1:length(naamfilterfile)-4) '_ES.sti -mat']);
eval(['load ' naamfilterfile(1:length(naamfilterfile)-4) '_EM.sti -mat']);

Sigenk=[dubfilEM(1,:);dubfilEM(1+(NumCelt+1):(2*NumCelt+1),:)];
effenk=[dubfilEM(1,:);dubfilEM(1:(NumCelt+1),:)];


%Bewerken van de tijd
TpsS=Sigenk(1,:);
Tpsacc=TpsS';

TpsE=effenk(1,:);%file enk
TpsE=TpsE/3600;
TpsE=TpsE';


b=effenk(:,1);
effenk=effenk';
effenk=effenk(:,(length(b)));

[NoIn, LengteIn]  = size(dubfilin);
Ql        = dubfilin(V.Flow+1,LengteIn);
Tl        = dubfilin(V.Temperature+1,LengteIn);
coSS      = dubfilin(V.Suspended_solids+1,LengteIn);
Flush     = dubfilES(1+1, :);    % flush signal: 0 = filter running, 1 = back washing

LengteUit = size(dubfilout,2);
ceSS      = dubfilout(V.Suspended_solids+1,LengteUit);

SSmax  = max(dubfilout(V.Suspended_solids+1,:));
RSSmin = (coSS-SSmax)/coSS*100; % Maximaal verwijderingsrendement zwevende stof


  %	Convert to: filtration = 1 and flush = 0
  FiltrOnOff = ~Flush;
  
  %	Select first cycle from filtration
  noCycle = 1;		% select first cycle
  [Cycle_On, Cycle_Off, Status, ErrStr] = selCycle(FiltrOnOff, noCycle);
  
  % Check result returned by the SelCycle-function
  switch Status
  case -1
    %	FiltrOnOff contains less cycles than noCycle: select all cycles
    Cycle_Start = Flush(1);
    Cycle_Stop  = Flush(length(Flush));
    h = errordlg(['At least ' num2str(noCycle) ' filterruns should be simulated, so extend the stop time for simulation.'],...
      'Stimela', 'on');
    dlgOnTop(h);
  case 1
    %	Desired cycle was selected (OK)
    Cycle_Start = Cycle_On(1);
    Cycle_Stop  = Cycle_On(length(Cycle_On));
  otherwise
    %	Error: select all cycles
    Cycle_Start = Flush(1);
    Cycle_Stop  = Flush(length(Flush));
    h = errordlg(['Filterrun ' num2str(noCycle) ' could not be selected'], 'Stimela', 'on');
    dlgOnTop(h);
  end		% switch Status
  
  Tcycle = TpsS(Cycle_Start:Cycle_Stop);
  
  %===edited code
  %Bepalen van de tijd tussen de lijnen in het Lindquist diagram
  TLintervalu = TL/NumLines;
  TLintervals = (TL/NumLines)*3600;
%=============================STOP : AvdBerge, 09/09/03=========================================

%Bewerken van de uitvoer gegevens
SSig=Ls+Sigenk(2:(NumCelt+1),Cycle_Start:Cycle_Stop);
grSig=size(SSig);
eind=grSig(2);
S(1:(NumCelt),1)=SSig(1:(NumCelt),1);
TS(1,1)=Tcycle(1,1);
tel=0;
t=1;
for tel = 2:1:eind
   if rem(Tcycle(1,tel),TLintervals)==0
      t=t+1;
      S(1:(NumCelt),t)=SSig(1:(NumCelt),tel);
      TS(1,t)=Tcycle(1,tel);
   end
end
TSacc=TS';
S=flipud(S);
S=[S;Ls*ones(1,length(TSacc))];

wst=-Sigenk(NumCelt+1,:)+Lbboven+Lbonder;

%=============================START: KMS, 03/08/04=========================================
%inlezen data
Data=[];
if nargin==3
  Data=st_LoadTxt(plotfile);
end  
%=============================STOP : AvdBerge, 03/08/04=========================================

%Omzetten van getallen naar strings voor weergave
DiambT   = sprintf('%.1f',Diamb);
DiamoT   = sprintf('%.1f',Diamo);
FilPorbT = sprintf('%.1f',FilPorb);
FilPoroT = sprintf('%.1f',FilPoro);
LbbovenT = sprintf('%.1f',Lbboven);
LbonderT = sprintf('%.1f',Lbonder);
LambdabT = sprintf('%.3f',Lambdab);
LambdaoT = sprintf('%.3f',Lambdao);
n1T      = sprintf('%.1f',n1);
n2T      = sprintf('%.1f',n2);
NumCelbT = sprintf('%.0f',NumCelb);
NumCeloT = sprintf('%.0f',NumCelo);
OppT     = sprintf('%.1f',Opp);
LsT      = sprintf('%.1f',Ls);
rhoDT    = sprintf('%.1f',rhoD);
RSSminT  = sprintf('%.1f',RSSmin);
QlT      = sprintf('%.1f',Ql);
TLT      = sprintf('%.1f',TL);
TLintervaluT = sprintf('%.1f',TLintervalu);


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
set(gcf,'Name',['Dual media filter']);
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
plot(TpsS/3600,wst)
xlabel('Time [hour]')
ylabel('Pressure drop [mWk]')
title(['Total filter resistance'])
grid on


subplot(2,2,2)
y=[0:Lbonder/NumCelo:Lbonder-Lbonder/NumCelo,Lbonder:Lbboven/NumCelb:Lbtotaal];
plot([0 (Ls+Lbtotaal)],[(Ls+Lbtotaal) 0]) %bovenstelijn statische waterhoogte
hold on
plot(S,y)
hold on
plot([0 (Ls+Lbtotaal)],[Lbtotaal Lbtotaal],'--') %filterbedhoogte
hold on
plot([0 (Ls+Lbtotaal)],[Lbonder Lbonder],'-.') %filterbedhoogte
axis([0 (Ls+Lbtotaal) 0 (Ls+Lbtotaal)]);
xlabel('Head [mWk]')
ylabel('Height from the bottom of the filterbed [m]')

text(Ls+Lbtotaal, Lbtotaal, '\downarrow Total filterbed height ', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom')
text(Ls+Lbtotaal, Lbonder, '\downarrow Height lower filter bed layer ', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom')

text(Ls, Lbtotaal, '\downarrow', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
text(Ls, Ls+Lbtotaal, '\uparrow', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')
text(Ls, (Ls/2)+Lbtotaal, 'Water level above the filter bed', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')
title(['Lindquist diagram (the time interval between the lines is ' TLintervaluT ' hour)' ])


subplot(2,2,3)
plot(TpsE,effenk)
%=============================START: KMS, 03/08/04=========================================
if size(Data,2)>1
  hold on
  plot(Data(:,1),Data(:,2),'*')
  hold off
end  
%=============================STOP: KMS, 03/08/04=========================================

xlabel('Time [hour]')
ylabel('Concentration suspended solids [mg/l]')
title(['Outgoing concentration suspended solids (Minimum efficiency = ' RSSminT ' %)'])

grid on


subplot(2,2,4)
set(gca,'Visible','off')

text(-0.1,1.1,  'Parameters:')
text(-0.1,1,    'Filterrun time')
text(-0.1,0.9,  'Filter surface')
text(-0.1,0.8,  'Water level above the filter bed')
text(-0.1,0.7,  'Water flow')
text(-0.1,0.6,  'Massdensity of the flocs')
text(-0.1,0.5,  'Clogging constant 1')
text(-0.1,0.4,  'Clogging constant 2')
text(0.4,0.25,  'Upper layer')
text(0.7,0.25,  'Lower layer')
text(-0.1,0.15, 'Bed height')
text(-0.1,0.05, 'Grainsize')
text(-0.1,-0.05,'Porosity')
text(-0.1,-0.15,'Lambda')
text(-0.1,-0.25,'Competely mixed reactors')


text(0.45,1,     TLT)
text(0.45,0.9,   OppT)
text(0.45,0.8,   LsT)
text(0.45,0.7,   QlT)
text(0.45,0.6,   rhoDT)
text(0.45,0.5,   n1T)
text(0.45,0.4,   n2T)
text(0.45,0.15,  LbbovenT)
text(0.75,0.15,  LbonderT)
text(0.45,0.05,  DiambT)
text(0.75,0.05,  DiamoT)
text(0.45,-0.05, FilPorbT)
text(0.75,-0.05, FilPoroT)
text(0.45,-0.15, LambdabT)
text(0.75,-0.15, LambdaoT)
text(0.45,-0.25, NumCelbT)
text(0.75,-0.25, NumCeloT)

text(0.7,1,   'hour')
text(0.7,0.9, 'm^2')
text(0.7,0.8, 'm')
text(0.7,0.7, 'm^3/h')
text(0.7,0.6, 'kg/m^3')
text(0.7,0.5, '-')
text(0.7,0.4, '-')
text(1,0.15,  'm')
text(1,0.05,  'mm')
text(1,-0.05, '%')
text(1,-0.15, '1/s')
text(1,-0.25, '-')

