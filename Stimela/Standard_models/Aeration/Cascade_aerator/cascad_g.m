function val = cascad_g(naamfile,plotfile)

V=st_Varia;

if nargin==0
  % 1 blok 
  ib = st_findblock(gcs,'cascad');
  if length(ib)==1
    naamfile = get_pfil(ib{1});
  else
    % meerdere blokken   
     fs = get_pfil(ib);
     n = Radiobox(strvcat(ib),'Select the parameter file of the weir aerator to be visualized');
     if length(n)
       naamfile = fs{n};
     else
       return;
     end
   end  
end

P = st_getPdata(naamfile, 'cascad');

NumCel = P.NumCel;
VBak   = P.VBak;
QgTot  = P.QgTot;
RQ     = P.RQeff;
%MeeTe  = P.MeeTe;
k2     = P.k2CH4;

% if MeeTe==1
%   MeeTe='Cocurrent';
% elseif MeeTe==0
%   MeeTe='Countercurrent';
% else
%   error(['Ongeldige Waarde 1']);
% end

eval(['load ' naamfile(1:length(naamfile)-4) '_in.sti -mat']);
eval(['load ' naamfile(1:length(naamfile)-4) '_EM.sti -mat']);
eval(['load ' naamfile(1:length(naamfile)-4) '_out.sti -mat']);

Taantal=size(cascadEM,2);

LengteIn  = size(cascadin,2);
Ql        = cascadin(V.Flow+1,LengteIn);
Tl        = cascadin(V.Temperature+1,LengteIn);
coO2      = cascadin(V.Oxygen+1,LengteIn);
coCH4     = cascadin(V.Methane+1,LengteIn);
% coCO2     = cascadin(V.Carbon_dioxide+1,LengteIn);
coHCO3    = cascadin(V.Bicarbonate+1,LengteIn);
coMn      = cascadin(V.Mnumber+1,LengteIn)/1000;
pHo       = cascadin(V.pH+1,LengteIn);
EGVo      = cascadin(V.Conductivity+1,LengteIn);
coN2      = cascadin(V.Nitrogen+1,LengteIn);
coH2S     = cascadin(V.Hydrogen_sulfide+1,LengteIn);
% coFe      = cascadin(V.Iron2+1,LengteIn);
% coCa      = cascadin(V.Calcium +1,LengteIn);


LengteUit = size(cascadout,2);
ceO2      = cascadout(V.Oxygen+1,LengteUit);
ceCH4     = cascadout(V.Methane+1,LengteUit);
ceN2      = cascadout(V.Nitrogen+1,LengteUit);
ceH2S     = cascadout(V.Hydrogen_sulfide+1,LengteUit);
ceCO2     = cascadout(V.Carbon_dioxide+1,LengteUit);
ceHCO3    = cascadout(V.Bicarbonate+1,LengteUit);
pHe       = cascadout(V.pH+1,LengteUit);
% ceFe      = cascadout(V.Iron2+1,LengteUit);
% ceCa      = cascadout(V.Calcium +1,LengteUit);

%Afronden van de luchttemperatuur op gehele getallen
Tg     = Tl;               %Lucht temperatuur in graden Celsius
% Tg     = round(Tg);        %De luchttemperatuur wordt afgerond op hele graden

%Bepalen van benodigde grootheden met betrekking tot de debieten en verblijftijden
tgem     = (NumCel*VBak)/(Ql/3600);   % Bepalen van de gemiddelde verblijftijd in de cascade, debiet van m3/h -> m3/s
tgembl   = tgem/NumCel;               % Bepalen van de gemiddelde verblijftijd in één volledig gemengd vat

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
% pw     = [  611   657   706   758   814   873   935  1002  1073  1148 ...  % pw = waterdampspanning 0-50 Celsius [Pa]
%            1228  1313  1403  1498  1599  1706  1819  1938  2064  2198 ...
%            2339  2488  2645  2810  2985  3169  3363  3567  3782  4008 ...
%            4246  4495  4758  5034  5323  5627  5945  6280  6630  6997 ...
%            7381  7784  8205  8646  9108  9590 10094 10620 11171 11745 ...
%           12344]; 
R      = 8.3143;                                                            % R = universele gasconstante [J/(K*mol)] 

  pw = 1070*exp(0.04986*Tg)-525.1;
  
  %Gasconcentraties in de lucht (Temperatuur in Kelvin)
  cgoO2  = (0.20948*(Po-pw)*(MrO2 /1000))/(R*(Tg+273)); 
  cgoCH4 =  0; 
  cgoCO2 = (0.00032*(Po-pw)*(MrCO2/1000))/(R*(Tg+273));
  cgoH2S =  0; 
  cgoN2  = (0.78084*(Po-pw)*(MrN2 /1000))/(R*(Tg+273));

% %Gasconcentraties in de lucht (Temperatuur in Kelvin)
% cgoO2  = (0.20948*(Po-pw(Tg+1))*(MrO2 /1000))/(R*(Tg+273)); 
% cgoCH4 =  0; 
% cgoCO2 = (0.00032*(Po-pw(Tg+1))*(MrCO2/1000))/(R*(Tg+273));
% cgoN2  = (0.78084*(Po-pw(Tg+1))*(MrN2 /1000))/(R*(Tg+273));
% cgoH2S =  0; 
  
% %Distributiecoëfficiënten van gassen in water voor 0, 10, 20 en 30 graden Celsius
% TkD    = [0     ;10    ;20    ;30    ];
% TkDO2  = [0.0493;0.0398;0.0337;0.0296]; 
% TkDCH4 = [0.0556;0.0433;0.0335;0.0306]; 
% TkDCO2 = [1.7100;1.2300;0.9420;0.7380];
% TkDN2  = [0.0230;0.0192;0.0166;0.0151];
% TkDH2S = [4.6900;3.6500;2.8700;2.3000];  % De kDH2S bij 30 graden 2,3 is door mij verzonnen (geen literatuur waarde)
%   
% %Berekening distributiecoëfficiënten voor tussenliggende temperaturen door lineaire interpolatie
% kDO2   = INTERP1Q(TkD,TkDO2, Tl);
% kDCH4  = INTERP1Q(TkD,TkDCH4,Tl);
% kDCO2  = INTERP1Q(TkD,TkDCO2,Tl);
% kDN2   = INTERP1Q(TkD,TkDN2, Tl);
% kDH2S  = INTERP1Q(TkD,TkDH2S,Tl);

  kDO2  = 0.02727*exp(-0.0426*Tl)+0.02202;
  kDCH4 = 0.03227*exp(-0.05315*Tl)+0.02352;
  kDCO2 = 1.307*exp(-0.04489*Tl)+0.4015;
  kDN2  = 5.75e-006*Tl^2-0.0004355*Tl+0.023;
  kDH2S = 0.001175*Tl^2-0.1148*Tl+4.688;

%De verschillende evenwichtsconstanten (Temperatuur in Kelvin)
T      = (Tl+273);
% pK1    = 356.3094 + 0.06091964*T - 21834.37/T - 126.8339*log10(T) + 1684915/(T^2);
% 
% %de concentraties in [mol/l] (met gebruik making van activiteiten):
% coHCO3 = (coHCO3/MrHCO3)*fi(1,4,EGVo);
% coCO2  = (10^(pK1-pHo+log10(coHCO3)));

  IonStrength = 0.183*EGVo;
  f = CE_Activity(IonStrength);
  [K1,K2,Kw,Ks] = KValues(T);
  coCO2=CE_pHM_CO2(pHo,coMn,K1,K2,Kw,f);

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
% dFe  = coFe-ceFe;
% dCa  = coCa-ceCa;


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
VBakT   = sprintf('%.2f',VBak);
QlT     = sprintf('%.1f',Ql);
QgTotT  = sprintf('%.1f',QgTot);
RQT     = sprintf('%.2f',RQ);
k2T     = sprintf('%.2e',k2);
NumCelT = sprintf('%.0f',NumCel);
% dFeT    = sprintf('%.2f',dFe);
% dCaT    = sprintf('%.2f',dCa);

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
stimMous(gcf);

subplot(3,2,1)
% plot((0:NumCel),cascadEM(2:NumCel+2,Taantal),'k -x');
% hold on
% plot((0:NumCel),cascadEM(2*(NumCel+1)+2:3*(NumCel+1)+1,Taantal),'k -o');

plot((0:NumCel),[coO2;cascadEM(3:NumCel+2,Taantal)],'k -x');
hold on
 plot((0:NumCel),[csoO2;cascadEM(2*(NumCel+1)+3:3*(NumCel+1)+1,Taantal)],'k -o');
%=============================START: KMS, 03/08/04=========================================
if size(Data,2)>1
  hold on
  plot(Data(:,1),Data(:,2),'*')
  hold off
end  
%=============================STOP: KMS, 03/08/04=========================================
title(['Oxygen  (Efficiency = ' RO2T ' %)'])
%xlabel('Hoogte van het gepakte bed [m]')
ylabel('O_2-concentration [mg/l]')
grid on

subplot(3,2,2)
% plot((0:NumCel),cascadEM(3*(NumCel+1)+2:4*(NumCel+1)+1,Taantal),'k -x');
% hold on
% plot((0:NumCel),cascadEM(5*(NumCel+1)+2:6*(NumCel+1)+1,Taantal),'k -o');

plot((0:NumCel),[coCH4;cascadEM(3*(NumCel+1)+3:4*(NumCel+1)+1,Taantal)],'k -x');
hold on
plot((0:NumCel),[csoCH4;cascadEM(5*(NumCel+1)+3:6*(NumCel+1)+1,Taantal)],'k -o');
%=============================START: KMS, 03/08/04=========================================
if size(Data,2)>2
  hold on
  plot(Data(:,1),Data(:,3),'*')
  hold off
end  
%=============================STOP: KMS, 03/08/04=========================================
title(['Methane  (Efficiency = ' RCH4T ' %)'])
%xlabel('Hoogte van het gepakte bed [m]')
ylabel('CH_4-concentration [mg/l]')
grid on

subplot(3,2,3)
% plot((0:NumCel),cascadEM(6*(NumCel+1)+2:7*(NumCel+1)+1,Taantal),'k -x');
% hold on
% plot((0:NumCel),cascadEM(8*(NumCel+1)+2:9*(NumCel+1)+1,Taantal),'k -o');

plot((0:NumCel),[coCO2;cascadEM(6*(NumCel+1)+3:7*(NumCel+1)+1,Taantal)],'k -x');
hold on
plot((0:NumCel),[csoCO2;cascadEM(8*(NumCel+1)+3:9*(NumCel+1)+1,Taantal)],'k -o');
%=============================START: KMS, 03/08/04=========================================
if size(Data,2)>3
  hold on
  plot(Data(:,1),Data(:,4),'*')
  hold off
end  
%=============================STOP: KMS, 03/08/04=========================================
title(['Carbondioxide  (Efficiency = ' RCO2T ' %)'])
%xlabel('Hoogte van het gepakte bed [m]')
ylabel('CO_2-concentration [mg/l]')
grid on

subplot(3,2,4)
% plot((0:NumCel),cascadEM(9*(NumCel+1)+2:10*(NumCel+1)+1,Taantal),'k -x');
% hold on
% plot((0:NumCel),cascadEM(11*(NumCel+1)+2:12*(NumCel+1)+1,Taantal),'k -o');

plot((0:NumCel),[coN2;cascadEM(9*(NumCel+1)+3:10*(NumCel+1)+1,Taantal)],'k -x');
hold on
plot((0:NumCel),[csoN2;cascadEM(11*(NumCel+1)+3:12*(NumCel+1)+1,Taantal)],'k -o');
title(['Nitrogen  (Efficiency = ' RN2T ' %)'])
xlabel('Step weirs [-]')
ylabel('N_2-concentration [mg/l]')
grid on

subplot(3,2,5)
% plot((0:NumCel),cascadEM(12*(NumCel+1)+2:13*(NumCel+1)+1,Taantal),'k -x');
% hold on
% plot((0:NumCel),cascadEM(14*(NumCel+1)+2:15*(NumCel+1)+1,Taantal),'k -o');

plot((0:NumCel),[coH2S;cascadEM(12*(NumCel+1)+3:13*(NumCel+1)+1,Taantal)],'k -x');
hold on
plot((0:NumCel),[csoH2S;cascadEM(14*(NumCel+1)+3:15*(NumCel+1)+1,Taantal)],'k -o');
title(['Hydrogen sulfide  (Efficiency = ' RH2ST ' %)'])
xlabel('Step weirs [-]')
ylabel('H_2S-concentration [mg/l]')
grid on

subplot(3,2,6)
set(gca,'Visible','off')

text(-0.1,0.9, 'Parameters:')
text(-0.1,0.8, 'Number of weirs')
text(-0.1,0.7, 'Volume of one weir chamber')
text(-0.1,0.6, 'Water flow')
text(-0.1,0.5, 'Air flow')
text(-0.1,0.4, 'Effective air to water ratio')
text(-0.1,0.29,'Gas transfer coëfficiënt (k_2)')
text(-0.1,0.2, '')
text(-0.1,0.1, 'pH:')
text(-0.1,0,   'Start pH')
text(-0.1,-0.1,'End pH')
% text(0.4,0.1,  'Iron and calcium conversion:')
% text(0.4,0,    'Oxidated iron')
% text(0.4,-0.1, 'Converted calcium')
  
text(0.55,0.8, NumCelT )
text(0.55,0.7, VBakT)
text(0.55,0.6, QlT)
text(0.55,0.5, QgTotT)
text(0.55,0.4, RQT)
text(0.5,0.3,  k2T)
%text(0.55,0.3,  )
text(0.1,0,    pHoT)
text(0.1,-0.1, pHeT)
% text(0.75,0,   dFeT)
% text(0.75,-0.1,dCaT)

text(0.7,0.8, '-')
text(0.7,0.7, 'm^3')
text(0.7,0.6, 'm^3/h')
text(0.7,0.5, 'm^3/h')
text(0.7,0.4, '-' )
text(0.7,0.3, '1/s')
text(0.7,0.2, '')
text(0.7,0,   '')
text(0.7,-0.1,'')
% text(0.9,0,   'mg/l')
% text(0.9,-0.1,'mg/l')


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
