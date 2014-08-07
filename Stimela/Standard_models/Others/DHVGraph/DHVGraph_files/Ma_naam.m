function h=Ma_naam(naam);
%  h=Ma_naam(naam);
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

if nargin == 0,
  naam = '';
end;

%hold on
axis(axis);
v=axis;
[m,n]=size(v);
d = date;
if n == 4,
   xpl = v(2)+.01*(v(2)-v(1));
   ypl = v(3);
   if strcmp(get(gca,'xdir'),'reverse'),
     xpl = v(1);
   end
   if strcmp(get(gca,'ydir'),'reverse'),
     ypl = v(4);
   end

   h= text(xpl,ypl,[naam '  ' d]);
   set(h,'Clipping','off');
   set(h,'HorizontalAlignment','Left')
   set(h,'VerticalAlignment','top')
   set(h,'Rotation',90)
   set(h,'Fontsize',[6])
   set(h,'userdata',['usernaam']);
end;
if n ==6,
   [az,el] = view;
   if (az <-90) & (az >-180)
   	xpl = v(1);
   	ypl = v(3);
   	zpl = v(5);
   else
   	xpl = v(2);
   	ypl = v(3);
   	zpl = v(5);
   end;

   h= text(xpl,ypl,zpl,[naam '  ' d]);
   set(h,'Clipping','off');
   set(h,'HorizontalAlignment','Left')
   set(h,'VerticalAlignment','top')
   set(h,'Rotation',90)
   set(h,'Fontsize',[6]);
   set(h,'userdata',['usernaam']);
end;
%hold off

