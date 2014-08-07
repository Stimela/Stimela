function val = torbsc_g(naamfile,plotfile)

warning off;
V= st_Varia;


%=============================START: AvdBerge, 13/03/00=========================================
if nargin == 0
     ib = st_findblock(gcs,'torbsc');
   if length(ib)==1
      naamfile = get_pfil(ib{1});
   else
    % meerdere blokken   
     fs = get_pfil(ib);
     n = Radiobox(strvcat(ib),'Select the parameter file of the packed column aerator  to be visualized');
     if length(n)
       naamfile = fs{n};
     else
       return;
     end
   end  

end
%=============================STOP : AvdBerge, 13/03/00=========================================
P = st_getPdata(naamfile, 'torbsc');

Hoogte = P.Hoogte;
Diam   = P.Diam;
QgTot  = P.QgTot;
QgRec  = P.QgRec;
MeeTe  = P.MeeTe;
k2     = P.k2;
NumCel = P.NumCel;
kDVC  = P.kD;

if MeeTe==1
  MeeTe='Cocurrent';
elseif MeeTe==0
  MeeTe='Countercurrent';
elseif MeeTe==2
  MeeTe='Completely mixed air';
else
  error(['Ongeldige Waarde 1']);
end


%=============================START: AvdBerge, 13/03/00=========================================
eval(['load ' naamfile(1:length(naamfile)-4) '_EM.sti -mat']);
%=============================STOP : AvdBerge, 13/03/00=========================================

Taantal=size(torbscEM,2);


%=============================START: AvdBerge, 13/03/00=========================================
eval(['load ' naamfile(1:length(naamfile)-4) '_in.sti -mat']);
%=============================STOP : AvdBerge, 13/03/00=========================================

LengteIn  = size(torbscin,2);
Ql        = torbscin(V.Flow+1,LengteIn);
Tl        = torbscin(V.Temperature+1,LengteIn);
coVC     = torbscin(V.Volatile_compound+1,LengteIn);

%=============================START: AvdBerge, 13/03/00=========================================
eval(['load ' naamfile(1:length(naamfile)-4) '_out.sti -mat']);
%=============================STOP : AvdBerge, 13/03/00=========================================

Lengteout = size(torbscout,2);
ceVC     = torbscout(V.Volatile_compound+1,Lengteout);

%Afronden van de luchttemperatuur op gehele getallen
Tg     = Tl;               %Lucht temperatuur in graden Celsius
Tg     = round(Tg);        %De luchttemperatuur wordt afgerond op hele graden

%Bepalen van benodigde grootheden met betrekking tot de debieten en verblijftijden
RQ       = QgTot/Ql;           % Bepalen van de lucht-waterverhouding
Ql       = Ql/3600;            % Omzetten van het debiet van m3/h -> m3/s
OppTot   = 0.25*pi*(Diam)^2;   % Bepalen van het totale oppervlak van de BOT
tgem     = Hoogte/(Ql/OppTot); % Bepalen van de gemiddelde verblijftijd in de BOT
tgembl   = tgem/NumCel;        % Bepalen van de gemiddelde verblijftijd in één volledig gemengd vat

%De relatieve molecuulmassa's [mg/mol] 
MrVC  = 1000*16.04303; 

%Constanten voor de berekening van de gasconcentraties in de lucht
Po     = 101325;                                                           % po = standaarddruk zeeniveau [Pa]  
pw     = [  611   657   706   758   814   873   935  1002  1073  1148 ...  % pw = waterdampspanning 0-50 Celsius [Pa]
           1228  1313  1403  1498  1599  1706  1819  1938  2064  2198 ...
           2339  2488  2645  2810  2985  3169  3363  3567  3782  4008 ...
           4246  4495  4758  5034  5323  5627  5945  6280  6630  6997 ...
           7381  7784  8205  8646  9108  9590 10094 10620 11171 11745 ...
          12344]; 
R      = 8.3143;                                                            % R = universele gasconstante [J/(K*mol)] 
  
%Gasconcentraties in de lucht (Temperatuur in Kelvin)
cgoVC =  0; 
  
%Distributiecoëfficiënten van gassen in water voor 0, 10, 20 en 30 graden Celsius
  
%Berekening distributiecoëfficiënten voor tussenliggende temperaturen door lineaire interpolatie

%De verschillende evenwichtsconstanten (Temperatuur in Kelvin)
T      = (Tl+273);

%de concentraties in [mol/l] (met gebruik making van activiteiten):

%de concentraties in [mg/l]:

%Gasverzadigingsconcentraties  
csoVC = kDVC * cgoVC;


%Berekening
RVC = ((ceVC-coVC)/(csoVC-coVC))*100;

%=============================START: KMS, 03/08/04=========================================
%inlezen data
Data=[];
if nargin==2
  Data=st_LoadTxt(plotfile);
end  
%=============================STOP : AvdBerge, 03/08/04=========================================

%Omzetten van getallen naar strings voor weergave
RVCT   = sprintf('%.1f',RVC);
HoogteT = sprintf('%.2f',Hoogte);
DiamT   = sprintf('%.2f',Diam);
QgTotT  = sprintf('%.1f',QgTot);
QgRecT  = sprintf('%.1f',QgRec);
RQT     = sprintf('%.1f',RQ);
k2T     = sprintf('%.2e',k2);
kDVCT  = sprintf('%.2e',kDVC);
NumCelT = sprintf('%.0f',NumCel);



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
set(gcf,'Name',[MeeTe ' packed column aerator, the gasconcentrations in water and the gas saturation concentrations']);
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

subplot(2,1,1)
plot((0:NumCel)*(Hoogte/NumCel),torbscEM(2:NumCel+2,Taantal),'k -x');
hold on
plot((0:NumCel)*(Hoogte/NumCel),torbscEM(2*(NumCel+1)+2:3*(NumCel+1)+1,Taantal),'k -o');
%=============================START: KMS, 03/08/04=========================================
if size(Data,2)>1
  hold on
  plot(Data(:,1),Data(:,2),'*')
  hold off
end  
% ============================STOP: KMS,%03/08/04=========================================
title(['Volatile compound  (Efficiency = ' RVCT ' %)'])
%xlabel('Height of the packed bed [m]')
ylabel('Concentration [mmol/l]')
legend('Gas concentration in water', 'Gas saturation concentration')
grid on


subplot(2,1,2)
set(gca,'Visible','off')

text(0,1.0, 'Parameters:')
text(0,0.9, 'Heigth of the packed bed')
text(0,0.8, 'Diameter of the packed bed')
text(0,0.7, 'Total air flow')
text(0,0.6, 'Recirculation air flow')
text(0,0.5, 'Air to water ratio')
text(0,0.39,'Gas transfer coëfficiënt (k_2)')
text(0,0.3, 'Distribution coefficient (kD)')
text(0,0.2, 'Number of completely mixed reactors')


text(0.55,0.9, HoogteT )
text(0.55,0.8, DiamT)
text(0.55,0.7, QgTotT)
text(0.55,0.6, QgRecT)
text(0.55,0.5, RQT)
text(0.55,0.4, k2T)
text(0.55,0.3, kDVCT)
text(0.55,0.2, NumCelT)

text(0.7,0.9, 'm')
text(0.7,0.8, 'm')
text(0.7,0.7, 'm^3/h')
text(0.7,0.6, 'm^3/h' )
text(0.7,0.5, '' )
text(0.7,0.4, '1/s')
text(0.7,0.3, '')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Functions which are used in this m.file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The following function returns the ion activity

function [fiF] = fi(z,a,EGV)

EGV = EGV/1000;% S/m
I = 0.183*EGV;% mol/l benaderingsformule
if I>=0 & I<0.1
  fiF=10^(-0.5*z^2*(I^0.5/(1+0.33*a*I^0.5)));
elseif 0.1<=I & I<=0.5
  fiF=10^(-0.5*z^2*((I^0.5/(1+0.33*a*I^0.5))-0.2*I));
else
 error(['Ongeldige Waarde EGV']);
end
