function hh = Arceer(t,ytop,ybot,fine,ahoek),
% function hh = Arceer(x,ytop,ybot,fine,ahoek),
% arceren van een vlak tussen twee lijnen ytop en ybot
% x is monotoom stijgend
% fine (optioneel) is het maximaal aantal arceerlijnen bij arceren van
% links boven tot rechts onder in het huidige assenstelsel.
% a (optioneel) is de richtingscoefficient van de arceerlijn

% check t
nh = length(t);
dt = t(1:nh-1)-t(2:nh);
if any(dt>=0)
  error('t moet monotoom stijgen');
end

Ylim = get(gca,'Ylim');
Xlim = get(gca,'Xlim');

if nargin <4
  fine = 20;
end
if nargin <5
  ahoek = 45;
end

if abs(tan(ahoek/180*pi))>1e8
  ahoek = 180/pi*atan(1e8);
end

xdata = [];
ydata = [];
xall = [];
yall = [];
% eindwaarde voor b berekenen
% b moet zo lopen dan begint met linker bovenhoek naar rechter onderhoek
% dus lb = t(1).*a +b = Ylim(2) -> b = Ylim2-a*t(1);
% einde Ylim(1)=t(n)*a+b

%limieten doortrekken naar figure zeiden
ax=get(gca,'units');
set(gca,'units','normal');
axpos = get(gca,'position');
set(gca,'units',ax);

%omrekenen naar figuur grenzen
lx=Dhv_arcl([axpos(1) axpos(1)+axpos(3)],[Xlim(1) Xlim(2)],[0 1]);
ly=Dhv_arcl([axpos(2) axpos(2)+axpos(4)],[Ylim(1) Ylim(2)],[0 1]);
Xlim2 = [lx(2) lx(1)+lx(2)];
Ylim2 = [ly(2) ly(1)+ly(2)];

a = tan(ahoek/180*pi)*(Ylim2(2)-Ylim2(1))/(Xlim2(2)-Xlim2(1));

if a>=0
  bb = max(ytop)-a*min(t);
  be = min(ybot)-a*max(t);
  db = (Ylim2(1)-a*Xlim2(2))- (Ylim2(2)-a*Xlim2(1));
end
if a <0
  bb = min(ybot)-a*min(t);
  be = max(ytop)-a*max(t);
  db = (Ylim2(2)-a*Xlim2(2))- (Ylim2(1)-a*Xlim2(1));
end

% en in het totaal wil ik fine lijnen

for b = bb:db*fine/800:be,

  yarc = a.*t+b;

  % bereken van elke lijn de snijliijn met de twee lijnen
  % bereken eerst van de bovenste lijn de snijlijn met de diagonaal.
  % maak een tekendiagram van punt naar punt
  % doe hetzelfde voor de onderste lijn.
  % de diagonaal loopt daar waar beiden postief zijn

  % eerst de bovenste lijn
  htop  = (ytop >yarc);
  dhtop = htop(1:nh-1)-htop(2:nh);
  hbtop = [0 (dhtop<0)];
  hetop = [0 (dhtop>0)];

  % dan onderste lijn
  hbot  = (ybot<yarc);
  dhbot = hbot(1:nh-1)-hbot(2:nh);
  hbbot = [0 (dhbot<0)];
  hebot = [0 (dhbot>0)];

  % snijlijnen
 xb=[];
 yb=[];
 % als het eerste punt tussen lijnen ligt dan is het
 % ook een beginpunt !
 if htop(1)&hbot(1)
   xb = t(1);
   yb = yarc(1);
 end

 if any(hbtop)
  % je weet zeker dat de lijn top tussen hbtop en hbtop-1 snijdt met top
  ltop = Dhv_arcl(t,ytop,hbtop);
  larc = Dhv_arcl(t,yarc,hbtop);
  lbot = Dhv_arcl(t,ybot,hbtop);

  %de snijputen zijn (en liggen tussen hbtop en hbtop -1)
  [xstop,ystop] = Dhv_arcs(ltop,larc);

  %ligt de bot lijn op deze punten lager dan is het een goede start punten
  ysbot = lbot(:,1).*xstop + lbot(:,2);
  nOK = find(ysbot<ystop);

  xb = [xb(:);xstop(nOK)];
  yb = [yb(:);ystop(nOK)];
 end

 if any(hbbot)
   % je weet zeker dat de lijn top tussen hbbot en hbbot-1 snijdt met bot
  lbot = Dhv_arcl(t,ybot,hbbot);
  larc = Dhv_arcl(t,yarc,hbbot);
  ltop = Dhv_arcl(t,ytop,hbbot);

  %de snijputen zijn (en liggen tussen hbtop en hbtop -1)
  [xsbot,ysbot] = Dhv_arcs(lbot,larc);

  %ligt de top lijn op deze punten hoger dan is het een goede start punten
  ystop = ltop(:,1).*xsbot + ltop(:,2);
  nOK = find(ysbot<ystop);

  xb = [xb;xsbot(nOK)];
  yb = [yb;ysbot(nOK)];
 end

 % sorteer deze nu naar oplopende x!
 [xb,ib]=sort(xb);
 yb = yb(ib);

 % nu de eindpunten
 xe = [];
 ye = [];

 %ligt het laatste punt tussen de lijnen dan is het re ook een
 if htop(nh) & hbot(nh)
  xe=t(nh);
  ye=yarc(nh);
 end

 if any(hetop)
  % je weet zeker dat de lijn top tussen hetop en hetop-1 snijdt met top
  ltop = Dhv_arcl(t,ytop,hetop);
  larc = Dhv_arcl(t,yarc,hetop);
  lbot = Dhv_arcl(t,ybot,hetop);

  %de snijputen zijn (en liggen tussen hetop en hetop -1)
  [xstop,ystop] = Dhv_arcs(ltop,larc);

  %ligt de bot lijn op deze punten lager dan is het een goede eind punten
  ysbot = lbot(:,1).*xstop + lbot(:,2);
  nOK = find(ysbot<ystop);

  xe = [xe(:);xstop(nOK)];
  ye = [ye(:);ystop(nOK)];
 end

 if any(hebot)
   % je weet zeker dat de lijn top tussen hebot en hebot-1 snijdt met bot
  lbot = Dhv_arcl(t,ybot,hebot);
  larc = Dhv_arcl(t,yarc,hebot);
  ltop = Dhv_arcl(t,ytop,hebot);

  %de snijputen zijn (en liggen tussen hetop en hetop -1)
  [xsbot,ysbot] = Dhv_arcs(lbot,larc);

  %ligt de top lijn op deze punten hoger dan is het een goede start punten
  ystop = ltop(:,1).*xsbot + ltop(:,2);
  nOK = find(ysbot<ystop);

  xe = [xe;xsbot(nOK)];
  ye = [ye;ysbot(nOK)];
 end

 % sorteer deze nu naar oplopende x!
 [xe,ie]=sort(xe);
 ye = ye(ie);


if length(xb)~=length(xe)
  disp(['foutje in berekening :' num2str(length(xb)-length(xe))])
  xb=[];
  xe=[];
  yb=[];
  ye=[];
end


  xdata = [xb';xe';NaN*ones(size(xb'))];
  ydata = [yb';ye';NaN*ones(size(xb'))];

  xall = [xall;xdata(:)];
  yall = [yall;ydata(:)];

end

% door afrondding komt wel eens een lijntje bijten assenstelsel
OKmin = xall>Xlim(1);
OKmax = xall<Xlim(2);
xall = (~OKmin).*Xlim(1)+(~OKmax).*Xlim(2)+(OKmin & OKmax).*xall;

OKmin = yall>Ylim(1);
OKmax = yall<Ylim(2);
yall = (~OKmin).*Ylim(1)+(~OKmax).*Ylim(2)+(OKmin & OKmax).*yall;

hh=line(xall(:),yall(:));

