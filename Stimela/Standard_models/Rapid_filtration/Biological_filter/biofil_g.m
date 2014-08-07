function val = biofil_g(naamfilterfile,naamspoelfile)

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
  ib = st_findblock(gcs,'biofil');
  if length(ib)==1
    naamfilterfile = get_pfil(ib{1});
  else
    % meerdere blokken   
     fs = get_pfil(ib);
     n = Radiobox(strvcat(ib),'Select the parameter file of the biological filter to be visualized');
     if length(n)
       naamfilterfile = fs{n};
     else
       return;
     end
   end  
end

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
P = st_getPdata(naamfilterfile, 'biofil');
PSpoel = st_getPdata(naamspoelfile, 'bacwa1');


Opp        = P.Surf;
Lbed       = P.Lbed;
Diam       = P.Diam;
FilPor     = P.FilPor;
X0_Ns      = P.X0_Ns;
X0_Nb      = P.X0_Nb;
MuMax15_Ns = P.MuMax15_Ns;
MuMax15_Nb = P.MuMax15_Nb; 
B_Ns       = P.B_Ns;
B_Nb       = P.B_Nb;
Y_Ns       = P.Y_Ns;
Y_Nb       = P.Y_Nb;
KsPO4_Ns   = P.KsPO4_Ns;
KsPO4_Nb   = P.KsPO4_Nb;
KsO2_Ns    = P.KsO2_Ns;
KsO2_Nb    = P.KsO2_Nb; 
AlfaT_Ns   = P.AlfaT_Ns;
AlfaT_Nb   = P.AlfaT_Nb; 
NumCel     = P.NumCel;

%Bewerken van de parameters
dy     = Lbed/NumCel;

%===New code
TL       = PSpoel.TL;   %Filter run time [h]
Tsp      = PSpoel.Tsp;   %Backwash time [min]
Tst      = PSpoel.Tst;   %Start time for backwashing [h]

eval(['load ' naamfilterfile(1:length(naamfilterfile)-4) '_in.sti -mat']);
eval(['load ' naamfilterfile(1:length(naamfilterfile)-4) '_EM.sti -mat']);
eval(['load ' naamfilterfile(1:length(naamfilterfile)-4) '_out.sti -mat']);
eval(['load ' naamfilterfile(1:length(naamfilterfile)-4) '_ES.sti -mat']);

tijd   = biofilEM(1,:)/(24*3600);
nh41   = biofilEM(2,:);
nh4s1  = biofilEM(NumCel+2,:);
nh4eff = biofilEM(NumCel+1,:);
no21   = biofilEM(2*NumCel+2,:);
no2s1  = biofilEM(3*NumCel+2,:);
no2eff = biofilEM(3*NumCel+1,:);
xns1   = biofilEM(4*NumCel+2,:);
xnb1   = biofilEM(5*NumCel+2,:);
po4eff = biofilEM(14*NumCel+1,:);

%===edited code
[NoIn, LengteIn]  = size(biofilin);
coNH4        = biofilin(V.Ammonia+1,:);
coNO2        = biofilin(V.Nitrite+1,:);
coO2         = biofilin(V.Oxygen+1,:);
%===new code
Flush     = biofilES(1+1, :);    % flush signal: 0 = filter running, 1 = back washing

%Lengteout = size(biofilout,2);
ceNH4     = biofilout(V.Ammonia+1,:);
ceNO2     = biofilout(V.Nitrite+1,:);
ceO2      = biofilout(V.Oxygen+1,:);

%Omzetten van getallen naar strings voor weergave
DiamT       = sprintf('%.1f',Diam);
FilPorT     = sprintf('%.1f',FilPor);
LbedT       = sprintf('%.1f',Lbed);
NumCelT     = sprintf('%.0f',NumCel);
OppT        = sprintf('%.1f',Opp);
X0_NsT      = sprintf('%.1f',X0_Ns);
X0_NbT      = sprintf('%.1f',X0_Nb);
MuMax15_NsT = sprintf('%.1e',MuMax15_Ns);
MuMax15_NbT = sprintf('%.1e',MuMax15_Nb);
B_NsT       = sprintf('%.1e',B_Ns);
B_NbT       = sprintf('%.1e',B_Nb);
Y_NsT       = sprintf('%.1e',Y_Ns);
Y_NbT       = sprintf('%.1e',Y_Nb);
KsPO4_NsT   = sprintf('%.1e',KsPO4_Ns);
KsPO4_NbT   = sprintf('%.1e',KsPO4_Nb);
KsO2_NsT    = sprintf('%.1e',KsO2_Ns);
KsO2_NbT    = sprintf('%.1e',KsO2_Nb);
AlfaT_NsT   = sprintf('%.1e',AlfaT_Ns);
AlfaT_NbT   = sprintf('%.1e',AlfaT_Nb);



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
set(gcf,'Name',['Biological filter']);
stimMous(gcf)

subplot(2,2,1)
max1 = max(ceNH4);
max2 = max(coNH4);
max3 = max(ceNO2);
max4 = max(coNO2);
maxc = 1.1*max([max1,max2,max3,max4]);
tijdmax = max(tijd);
plot(tijd,coNH4,'b:','LineWidth',2)
%plot(tijd,nh4eff)
%plot(tijd,nh41,':')
%plot(tijd,nh4s1,'-.')
hold on
plot(tijd,ceNH4)
plot(tijd,coNO2,'r:','LineWidth',2)
plot(tijd,ceNO2,'r')
%plot(tijd,no2eff,'r')
%plot(tijd,no21,'r:')
%plot(tijd,no2s1,'r-.')
%plot(tijd,po4eff,'g')
xlabel('Time [days]')
ylabel('Concentration (mg/l)')
title('Concentration ammonia and nitrite in influent and effluent')
legend('Ammonia influent','Ammonia effluent','Nitrite influent','Nitrite effluent')
axis([0 tijdmax 0 maxc]);
grid on


subplot(2,2,2)
max1 = max(ceO2);
max2 = max(coO2);
maxc = 1.1*max([max1,max2]);
plot(tijd,coO2,'b:','LineWidth',2)
hold on
plot(tijd,ceO2)
xlabel('Time [days]')
ylabel('Concentration (mg/l)')
title('Concentration oxygen in influent and effluent')
%legend('Oxygen influent','Oxygen effluent')
axis([0 tijdmax 0 maxc]);
grid on


subplot(2,2,3)
max1 = max(xns1);
max2 = max(xnb1);
maxc = 1.1*max([max1,max2]);
plot(tijd,xns1);
hold on
plot(tijd,xnb1,'r');
xlabel('Time [days]')
ylabel('Concentration (mg/l)')
title('Concentration bacteria in the first filter layer')
legend('Nitrosomas','Nitrobacter')
axis([0 tijdmax 0 maxc]);
grid on


subplot(2,2,4)
set(gca,'Visible','off')

text(-0.1,1.1,  'Parameters:')
text(-0.1,1,    'Filter surface')
text(-0.1,0.92, 'Bed height')
text(-0.1,0.84, 'Grainsize')
text(-0.1,0.76, 'Porosity')
text(-0.1,0.68, 'Competely mixed reactors')
text(0.4,0.55,  'Nitrosomonas')
text(0.7,0.55,  'Nitrobacter')
text(-0.1,0.45, 'X0')
text(-0.1,0.37, 'MuMax15')
text(-0.1,0.29, 'B')
text(-0.1,0.21, 'Y')
text(-0.1,0.13, 'AlfaT')
text(-0.1,0.05, 'KsPO4')
text(-0.1,-0.03,'KsO2')

text(0.45,1,     OppT)
text(0.45,0.92,  LbedT)
text(0.45,0.84,  DiamT)
text(0.45,0.76,  FilPorT)
text(0.45,0.68,  NumCelT)
text(0.45,0.45,  X0_NsT)
text(0.75,0.45,  X0_NbT)
text(0.45,0.37,  MuMax15_NsT)
text(0.75,0.37,  MuMax15_NbT)
text(0.45,0.29,  B_NsT)
text(0.75,0.29,  B_NbT)
text(0.45,0.21,  Y_NsT)
text(0.75,0.21,  Y_NbT)
text(0.45,0.13,  AlfaT_NsT)
text(0.75,0.13,  AlfaT_NbT)
text(0.45,0.05,  KsPO4_NsT)
text(0.75,0.05,  KsPO4_NbT)
text(0.45,-0.03, KsO2_NsT)
text(0.75,-0.03, KsO2_NbT)

text(0.7,1,     'm^2')
text(0.7,0.92,  'm')
text(0.7,0.84,  'mm')
text(0.7,0.76,  '%')
text(0.7,0.68,  '-')
text(1,0.45,    'g/m^3')
text(1,0.37,    '1/s')
text(1,0.29,    '1/s')
text(1,0.21,    '-')
text(1,0.13,    '-')
text(1,0.05,    'g/m^3')
text(1,-0.03,   'g/m^3')

