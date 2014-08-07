function val = torbk2_g(naamfile,plotfile)

V= st_Varia;

if nargin == 0
  ib = st_findblock(gcs,'torbk2');
  if length(ib)==1
    naamfile = get_pfil(ib{1});
  else
    % meerdere blokken   
     fs = get_pfil(ib);
     n = Radiobox(strvcat(ib),'Select the parameter file of the packed column aerator to be visualized');
     if length(n)
       naamfile = fs{n};
     else
       return;
     end
   end  
end
P = st_getPdata(naamfile, 'torbk2');

Hoogte = P.Hoogte;
Diam   = P.Diam;
QgTot  = P.QgTot;
%QgRec  = P.QgRec;
MeeTe  = P.MeeTe;
k2     = P.k2;
NumCel = P.NumCel;

if MeeTe==1
  MeeTe='Cocurrent';
elseif MeeTe==0
  MeeTe='Countercurrent';
elseif MeeTe==2
  MeeTe='Completely mixed air';
else
  error(['Ongeldige Waarde 1']);
end


eval(['load ' naamfile(1:length(naamfile)-4) '_in.sti -mat']);
eval(['load ' naamfile(1:length(naamfile)-4) '_out.sti -mat']);
eval(['load ' naamfile(1:length(naamfile)-4) '_EM.sti -mat']);

Taantal=size(torbk2EM,2);


LengteIn  = size(torbk2in,2);
Ql        = torbk2in(V.Flow+1,LengteIn);
Tl        = torbk2in(V.Temperature+1,LengteIn);
coO2      = torbk2in(V.Oxygen+1,LengteIn);
coCH4     = torbk2in(V.Methane+1,LengteIn);
coCO2     = torbk2in(V.Carbon_dioxide+1,LengteIn);
coHCO3    = torbk2in(V.Bicarbonate+1,LengteIn);
pHo       = torbk2in(V.pH+1,LengteIn);
EGVo      = torbk2in(V.Conductivity+1,LengteIn);
coN2      = torbk2in(V.Nitrogen+1,LengteIn);
coH2S     = torbk2in(V.Hydrogen_sulfide+1,LengteIn);
coFe      = torbk2in(V.Iron2+1,LengteIn);
coCa      = torbk2in(V.Calcium +1,LengteIn);

Lengteout = size(torbk2out,2);
ceO2      = torbk2out(V.Oxygen+1,Lengteout);
ceCH4     = torbk2out(V.Methane+1,Lengteout);
ceN2      = torbk2out(V.Nitrogen+1,Lengteout);
ceH2S     = torbk2out(V.Hydrogen_sulfide+1,Lengteout);
ceCO2     = torbk2out(V.Carbon_dioxide+1,Lengteout);
ceHCO3    = torbk2out(V.Bicarbonate+1,Lengteout);
pHe       = torbk2out(V.pH+1,Lengteout);
ceFe      = torbk2out(V.Iron2+1,Lengteout);
ceCa      = torbk2out(V.Calcium +1,Lengteout);

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
MrCO2  = 1000*44.01;
MrHCO3 = 1000*61.02;
MrHCO3 = 1000*61.02;
MrFe   = 1000*55.847;
MrO2   = 1000*31.9988;
MrCH4  = 1000*16.04303; 
MrCa   = 1000*40.02;
MrCaCO3= 1000*100.08935; 
MrN2   = 1000*28.0134;
MrH2S  = 1000*34.08;

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
cgoO2  = (0.20948*(Po-pw(Tg+1))*(MrO2 /1000))/(R*(Tg+273)); 
cgoCH4 =  0; 
cgoCO2 = (0.00032*(Po-pw(Tg+1))*(MrCO2/1000))/(R*(Tg+273));
cgoN2  = (0.78084*(Po-pw(Tg+1))*(MrN2 /1000))/(R*(Tg+273));
cgoH2S =  0; 
  
%Distributiecoëfficiënten van gassen in water voor 0, 10, 20 en 30 graden Celsius
TkD    = [0     ;10    ;20    ;30    ];
TkDO2  = [0.0493;0.0398;0.0337;0.0296]; 
TkDCH4 = [0.0556;0.0433;0.0335;0.0306]; 
TkDCO2 = [1.7100;1.2300;0.9420;0.7380];
TkDN2  = [0.0230;0.0192;0.0166;0.0151];
TkDH2S = [4.6900;3.6500;2.8700;2.3000];  % De kDH2S bij 30 graden 2,3 is door mij verzonnen (geen literatuur waarde)
  
%Berekening distributiecoëfficiënten voor tussenliggende temperaturen door lineaire interpolatie
kDO2   = INTERP1Q(TkD,TkDO2, Tl);
kDCH4  = INTERP1Q(TkD,TkDCH4,Tl);
kDCO2  = INTERP1Q(TkD,TkDCO2,Tl);
kDN2   = INTERP1Q(TkD,TkDN2, Tl);
kDH2S  = INTERP1Q(TkD,TkDH2S,Tl);

%De verschillende evenwichtsconstanten (Temperatuur in Kelvin)
T      = (Tl+273);
pK1    = 356.3094 + 0.06091964*T - 21834.37/T - 126.8339*log10(T) + 1684915/(T^2);

%de concentraties in [mol/l] (met gebruik making van activiteiten):
coHCO3 = (coHCO3/MrHCO3)*fi(1,4,EGVo);
coCO2  = (10^(pK1-pHo+log10(coHCO3)));

%de concentraties in [mg/l]:
coCO2  = coCO2*MrCO2;

%Gasverzadigingsconcentraties  
csoO2  = kDO2  * cgoO2;
csoCH4 = kDCH4 * cgoCH4;
csoCO2 = kDCO2 * cgoCO2;
csoN2  = kDN2  * cgoN2;
csoH2S = kDH2S * cgoH2S;


%Berekening
RO2  = ((ceO2-coO2)  /(csoO2-coO2))  *100;
RCH4 = ((ceCH4-coCH4)/(csoCH4-coCH4))*100;
RCO2 = ((ceCO2-coCO2)/(csoCO2-coCO2))*100;
RN2  = ((ceN2-coN2)  /(csoN2-coN2))  *100;
RH2S = ((ceH2S-coH2S)/(csoH2S-coH2S))*100;
dFe  = coFe-ceFe;
dCa  = coCa-ceCa;

%=============================START: KMS, 03/08/04=========================================
%inlezen data
Data=[];
if nargin==2
  Data=st_LoadTxt(plotfile);
end  
%=============================STOP : AvdBerge, 03/08/04=========================================

%Omzetten van getallen naar strings voor weergave
RO2T    = sprintf('%.1f',RO2);
RCH4T   = sprintf('%.1f',RCH4);
RCO2T   = sprintf('%.1f',RCO2);
RN2T    = sprintf('%.1f',RN2);
RH2ST   = sprintf('%.1f',RH2S);
pHoT    = sprintf('%.2f',pHo);
pHeT    = sprintf('%.2f',pHe);
HoogteT = sprintf('%.2f',Hoogte);
DiamT   = sprintf('%.2f',Diam);
QgTotT  = sprintf('%.1f',QgTot);
%QgRecT  = sprintf('%.1f',QgRec);
RQT     = sprintf('%.1f',RQ);
k2T     = sprintf('%.2e',k2);
NumCelT = sprintf('%.0f',NumCel);
dFeT    = sprintf('%.2f',dFe);
dCaT    = sprintf('%.2f',dCa);



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

subplot(3,2,1)
plot((0:NumCel)*(Hoogte/NumCel),torbk2EM(2:NumCel+2,Taantal),'k -x');
hold on
plot((0:NumCel)*(Hoogte/NumCel),torbk2EM(2*(NumCel+1)+2:3*(NumCel+1)+1,Taantal),'k -o');
%=============================START: KMS, 03/08/04=========================================
if size(Data,2)>1
  hold on
  plot(Data(:,1),Data(:,2),'*')
  hold off
end  
% ============================STOP: KMS,%03/08/04=========================================
title(['Oxygen  (Efficiency = ' RO2T ' %)'])
%xlabel('Height of the packed bed [m]')
ylabel('O_2-concentration [mg/l]')
grid on

subplot(3,2,2)
plot((0:NumCel)*(Hoogte/NumCel),torbk2EM(3*(NumCel+1)+2:4*(NumCel+1)+1,Taantal),'k -x');
hold on
plot((0:NumCel)*(Hoogte/NumCel),torbk2EM(5*(NumCel+1)+2:6*(NumCel+1)+1,Taantal),'k -o');
%=============================START: KMS, 03/08/04=========================================
if size(Data,2)>2
  hold on
  plot(Data(:,1),Data(:,3),'*')
  hold off
end  
%=============================STOP: KMS, 03/08/04=========================================
title(['Methane  (Efficiency = ' RCH4T ' %)'])
%xlabel('Height of the packed bed [m]')
ylabel('CH_4-concentration [mg/l]')
grid on

subplot(3,2,3)
plot((0:NumCel)*(Hoogte/NumCel),torbk2EM(6*(NumCel+1)+2:7*(NumCel+1)+1,Taantal),'k -x');
hold on
plot((0:NumCel)*(Hoogte/NumCel),torbk2EM(8*(NumCel+1)+2:9*(NumCel+1)+1,Taantal),'k -o');
%=============================START: KMS, 03/08/04=========================================
if size(Data,2)>3
  hold on
  plot(Data(:,1),Data(:,4),'*')
  hold off
end  
%=============================STOP: KMS, 03/08/04=========================================
title(['Carbondioxide  (Efficiency = ' RCO2T ' %)'])
%xlabel('Height of the packed bed [m]')
ylabel('CO_2-concentration [mg/l]')
grid on

subplot(3,2,4)
plot((0:NumCel)*(Hoogte/NumCel),torbk2EM(9*(NumCel+1)+2:10*(NumCel+1)+1,Taantal),'k -x');
hold on
plot((0:NumCel)*(Hoogte/NumCel),torbk2EM(11*(NumCel+1)+2:12*(NumCel+1)+1,Taantal),'k -o');
title(['Nitrogen  (Efficiency = ' RN2T ' %)'])
xlabel('Height of the packed bed [m]')
ylabel('N_2-concentration [mg/l]')
grid on

subplot(3,2,5)
plot((0:NumCel)*(Hoogte/NumCel),torbk2EM(12*(NumCel+1)+2:13*(NumCel+1)+1,Taantal),'k -x');
hold on
plot((0:NumCel)*(Hoogte/NumCel),torbk2EM(14*(NumCel+1)+2:15*(NumCel+1)+1,Taantal),'k -o');
title(['Hydrogen sulfide  (Efficiency = ' RH2ST ' %)'])
xlabel('Height of the packed bed [m]')
ylabel('H_2S-concentration [mg/l]')
grid on


subplot(3,2,6)
set(gca,'Visible','off')

text(-0.1,1.0, 'Parameters:')
text(-0.1,0.9, 'Heigth of the packed bed')
text(-0.1,0.8, 'Diameter of the packed bed')
text(-0.1,0.7, 'Total air flow')
text(-0.1,0.6, 'Recirculation air flow')
text(-0.1,0.5, 'Air to water ratio')
text(-0.1,0.39,'Gas transfer coëfficiënt (k_2)')
text(-0.1,0.3, 'Number of completely mixed reactors')
text(-0.1,0.1, 'pH:')
text(-0.1,0,   'Start pH')
text(-0.1,-0.1,'End pH')
text(0.4,0.1,  'Iron and calcium conversion:')
text(0.4,0,    'Oxidated iron')
text(0.4,-0.1, 'Converted calcium')

text(0.55,0.9, HoogteT )
text(0.55,0.8, DiamT)
text(0.55,0.7, QgTotT)
%text(0.55,0.6, QgRecT)
text(0.55,0.5, RQT)
text(0.5,0.4,  k2T)
text(0.55,0.3, NumCelT)
text(0.1,0,    pHoT)
text(0.1,-0.1, pHeT)
text(0.75,0,   dFeT)
text(0.75,-0.1,dCaT)

text(0.7,0.9, 'm')
text(0.7,0.8, 'm')
text(0.7,0.7, 'm^3/h')
text(0.7,0.6, 'm^3/h' )
text(0.7,0.5, '' )
text(0.7,0.4, '1/s')
text(0.7,0.3, '')
text(0.7,0,   '')
text(0.7,-0.1,'')
text(0.9,0,   'mg/l')
text(0.9,-0.1,'mg/l')


subplot('position',[0.25 .02 0.5 0.03])
set(gca,'Visible','off');
surface([0 1;0 1],[0 0;1 1],[0 0;0 0],'facecolor',[1,1,1]);
text(0.5,0.5,' -x-  Gas concentrations in water    -o-  Gas saturation concentrations','HorizontalAlignment','center','VerticalAlignment','middle')




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
