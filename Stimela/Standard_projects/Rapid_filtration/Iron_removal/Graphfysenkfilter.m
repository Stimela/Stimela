function val = plotenk(naamfilterfile,naamspoelfile)

% 09/09/2003, A. v.d. Berge
%    Adjusted for new backwash module

%=============================START: AvdBerge, 09/09/03=========================================
% Constants
NumLines = 6;
%=============================STOP : AvdBerge, 09/09/03=========================================

%Ophalen van de variabelen
warning off;
V=st_Varia;

% Get filter parameters
if nargin<1
   [Fn,Pn]=uigetfile('*.mat','Select the parameter file of the single media filter to be visualized');
   if Fn ~= 0,
      Pn = transDir(Pn);
      naamfilterfile=[Pn Fn];
   end
end

%Ophalen van de parameters
P = st_getPdata(naamfilterfile, 'irofil');

NumCel = P.NumCel;
  Opp    = P.Surf;
  Diam   = P.Diam;
  nmax   = P.nmax;
  rhoD   = P.rhoD;
  rhoD   = rhoD; % g/m3
  FilPor0 = P.FilPor;
  Lwater = P.Lwater;
  %LaShift= P.LaShift;
  Lambda_Iron3  = P.Lambda_Iron3;
  K = P.Kfe;
Lbed   = P.Lbed;
%Bewerken van de parameters
dy     = Lbed/NumCel;

%=============================START: AvdBerge, 09/09/03=========================================
% Get backwash module parameters
%===Code moved
if nargin<2
  [F,P]=uigetfile('*.mat','Select the parameter file of the backwash module of the filter');
  if F ~= 0,
    P = transDir(P);
    naamspoelfile=[P F];
  end
end

load (naamspoelfile);

%Ophalen van de parameters
P = st_getPdata(naamspoelfile, 'bkwash');
%===New code
TL       = P.TL;   %Filter run time [h]
Tsp      = P.Tsp;   %Backwash time [min]
Tst      = P.Tst;   %Start time for backwashing [h]
%=============================STOP : AvdBerge, 09/09/03=========================================

eval(['load ' naamfilterfile(1:length(naamfilterfile)-4) '_EM.sti -mat']);

Sigenk=[irofilEM(1,:);irofilEM(1+(NumCel+1):(2*NumCel+1),:)];
effenk=[irofilEM(1,:);irofilEM(1+1:(NumCel+1),:)];
efffe2=[irofilEM(1,:);irofilEM(1+(2*NumCel+1):(3*NumCel+1),:)];


%Bewerken van de tijd
TpsS=Sigenk(1,:);
Tpsacc=TpsS';

TpsE=effenk(1,:);%file enk
TpsE=TpsE/3600;
TpsE=TpsE';


b=effenk(:,1);
effenk=effenk';
effenk=effenk(:,(length(b)));

efffe2=efffe2';
efffe2=efffe2(:,2:(length(b)));

eval(['load ' naamfilterfile(1:length(naamfilterfile)-4) '_in.sti -mat']);

%=============================START: AvdBerge, 09/09/03=========================================
%===edited code
[NoIn, LengteIn]  = size(irofilin);
Ql        = irofilin(V.Flow+1,LengteIn);
Tl        = irofilin(V.Temperature+1,LengteIn);
%coSS      = irofilin(V.Suspended_solids+1,LengteIn);
coSS      = irofilin(V.Iron3+1,LengteIn);
%===new code
Flush     = irofilin(NoIn, :);    % flush signal: 0 = filter running, 1 = back washing
%=============================STOP : AvdBerge, 09/09/03=========================================

eval(['load ' naamfilterfile(1:length(naamfilterfile)-4) '_uit.sti -mat']);

LengteUit = size(irofiluit,2);
%ceSS      = irofiluit(V.Suspended_solids+1,LengteUit);
ceSS      = irofiluit(V.Iron3+1,LengteUit);


%SSmax  = max(irofiluit(V.Suspended_solids+1,:));
SSmax  = max(irofiluit(V.Iron3+1,:));
RSSmin = (coSS-SSmax)/coSS*100; % Maximaal verwijderingsrendement zwevende stof

%=============================START: AvdBerge, 09/09/03=========================================
%===new code
  %	Select first filtration cycle
  
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
SSig=Lwater+Sigenk(2:(NumCel+1),Cycle_Start:Cycle_Stop);
grSig=size(SSig);
eind=grSig(2);
S(1:(NumCel),1)=SSig(1:(NumCel),1);
TS(1,1)=Tcycle(1,1);
tel=0;
t=1;
for tel = 2:1:eind
   if rem(Tcycle(1,tel),TLintervals)==0
      t=t+1;
      S(1:(NumCel),t)=SSig(1:(NumCel),tel);
      TS(1,t)=Tcycle(1,tel);
   end
end
TSacc=TS';
S=flipud(S);
S=[S;Lwater*ones(1,length(TSacc))];

wst=-Sigenk(NumCel+1,:)+Lbed;


%Omzetten van getallen naar strings voor weergave
DiamT   = sprintf('%.1f',Diam);
%FilPorT = sprintf('%.1f',FilPor);
LbedT     = sprintf('%.1f',Lbed);
NumCelT = sprintf('%.0f',NumCel);
OppT    = sprintf('%.1f',Opp);
LwaterT     = sprintf('%.1f',Lwater);
nmaxT   = sprintf('%.1f',nmax);
rhoDT   = sprintf('%.1f',rhoD);
%LaShiftT = sprintf('%.2f',LaShift);
RSSminT = sprintf('%.1f',RSSmin);
QlT     = sprintf('%.1f',Ql);
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
set(gcf,'Name',['Single media filter']);
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
y=[0:Lbed/NumCel:Lbed];
plot([0 (Lwater+Lbed)],[(Lwater+Lbed) 0]) %bovenstelijn statische waterhoogte
hold on
plot(S,y)
hold on
plot([0 (Lwater+Lbed)],[Lbed Lbed],'--') %filterbedhoogte
axis([0 (Lwater+Lbed) 0 (Lwater+Lbed)]);
xlabel('Head [mWk]')
ylabel('Height from the bottom of the filterbed [m]')
text(Lwater+Lbed, Lbed, '\downarrow Filterbed height ', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom')

text(Lwater, Lbed, '\downarrow', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
text(Lwater, Lwater+Lbed, '\uparrow', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')
text(Lwater, (Lwater/2)+Lbed, 'Water level above the filter bed', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')
title(['Lindquist diagram (the time interval between the lines is ' TLintervaluT ' hour)' ])


subplot(2,2,3)
plot(TpsE,effenk)
hold on 
plot(TpsE,efffe2,'r')
xlabel('Time [hour]')
%ylabel('Concentration suspended solids [mg/l]')
ylabel('Concentration Iron III [mg/l]')
%title(['Outgoing concentration suspended solids (Minimum efficiency = ' RSSminT ' %)'])
%title(['Outgoing concentration Iron III (Minimum efficiency = ' RSSminT ' %)'])
grid on


subplot(2,2,4)
set(gca,'Visible','off')

text(-0.1,1.1, 'Parameters:')
text(-0.1,1,   'Filterrun time')
text(-0.1,0.9, 'Filter surface')
text(-0.1,0.8, 'Water level above the filter bed')
text(-0.1,0.7, 'Water flow')
text(-0.1,0.6, 'Maximum porefilling')
text(-0.1,0.5, 'Massdensity of the flocs')
text(-0.1,0.4, 'Bed height')
text(-0.1,0.3, 'Grainsize')
text(-0.1,0.2, 'Porosity')
text(-0.1,0.1, 'Shift of lambda0')
text(-0.1,0,   'Competely mixed reactors')

text(0.45,1,   TLT)
text(0.45,0.9, OppT )
text(0.45,0.8, LwaterT)
text(0.45,0.7, QlT)
text(0.45,0.6, nmaxT)
text(0.45,0.5, rhoDT)
text(0.45,0.4, LbedT)
text(0.45,0.3, DiamT)
%text(0.45,0.2, FilPorT)
%text(0.45,0.1, LaShiftT)
text(0.45,0,   NumCelT)

text(0.7,1,   'hour')
text(0.7,0.9, 'm^2')
text(0.7,0.8, 'm')
text(0.7,0.7, 'm^3/h')
text(0.7,0.6, '-')
text(0.7,0.5, 'kg/m^3')
text(0.7,0.4, 'm')
text(0.7,0.3, 'mm')
text(0.7,0.2, '%')
text(0.7,0.1, 'm^3/m^3')
text(0.7,0,   '-')

