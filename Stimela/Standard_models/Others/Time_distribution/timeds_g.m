function val = graphtimedistribution(naamfile)


%Ophalen van de variabelen
warning off;
V=st_Varia;


%=============================START: AvdBerge, 13/03/00=========================================
if nargin<1
     ib = st_findblock(gcs,'timeds');
   if length(ib)==1
      naamfile = get_pfil(ib{1});
   else
    % meerdere blokken   
     fs = get_pfil(ib);
     n = Radiobox(strvcat(ib),'Select the parameter file of the time distribution file to be visualized');
     if length(n)
       naamfile = fs{n};
     else
       return;
     end
   end  
end
%=============================STOP : AvdBerge, 13/03/00=========================================


%Ophalen van de parameters
P = st_getPdata(naamfile, 'timeds');

th     = P.th;
NumCel = P.NumCel;


%Bewerken van de parameters


%=============================START: AvdBerge, 13/03/00=========================================
eval(['load ' naamfile(1:length(naamfile)-4) '_EM.sti -mat']);
%=============================STOP : AvdBerge, 13/03/00=========================================

%Bewerken van de tijd
Time=timedsEM(1,:);
Time=Time';
ceConduc1  = timedsEM(size(timedsEM,1)-1,:);
%size(timedsEM,1)

%=============================START: AvdBerge, 13/03/00=========================================
eval(['load ' naamfile(1:length(naamfile)-4) '_in.sti -mat']);
%=============================STOP : AvdBerge, 13/03/00=========================================

LengteIn  = size(timedsin,2);
Ql        = timedsin(V.Flow+1,LengteIn);
Tl        = timedsin(V.Temperature+1,LengteIn);
coConduc  = timedsin(V.Conductivity+1,:);


%=============================START: AvdBerge, 13/03/00=========================================
eval(['load ' naamfile(1:length(naamfile)-4) '_out.sti -mat']);
%=============================STOP : AvdBerge, 13/03/00=========================================

Lengteout = size(timedsout,2);
ceConduc  = timedsout(V.Conductivity+1,:);


%Omzetten van getallen naar strings voor weergave
%VolT    = sprintf('%.1f',Vol);
NumCelT = sprintf('%.0f',NumCel);
QlT     = sprintf('%.1f',Ql);
TlT      = sprintf('%.1f',Tl);
thT      = sprintf('%.1f',th);


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
set(gcf,'Name',['Residence Time Distribution']);
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
plot(Time,coConduc)
hold on
plot(Time,ceConduc,'r')
hold on
plot(Time,ceConduc1,'g')
xlabel('Time [sec]')
ylabel('Conductivity []')
title([' '])
%axis([0 200 0 1.4])
grid on

subplot(2,2,2)
plot(Time/th,coConduc)
hold on
plot(Time/th,ceConduc,'r')
xlabel('Theta [sec]')
ylabel('Conductivity []')
title([' '])
axis([0 5 0 1.4])
grid on

subplot(2,2,3)
set(gca,'Visible','off')

subplot(2,2,4)
set(gca,'Visible','off')

text(-0.1,1.1, 'Parameters:')
text(-0.1,1,   'Hydraulic retention time')
text(-0.1,0.9, 'Competely mixed reactors')

text(0.45,1,   thT)
text(0.45,0.9, NumCelT)

text(0.7,1,   's')
text(0.7,0.9, '-')


%Time=Time(find(ceConduc>0.001));
%Time=Time-Time(1,1);
%ceConduc=ceConduc(find(ceConduc>0.001))';
%test10_10 = [Time ceConduc];
%save test10_10.prn test10_10 -ascii
%size(Time)
%size(ceConduc)
%
%figure
%plot(Time,ceConduc,'r')
