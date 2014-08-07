function F=calRTD(cal,FileName,MagnitudeCal,CalPar,CSTR)

FileName
MagnitudeCal
CSTR

%Bubble Column
eval(['load ' FileName '_TD'])
Pr1=['[' num2str(cal*MagnitudeCal,12) ']']
Pr2=['[' num2str(CSTR,12) ']']
eval(['save ' FileName '_TD Pr1 Pr2 Pr3 Pr4 Pr5 Pr6 Pr7 Pr8 Pr9'])

Pr1=eval(Pr1,'error(''Ongeldige Waarde 1'')');
Pr2=eval(Pr2,'error(''Ongeldige Waarde 1'')');

%th = Pr1;         %hydraulic retention time

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LET OP, VOOR GEVORDERDEN:
% Aangepaste verblijftijdspreidingscurven
% Het volgende blok kan gebruikt worden wanneer het gewenst is de waterstroom niet in allemaal evengrootte
% gemengde vaten op te delen maar in gemengde vaten van verschillende grootten. Hiermee kan in principe
% iedere willekeurige verblijftijdspreidingscurve benaderd worden.  
% Voorbeeld:
% Aantal = 2, TijdAantal = 0.9, totale verblijftijd = 100 seconden en NumCel = 10 (aantal volledig gemende vaten)
% in dit geval hebben de eerste 8 volledige gemengde vaten een totale verblijftijd van 0.1 * 100 = 10 seconden
% dat betekent dat ieder van de eerste 8 vaten een verblijftijd heeft van 10/8 = 1.25 seconde. De laatste
% twee vaten hebben een totale verblijftijd van 0.9 * 100 = 90 seconden dat betekent dat ieder van de laatste
% twee vaten een verblijftijd heeft van 90/2 = 45 seconden. Dit zal tot gevolg hebben dat de piek in de
% verblijftijdspreidingscurve eerder optreedt en lager zal zijn dan bij 10 evengrootte volledig gemengde vaten.
% Indien dit wordt toegepast moet de stromingsmatrix MatQ3 worden aangepast, zie opmerking bij 'stromingsmatrices'
%%%%%%%%
%Aantal     = NumCelBC-5;                        % De laatste volledig gemengde vaten, Aantal ( Aantal =< NumCel), hebben 
%TijdAantal = 0.95;                      % een deel, TijdAantal (0 =< TijdAantal =< 1) van de totale verblijftijd
%Tel        = 0;                        % initialiseren teller
%for Tel=1:1:(NumCelBC-Aantal)
%  dhnew(Tel,1)=((1-TijdAantal)*HreactBC)/(NumCelBC-Aantal);
%end
%for Tel=(NumCelBC-Aantal+1):1:NumCelBC
%  dhnew(Tel,1)=(TijdAantal*HreactBC)/Aantal;
%end
%dhBC = dhnew;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


sim('Time_distribution')


eval(['load ' FileName '_TD_uit.sti -mat'])

%Ophalen van de variabelen
warning off;
[a,Variables]=varia;

SimConduc = timedsuit(strmatch('Conductivity',Variables)+1,:)';
SimTime = timedsuit(1,:)';
%SimTime = SimTime';

eval(['load ' FileName '_Exp.mat'])
%if FileName(1,1)==['0']
%    MeasDataConduc = eval(['X' FileName '_Exp']);
%else
    MeasDataConduc = eval([FileName '_Exp']);
%end
MeasTime        = MeasDataConduc(:,1);
MeasConduc      = MeasDataConduc(:,2);
SimConducInterp = interp1(SimTime,SimConduc,MeasTime);%,'spline');
F               = SimConducInterp-MeasConduc;

%plot(SimTime,SimConduc)
%hold on
%plot(MeasTime,MeasConduc)