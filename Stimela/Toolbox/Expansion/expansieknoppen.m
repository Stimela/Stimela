function val = expansieknoppen(action)


h       = findobj(gcbf,'Tag','PopupMenufiltmat'); %h=handle het handvat voor de waarden
filtmat = get(h,'Value');                         %het nummer uit de lijst van de gekozen waarde 
%filtmat = get(h,'String');                       %alle keuze mogelijkheden uit de lijst
%filtmat = char(filtmat{Value});                  %de text van de keuze
%1 = zand
%2 = granaatzand
%3 = gebroken grind
%4 = magnetiet
%5 = Wales antraciet
%6 = Hydro antraciet
%7 = Nieuw materiaal

%filtermat = {'Zand';'Granaatzand';'Gebroken grind';'Magnetiet';'Wales antraciet';'Hydro antraciet';'Nieuw materiaal'}
%filtermat = {'Sand';'Garnet sand';'Granulate';'Magnetite';'Wales antracite';'Hydro antracite'}
%filtermat kan in de workspace geplaatst worden en vervolgens in de gui control bij string aangeroepen worden.

if filtmat == 7
   filtmat = 6
end


h        = findobj(gcbf,'Tag','PopupMenuzeeffrac'); 
zeeffrac = get(h,'Value');                          
%Zeeffrac = get(h,'String');                        
%Zeeffrac = char(Zeeffrac{Value});
%1  = 2.0   2.24  2.118
%2  = 1.8   2.0   1.898
%3  = 1.6   1.8   1.697
%4  = 1.4   1.6   1.497
%5  = 1.25  1.4   1.323
%6  = 1.12  1.25  1.184
%7  = 1.0   1.12  1.058
%8  = 0.9   1.0   0.949
%9  = 0.8   0.9   0.848
%10 = 0.71  0.8   0.754
%11 = 0.63  0.71  0.669
%12 = 0.56  0.63  0.594
%13 = 0.5   0.56  0.529
%14 = Zeef analyse

if zeeffrac == 14
   zeeffrac = 13;
end


h       = findobj(gcbf,'Tag','EditTextvdiam');
vdiam   = str2num(get(h,'String'));

h       = findobj(gcbf,'Tag','EditTextvlower');
vlower  = str2num(get(h,'String'));

h       = findobj(gcbf,'Tag','EditTextvupper');
vupper  = str2num(get(h,'String'));

h       = findobj(gcbf,'Tag','EditTextpo');
po      = str2num(get(h,'String'));
if po < 0
   po = 0
elseif po > 1
   po = 1
else
end

h       = findobj(gcbf,'Tag','EditTextT');
T       = str2num(get(h,'String'));

switch(action)
   
case 'print' %Printen van het uitvoerscherm
   print   
   
case 'bereken'  %Plotten van de grafieken
  [v,ECorstjens,ERealitymin2,EReality,ERealityplus2,stroming,F3,ECorstjensd,ERealitymin2d,ERealityd,ERealityplus2d] = expansie_s(filtmat,zeeffrac,vdiam,vlower,vupper,T,po);
  
  Expansiev = [v ECorstjens ERealitymin2 EReality ERealityplus2];
  %v             = expansie(:,1);
  %ECorstjens    = expansie(:,2);
  %ERealitymin2  = expansie(:,3);
  %EReality      = expansie(:,4);
  %ERealityplus2 = expansie(:,5);
 
  Expansied = [F3 ECorstjensd ERealitymin2d ERealityd ERealityplus2d];
  %Fractie(:,3)   = expansie(:,6);
  %ECorstjensd    = expansie(:,7);
  %ERealitymin2d  = expansie(:,8);
  %ERealityd      = expansie(:,9);
  %ERealityplus2d = expansie(:,10);
  
  
%Figuur snelheid
h1       = findobj(gcbf,'Tag','figsnelheid');
set(gcbf,'currentaxes',h1)
plot(v,Expansiev(:,3:5))%,'color',[0 0 0],Expansiev(:,4),'color',[1 0 0],Expansiev(:,5),'color',[0 1 0]);
%hold on
%plot(v,Expansiev(:,4),'color',[1 0 0]);
%hold on
%plot(v,Expansiev(:,5),'color',[0 1 0]);
set(h1,'Tag','figsnelheid'); %Tag opnieuw setten want de plot functie vernielt je Tag!!!

xmin = vlower;%*3600;
xmax = vupper;%*3600;
ymin = 0;
if max(ERealitymin2)<100 
   q = 10;
elseif max(ERealitymin2)<1000 
   q = 100;
else
   q=1000;
end

if xmax > 100
   r = 10;
else
   r = 5;
end

ymax = ceil(max(ERealitymin2)/q)*q;
if ymax < 10
   ymax = 10;
end

axis([xmin xmax ymin ymax]);
grid on
%set(gca,'XTick',[xmin:r:xmax])
%set(gca,'YTick',[ymin:0.5*q:ymax])
%title(['Bed expansie bij het terugspoelen van een filter bij verschillende filtersnelheden'])
xlabel('Backwash velocity [m/h]')
ylabel('Expansion [%]')


  
%Figuur diameter

h2       = findobj(gcbf,'Tag','figdiameter');
set(gcbf,'currentaxes',h2)

plot(Expansied(:,1)*1000,Expansied(:,3:5))%,'color',[0 0 0])
%hold on
%plot(Expansied(:,1)*1000,Expansied(:,4),'color',[1 0 0])
%hold on
%plot(Expansied(:,1)*1000,Expansied(:,5),'color',[0 1 0])
set(h2,'Tag','figdiameter');

xmin  = 0.5;%floor(Expansied(1,1)*1000);
xmax  = 2.2;%ceil(Expansied(length(Expansied),1)*1000);
ymin  = 0;
if max(ERealitymin2d)<100 
   q = 10;
elseif max(ERealitymin2d)<1000 
   q = 100;
else
   q=1000;
end

if xmax > 100
   r = 10;
else
   r = 5;
end

ymax = ceil(max(ERealitymin2d)/q)*q;
if ymax < 10
   ymax = 10;
end

axis([xmin xmax ymin ymax]);
grid on
%set(gca,'XTick',[xmin:0.1:xmax])
%set(gca,'YTick',[ymin:0.5*q:ymax])
vdiam=num2str(vdiam);
%title(['Bed expansie bij het terugspoelen van een filter bij verschillende specifieke diameters bij een terugspoelsnelheid van ',vdiam,' m/h'])
xlabel('Specific diameter [mm]')
ylabel('Expansion [%]')


%Figuur stroming

x1begin = 0;
x1eind  = 0;
x2begin = 0;
x2eind  = 0;
x3begin = 0;
x3eind  = 0;
vgraf=[v(1);v;v(length(v))];
for i=1:length(stroming)
   if stroming(i) == 1 
      x1eind=(vgraf(i+1)+vgraf(i+2))/2;
   end
   if stroming(i) == 2 
      x2eind=(vgraf(i+1)+vgraf(i+2))/2;
   end
   if stroming(i) == 3 
      x3eind=(vgraf(i+1)+vgraf(i+2))/2;
   end
end

for i=length(stroming):-1:1
   if stroming(i) == 3 
      x3begin=(vgraf(i+1)+vgraf(i))/2;
   end
   if stroming(i) == 2 
      x2begin=(vgraf(i+1)+vgraf(i))/2;
   end
   if stroming(i) == 1 
      x1begin=(vgraf(i+1)+vgraf(i))/2;
   end
end

x1=[x1begin x1eind;x1begin x1eind];
x2=[x2begin x2eind;x2begin x2eind];
x3=[x3begin x3eind;x3begin x3eind];

if isempty(x1)
   x1=[0 0;0 0];
end
if isempty(x2)
   x2=[0 0;0 0];
end
if isempty(x3)
   x3=[0 0;0 0];
end


y=[0 0;1 1];
z=[0 0;0 0];

h3       = findobj(gcbf,'Tag','stroming');
set(gcbf,'currentaxes',h3)
surface(x1,y,z,'FaceColor',[0 1 1])
surface(x2,y,z,'FaceColor',[1 0 1])
surface(x3,y,z,'FaceColor',[0 0 1])
set(h3,'Tag','stroming');
xmin = vlower;%*3600;
xmax = vupper;%*3600;
ymin = 0;
ymax = 1;
axis([xmin xmax ymin ymax]);


case 'tabel' %Gegevens weergeven in een tabel
  % Openen notepad + aanmaken file met ingevulde waarden
  
  [v,ECorstjens,ERealitymin2,EReality,ERealityplus2,stroming,F3,ECorstjensd,ERealitymin2d,ERealityd,ERealityplus2d] = expansie_s(filtmat,zeeffrac,vdiam,vlower,vupper,T,po);
  Expansiev = [v ECorstjens ERealitymin2 EReality ERealityplus2];
  Expansied = [F3 ECorstjensd ERealitymin2d ERealityd ERealityplus2d];
  
  pomin = po - 2*(po/100);
  pomax = po + 2*(po/100);
  
  filtermat = ['Sand           ';'Granaatzand    ';'Gebroken grind ';'Magnetiet      ';'Wales antraciet';'Hydro antraciet';'Nieuw materiaal'];
  Zeeffractie=['2.0  -  2.24';'1.8  -  2.0 ';'1.6  -  1.8 ';'1.4  -  1.6 ';'1.25 -  1.4 ';'1.12 -  1.25';'1.0  -  1.12';'0.9  -  1.0 ';'0.8  -  0.9 ';'0.71 -  0.8 ';'0.63 -  0.71';'0.56 -  0.63';'0.5  -  0.56'];
  
  Expansied=Expansied(:,3:5);
  Expansied=flipud(Expansied);
   
  Expansie_fig=gcf;
  fid=fopen('Expansion.txt','w');
  fprintf(fid,['Results of the expansion calculation' 13 10 13 10]);
  fprintf(fid,['Filter material   : %s'  13 10],filtermat(filtmat,:));
  fprintf(fid,['Initial porosity  : %1.2f [-]'  13 10],po);
  fprintf(fid,['Water temperature : %2.1f [Celsius]'  13 10 13 10],T);
  
  fprintf(fid,['Table 1: Expansion for different backwash velocities for a fraction of %s mm'  13 10 13 10],Zeeffractie(zeeffrac,:));
  fprintf(fid,['Backwash velocity |     Expansion [%%]     |     Expansion [%%]     |     Expansion [%%]  ' 13 10]);
  fprintf(fid,['      [m/h]       |Initial porosity %.3f |Initial porosity %.3f |Initial porosity %.3f' 13 10],pomin,po,pomax);
  fprintf(fid,['------------------|-----------------------|-----------------------|---------------------' 13 10]);
  fprintf(fid,['%12.2f      |%13.1f          |%13.1f          |%12.1f            ' 13 10],[v,Expansiev(:,3:5)]');
  fprintf(fid,[' '  13 10 13 10]);

  Zeeffractie=flipud(Zeeffractie);
  
  fprintf(fid,['Filter material   : %s'  13 10],filtermat(filtmat,:));
  fprintf(fid,['Initial porosity  : %1.2f [-]'  13 10],po);
  fprintf(fid,['Water temperature : %2.1f [Celsius]'  13 10 13 10],T);
  
  fprintf(fid,['Table 2: Expansion for different fractions for a backwash velocity of %.2f m/h'  13 10 13 10],vdiam);
  fprintf(fid,['     Fraction     |     Expansion [%%]     |     Expansion [%%]     |     Expansion [%%]        ' 13 10]);
  fprintf(fid,['       [mm]       |Initial porosity %.3f |Initial porosity %.3f |Initial porosity %.3f' 13 10],pomin,po,pomax);
  fprintf(fid,['------------------|-----------------------|-----------------------|---------------------' 13 10]);
  length(Zeeffractie);
  for zfrtel=1:length(Zeeffractie)
     fprintf(fid,['   %s   |%13.1f          |%13.1f          |%12.1f            ' 13 10],Zeeffractie(zfrtel,:),[Expansied(zfrtel,1:3)]');
  end
 
  %orient(Expansie_fig,'landscape');
  
  fclose(fid);
  !notepad Expansion.txt
  figure(Expansie_fig);


end %case




