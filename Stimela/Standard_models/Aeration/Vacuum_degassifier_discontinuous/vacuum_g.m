function val = vacuum_g(naamfile,plotfile)

warning off;
V=st_Varia;


%=============================START: AvdBerge, 13/03/00=========================================
if nargin==0
     ib = st_findblock(gcs,'vacuum');
   if length(ib)==1
      naamfile = get_pfil(ib{1});
   else
    % meerdere blokken   
     fs = get_pfil(ib);
     n = Radiobox(strvcat(ib),'Select the parameter file of the vacuum degassifier discontinuous  to be visualized');
     if length(n)
       naamfile = fs{n};
     else
       return;
     end
   end  
end
%=============================STOP : AvdBerge, 13/03/00=========================================

P = st_getPdata(naamfile, 'vacuum');

Hoogte   = P.Height;
Diam     = P.Diam; 
PercOpen = P.PercOpen;
Percl    = P.Percl;
Tvac     = P.Tvac;
Tpomp    = P.Tpump;
k2       = P.k2;
NumCel   = P.NumCel;

Percg    = PercOpen-Percl;


%=============================START: AvdBerge, 13/03/00=========================================
eval(['load ' naamfile(1:length(naamfile)-4) '_EM.sti -mat']);
%=============================STOP : AvdBerge, 13/03/00=========================================

Taantal=size(vacuumEM,2);
vacuumEM(1,Taantal);


%=============================START: AvdBerge, 13/03/00=========================================
eval(['load ' naamfile(1:length(naamfile)-4) '_in.sti -mat']);
%=============================STOP : AvdBerge, 13/03/00=========================================

LengteIn  = size(vacuumin,2);
Ql        = vacuumin(V.Flow+1,LengteIn);
Tl        = vacuumin(V.Temperature+1,LengteIn);
coO2      = vacuumin(V.Oxygen+1,LengteIn);
coCH4     = vacuumin(V.Methane+1,LengteIn);
coCO2     = vacuumin(V.Carbon_dioxide+1,LengteIn);
coHCO3    = vacuumin(V.Bicarbonate+1,LengteIn);
pHo       = vacuumin(V.pH+1,LengteIn);
EGVo      = vacuumin(V.Conductivity+1,LengteIn);
coN2      = vacuumin(V.Nitrogen+1,LengteIn);
coH2S     = vacuumin(V.Hydrogen_sulfide+1,LengteIn);
coFe      = vacuumin(V.Iron2+1,LengteIn);
coCa      = vacuumin(V.Calcium +1,LengteIn);


%=============================START: AvdBerge, 13/03/00=========================================
eval(['load ' naamfile(1:length(naamfile)-4) '_out.sti -mat']);
%=============================STOP : AvdBerge, 13/03/00=========================================

Lengteout = size(vacuumout,2);
ceO2      = vacuumout(V.Oxygen+1,Lengteout);
ceCH4     = vacuumout(V.Methane+1,Lengteout);
ceN2      = vacuumout(V.Nitrogen+1,Lengteout);
ceH2S     = vacuumout(V.Hydrogen_sulfide+1,Lengteout);
ceCO2     = vacuumout(V.Carbon_dioxide+1,Lengteout);
ceHCO3    = vacuumout(V.Bicarbonate+1,Lengteout);
pHe       = vacuumout(V.pH+1,Lengteout);
ceFe      = vacuumout(V.Iron2+1,Lengteout);
ceCa      = vacuumout(V.Calcium +1,Lengteout);

TR   = vacuumout(1,Lengteout) - (2*Tpomp+Tvac); % 
tel1 = 0;
tel2 = 0;
for tel = 1:Lengteout
   if vacuumout(1,tel) >= TR   
      tel2=tel2+1;
      minmax(1,tel2) = tel;
   else
   end
end


O2min  = min(vacuumout(V.Oxygen+1,minmax));
O2max  = max(vacuumout(V.Oxygen+1,minmax));
CH4min = min(vacuumout(V.Methane+1,minmax));
CH4max = max(vacuumout(V.Methane+1,minmax));
CO2min = min(vacuumout(V.Carbon_dioxide+1,minmax));
CO2max = max(vacuumout(V.Carbon_dioxide+1,minmax));
N2min  = min(vacuumout(V.Nitrogen+1,minmax));
N2max  = max(vacuumout(V.Nitrogen+1,minmax));
H2Smin = min(vacuumout(V.Hydrogen_sulfide+1,minmax));
H2Smax = max(vacuumout(V.Hydrogen_sulfide+1,minmax));
pHmin  = min(vacuumout(V.pH+1,minmax));
pHmax  = max(vacuumout(V.pH+1,minmax));
PTotmin= min(vacuumEM(26*(NumCel+1)+1,minmax))/1000;
PTotmax= max(vacuumEM(26*(NumCel+1)+1,minmax))/1000;

O2nomin  = minmax(1,find((vacuumout(V.Oxygen+1,minmax)-O2min)==0));
O2nomax  = minmax(1,find((vacuumout(V.Oxygen+1,minmax)-O2max)==0));
CH4nomin = minmax(1,find((vacuumout(V.Methane+1,minmax)-CH4min)==0));
CH4nomax = minmax(1,find((vacuumout(V.Methane+1,minmax)-CH4max)==0));
CO2nomin = minmax(1,find((vacuumout(V.Carbon_dioxide+1,minmax)-CO2min)==0));
CO2nomax = minmax(1,find((vacuumout(V.Carbon_dioxide+1,minmax)-CO2max)==0));
N2nomin  = minmax(1,find((vacuumout(V.Nitrogen+1,minmax)-N2min)==0));
N2nomax  = minmax(1,find((vacuumout(V.Nitrogen+1,minmax)-N2max)==0));
H2Snomin = minmax(1,find((vacuumout(V.Hydrogen_sulfide+1,minmax)-H2Smin)==0));
H2Snomax = minmax(1,find((vacuumout(V.Hydrogen_sulfide+1,minmax)-H2Smax)==0));

  
%Afronden van de luchttemperatuur op gehele getallen
Tg     = Tl;               %Lucht temperatuur in graden Celsius
Tg     = round(Tg);        %De luchttemperatuur wordt afgerond op hele graden

%Bepalen van benodigde grootheden met betrekking tot de debieten en verblijftijden
Ql       = Ql/3600;           % Omzetten van het debiet van m3/h -> m3/s
OppTot   = 0.25*pi*(Diam)^2;  % Oppervlak van de ronde vacuumontgasser
Fluxl    = Ql/OppTot;         % Flux door de vacuumontgasser [m/s]
tgem     = Hoogte/Fluxl;      % Bepalen van de gemiddelde verblijftijd in de vacuumontgasser
tgembl   = tgem/NumCel;       % Bepalen van de gemiddelde verblijftijd in één volledig gemengd vat


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
if O2max == 0
   RO2min = ((O2max-coO2)/(csoO2-coO2))*100;;
else
   RO2min = ((coO2-O2max)/(coO2))*100;
end
if O2min == 0
   RO2max = ((O2min-coO2)/(csoO2-coO2))*100;;
else
   RO2max = ((coO2-O2min)/(coO2))*100;
end

RCH4min = ((CH4max-coCH4)/(csoCH4-coCH4))*100;
RCH4max = ((CH4min-coCH4)/(csoCH4-coCH4))*100;

RCO2min = ((CO2max-coCO2)/(csoCO2-coCO2))*100;
RCO2max = ((CO2min-coCO2)/(csoCO2-coCO2))*100;

if N2max == 0
   RN2min = ((N2max-coN2)/(csoN2-coN2))*100;
else
   RN2min = ((coN2-N2max)/(coN2))*100;
end
if N2min == 0
   RN2max = ((N2min-coN2)/(csoN2-coN2))*100;
else
   RN2max = ((coN2-N2min)/(coN2))*100;
end

RH2Smin = ((H2Smax-coH2S)/(csoH2S-coH2S))*100;
RH2Smax = ((H2Smin-coH2S)/(csoH2S-coH2S))*100;

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
RO2maxT   = sprintf('%.1f',RO2max);
RO2minT   = sprintf('%.1f',RO2min);
RCH4maxT  = sprintf('%.1f',RCH4max);
RCH4minT  = sprintf('%.1f',RCH4min);
RCO2maxT  = sprintf('%.1f',RCO2max);
RCO2minT  = sprintf('%.1f',RCO2min);
RN2maxT   = sprintf('%.1f',RN2max);
RN2minT   = sprintf('%.1f',RN2min);
RH2SmaxT  = sprintf('%.1f',RH2Smax);
RH2SminT  = sprintf('%.1f',RH2Smin);
pHoT      = sprintf('%.2f',pHo);
pHminT    = sprintf('%.2f',pHmin);
pHmaxT    = sprintf('%.2f',pHmax);
HoogteT   = sprintf('%.2f',Hoogte);
DiamT     = sprintf('%.2f',Diam);
PercOpenT = sprintf('%.1f',PercOpen);
PerclT    = sprintf('%.1f',Percl);
PercgT     = sprintf('%.1f',Percg);
k2T       = sprintf('%.2e',k2);
NumCelT   = sprintf('%.0f',NumCel);
dFeT      = sprintf('%.2f',dFe);
dCaT      = sprintf('%.2f',dCa);
PTotmaxT  = sprintf('%.2f',PTotmax);
PTotminT  = sprintf('%.2f',PTotmin);

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
set(gcf,'Name',['Vacuum degassifier with discontinuous vacuum pump, the gasconcentrations in water and the gas saturation concentrations']);
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
%plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(2:NumCel+2,Taantal),'k -x');
plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(2:NumCel+2,O2nomin),'g -x');
hold on
plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(2:NumCel+2,O2nomax),'r -x');
hold on
%plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(2*(NumCel+1)+2:3*(NumCel+1)+1,Taantal),'k -o');
plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(2*(NumCel+1)+2:3*(NumCel+1)+1,O2nomin),'g -o');
hold on
plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(2*(NumCel+1)+2:3*(NumCel+1)+1,O2nomax),'r -o');
%=============================START: KMS, 03/08/04=========================================
if size(Data,2)>1
  hold on
  plot(Data(:,1),Data(:,2),'*')
  hold off
end  
%=============================STOP: KMS, 03/08/04=========================================
title(['Oxygen,  Efficiency max = ' RO2maxT ' % (green)  min = ' RO2minT ' % (red)'])
%xlabel('Height of the packed bed [m]')
ylabel('O_2-concentration [mg/l]')
grid on

subplot(3,2,2)
%plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(3*(NumCel+1)+2:4*(NumCel+1)+1,Taantal),'k -x');
plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(3*(NumCel+1)+2:4*(NumCel+1)+1,CH4nomin),'g -x');
hold on
plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(3*(NumCel+1)+2:4*(NumCel+1)+1,CH4nomax),'r -x');
hold on
%plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(5*(NumCel+1)+2:6*(NumCel+1)+1,Taantal),'k -o');
plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(5*(NumCel+1)+2:6*(NumCel+1)+1,CH4nomin),'g -o');
hold on
plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(5*(NumCel+1)+2:6*(NumCel+1)+1,CH4nomax),'r -o');
%=============================START: KMS, 03/08/04=========================================
if size(Data,2)>2
  hold on
  plot(Data(:,1),Data(:,3),'*')
  hold off
end  
%=============================STOP: KMS, 03/08/04=========================================
title(['Methane,  Efficiency max = ' RCH4maxT ' % (green)   min = ' RCH4minT ' % (red)'])
%xlabel('Height of the packed bed [m]')
ylabel('CH_4-concentration [mg/l]')
grid on

subplot(3,2,3)
%plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(6*(NumCel+1)+2:7*(NumCel+1)+1,Taantal),'k -x');
plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(6*(NumCel+1)+2:7*(NumCel+1)+1,CO2nomin),'g -x');
hold on
plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(6*(NumCel+1)+2:7*(NumCel+1)+1,CO2nomax),'r -x');
hold on
%plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(8*(NumCel+1)+2:9*(NumCel+1)+1,Taantal),'k -o');
plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(8*(NumCel+1)+2:9*(NumCel+1)+1,CO2nomin),'g -o');
hold on
plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(8*(NumCel+1)+2:9*(NumCel+1)+1,CO2nomax),'r -o');
%=============================START: KMS, 03/08/04=========================================
if size(Data,2)>3
  hold on
  plot(Data(:,1),Data(:,4),'*')
  hold off
end  
%=============================STOP: KMS, 03/08/04=========================================
title(['Carbondioxide,  Efficiency max = ' RCO2maxT ' % (green)  min = ' RCO2minT ' % (red)'])
%xlabel('Height of the packed bed [m]')
ylabel('CO_2-concentration [mg/l]')
grid on

subplot(3,2,4)
%plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(9*(NumCel+1)+2:10*(NumCel+1)+1,Taantal),'k -x');
plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(9*(NumCel+1)+2:10*(NumCel+1)+1,N2nomin),'g -x');
hold on
plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(9*(NumCel+1)+2:10*(NumCel+1)+1,N2nomax),'r -x');
hold on
%plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(11*(NumCel+1)+2:12*(NumCel+1)+1,Taantal),'k -o');
plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(11*(NumCel+1)+2:12*(NumCel+1)+1,N2nomin),'g -o');
hold on
plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(11*(NumCel+1)+2:12*(NumCel+1)+1,N2nomax),'r -o');
title(['Nitrogen,  Efficiency max = ' RN2maxT ' % (green)  min = ' RN2minT ' %(red)'])
xlabel('Height of the packed bed [m]')
ylabel('N_2-concentration [mg/l]')
grid on

subplot(3,2,5)
%plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(12*(NumCel+1)+2:13*(NumCel+1)+1,Taantal),'k -x');
plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(12*(NumCel+1)+2:13*(NumCel+1)+1,H2Snomin),'g -x');
hold on
plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(12*(NumCel+1)+2:13*(NumCel+1)+1,H2Snomax),'r -x');
hold on
%plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(14*(NumCel+1)+2:15*(NumCel+1)+1,Taantal),'k -o');
plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(14*(NumCel+1)+2:15*(NumCel+1)+1,H2Snomin),'g -o');
hold on
plot((0:NumCel)*(Hoogte/NumCel),vacuumEM(14*(NumCel+1)+2:15*(NumCel+1)+1,H2Snomax),'r -o');
title(['Hydrogen sulfide,  Efficiency max = ' RH2SmaxT ' % (green)  min = ' RH2SminT ' % (red)'])
xlabel('Height of the packed bed [m]')
ylabel('H_2S-concentration [mg/l]')
grid on


subplot(3,2,6)
set(gca,'Visible','off')

text(-0.1,1.0, 'Parameters:')
text(-0.1,0.9, 'Heigth of the packed bed')
text(-0.1,0.8, 'Diameter of the packed bed')
text(-0.1,0.7, 'Free volume packing')
text(-0.1,0.6, 'Wet area of the cross section')
text(-0.1,0.5, 'Air area of the cross section')
text(-0.1,0.39,'Gas transfer coëfficiënt (k_2)')
text(-0.1,0.3, 'Number of completely mixed reactors')
text(-0.1,0.1, 'Start pH')
text(-0.1,0,   'End pH max')
text(-0.1,-0.1,'End pH min')
text(0.4,0.1,  'Pressure in the vacuum degassifier:')
text(0.4,0,    'Minimum pressure')
text(0.4,-0.1, 'Maximum pressure')

text(0.55,0.9, HoogteT )
text(0.55,0.8, DiamT)
text(0.55,0.7, PercOpenT)
text(0.55,0.6, PerclT)
text(0.55,0.5, PercgT)
text(0.5,0.4,  k2T)
text(0.55,0.3, NumCelT)
text(0.2,0.1,  pHoT)
text(0.2,0,    pHmaxT)
text(0.2,-0.1, pHminT)
text(0.75,0,   PTotminT)
text(0.75,-0.1,PTotmaxT)

text(0.7,0.9, 'm')
text(0.7,0.8, 'm')
text(0.7,0.7, '%')
text(0.7,0.6, '%' )
text(0.7,0.5, '%' )
text(0.7,0.4, '1/s')
text(0.7,0.3, '')
text(0.7,0,   '')
text(0.7,-0.1,'')
text(0.9,0,   'kPa')
text(0.9,-0.1,'kPa')


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
